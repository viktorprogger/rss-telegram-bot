<?php

declare(strict_types=1);

use bot\commands\HelloCommand;

return [
    'app.id' => 'yii-console',
    'app.name' => 'Yii Console',
    'commands' => [
        'hello' => HelloCommand::class,
    ],
];
