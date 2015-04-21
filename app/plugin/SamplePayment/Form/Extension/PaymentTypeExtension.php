<?php

namespace Plugin\SamplePayment\Form\Extension;

use Symfony\Component\Form\AbstractTypeExtension;
use Symfony\Component\Form\FormBuilderInterface;
use Symfony\Component\Form\FormInterface;
use Symfony\Component\Form\FormView;
use Symfony\Component\OptionsResolver\OptionsResolverInterface;
use Symfony\Component\Validator\Constraints as Assert;
use Symfony\Component\Validator\ExecutionContextInterface;

/**
 * FreezeTypeExtension.
 */
class PaymentTypeExtension extends AbstractTypeExtension
{
    private $app;

    public function __construct(\Eccube\Application $app)
    {
        $this->app = $app;
    }

    /**
     * {@inheritdoc}
     */
    public function buildForm(FormBuilderInterface $builder, array $options)
    {
        $app = $this->app;

        $builder
            ->add('card', 'sample_payment', array(
                'label' => 'ロックオンペイメント',
                'attr' => array(
                    'class' => 'lockon_card_table',
                ),
                'constraints' => array(
                    new Assert\Callback(function($card, ExecutionContextInterface $context) use ($app) {
                        $result = $app['com.card.service']->getResult();
                        if (!$result) {
                            $context->addViolation('決済情報が間違っています。');
                        }
                    }),
                ),
            ));
    }

    /**
     * {@inheritdoc}
     */
    public function buildView(FormView $view, FormInterface $form, array $options)
    {
    }

    public function getExtendedType()
    {
        return 'shopping';
    }

}
