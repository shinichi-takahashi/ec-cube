<?php

namespace Plugin\SamplePayment;

use Symfony\Component\EventDispatcher\EventSubscriberInterface;
use Symfony\Component\Form\FormEvent;
use Eccube\Event\RenderEvent;
use Eccube\Event\ShoppingEvent;

class SamplePayment implements EventSubscriberInterface
{
    private $app;

    public function __construct($app)
    {
        $this->app = $app;
    }
    
    public static function getSubscribedEvents() {
        return array(
            'eccube.event.render.shopping.before' => array(
                array('onRenderShoppingBefore', 10),
            ),
            'eccube.service.order.commit.before' => array(

                array('onServiceOrderCommitBefore', 1)),
        );
    }

    public function onRenderShoppingBefore(RenderEvent $event)
    {
        $source = $event->getSource();
        $Payment = $this->app['orm.em']->getRepository('Eccube\Entity\Payment')
            ->findOneBy(array(
                'module_id' => intval($this->app['SamplePayment']['const']['PAYMENT_ID']),
            ));
        $source .= '
            <script>
                ;$(function(){
                    var selected = $("#shopping_payment :selected").val();
                    if (selected == ' . $Payment->getId() . ') {
                        $(".lockon_card_table").parents("table").eq(0).css("display", "");
                    } else {
                        $(".lockon_card_table").parents("table").eq(0).css("display", "none");
                    }
                });
            </script>
        ';
        $event->setSource($source);
    }

    public function onServiceOrderCommitBefore(ShoppingEvent $event)
    {
        $Order = $event->getOrder();
        $app = $event->getApp();

        $form = $app['form.factory']
            ->createBuilder('shopping')
            ->getForm();
        $form->handleRequest($app['request']);
        $data = $form->getData();
        $card = $data['card'];
        $card['order_id'] = $Order['id'];

        $Card = new \Plugin\SamplePayment\Entity\Card();
        $Card->setCard($card);
        $app['orm.em']->persist($Card);
        $app['orm.em']->flush();
    }

}