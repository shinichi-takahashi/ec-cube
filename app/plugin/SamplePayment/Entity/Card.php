<?php

namespace Plugin\SamplePayment\Entity;

use Doctrine\ORM\Mapping as ORM;

/**
 * AuthExclude
 */
class Card extends \Eccube\Entity\AbstractEntity
{
    private $id;

    private $order_id;

    private $card_no;

    private $name01;

    private $name02;

    private $mm;

    private $yy;

    private $method;

    public function setCard(array $card)
    {
        $this->setCardNo($card['card_no'])
            ->setName01($card['name01'])
            ->setName02($card['name02'])
            ->setMm($card['mm'])
            ->setYy($card['yy'])
            ->setMethod($card['method'])
            ->setOrderId($card['order_id']);
    }

    public function getId()
    {
        return $this->id;
    }

    public function setOrderId($orderId)
    {
        $this->order_id = $orderId;

        return $this;
    }

    public function getOrderId()
    {
        return $this->order_id;
    }

    public function setCardNo($cardNo)
    {
        $this->card_no = $cardNo;

        return $this;
    }

    public function getCardNo()
    {
        return $this->card_no;
    }

    public function setName01($name)
    {
        $this->name01 = $name;

        return $this;
    }

    public function getName01()
    {
        return $this->name01;
    }

    public function setName02($name)
    {
        $this->name02 = $name;

        return $this;
    }

    public function getName02()
    {
        return $this->name02;
    }

    public function setMm($mm)
    {
        $this->mm = $mm;

        return $this;
    }

    public function getMm()
    {
        return $this->mm;
    }

    public function setYy($yy)
    {
        $this->yy = $yy;

        return $this;
    }

    public function getYy()
    {
        return $this->yy;
    }

    public function setMethod($method)
    {
        $this->method = $method;

        return $this;
    }

    public function getMethod()
    {
        return $this->method;
    }
}

