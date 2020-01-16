<?php

declare(strict_types=1);

namespace bot\commands;

use Symfony\Component\Console\Command\Command;
use Symfony\Component\Console\Input\InputInterface;
use Symfony\Component\Console\Output\OutputInterface;

class HelloCommand extends Command
{
    protected static $defaultName = 'hello';

    protected function execute(InputInterface $input, OutputInterface $output)
    {
        $output->writeln('Hi!');
    }
}
