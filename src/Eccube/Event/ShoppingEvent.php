<?php

namespace Eccube\Event;

use Symfony\Component\EventDispatcher\Event;

class ShoppingEvent extends Event
{
    private $app;

    private $Order;

    public function __construct()
    {
    }

    public function getApp()
    {
        return $this->app;
    }

    public function setApp($app)
    {
        $this->app = $app;

        return $this;
    }

    public function getOrder()
    {
        return $this->Order;
    }

    public function setOrder(\Eccube\Entity\Order $Order)
    {
        $this->Order = $Order;

        return $this;
    } 

}