<?php

namespace Plugin\SamplePayment\Form\Type;

use Symfony\Component\Form\AbstractType;
use Symfony\Component\Form\FormBuilderInterface;
use Symfony\Component\Validator\Constraints as Assert;
use Symfony\Component\OptionsResolver\OptionsResolverInterface;

class PaymentType extends AbstractType
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
        $builder
            ->add('card_no', 'text', array(
                'label' => 'カード番号',
                'attr' => array(
                    'class' => 'lockon_card_row',
                ),
            ))
            ->add('name01', 'text', array(
                'label' => '姓（英字）',
                'attr' => array(
                    'class' => 'lockon_card_row',
                ),
            ))
            ->add('name02', 'text', array(
                'label' => '名（英字）',
                'attr' => array(
                    'class' => 'lockon_card_row',
                ),
            ))
            ->add('mm', 'integer', array(
                'label' => '有効期限(月)',
                'attr' => array(
                    'class' => 'lockon_card_row',
                ),
            ))
            ->add('yy', 'integer', array(
                'label' => '有効期限(年)',
                'attr' => array(
                    'class' => 'lockon_card_row',
                ),
            ))
            ->add('method', 'choice', array(
                'label' => 'お支払い方法',
                'attr' => array(
                    'class' => 'lockon_card_row',
                ),
                'choices' => array(
                    '1' => '一括払い'
                ),
                'expanded' => false,
                'multiple' => false,
            ))
            ->addEventSubscriber(new \Eccube\Event\FormEventSubscriber());
        ;
    }

    /**
     * {@inheritdoc}
     */
    public function getName()
    {
        return 'sample_payment';
    }
}
