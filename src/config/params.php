<?php

declare(strict_types=1);

return [
    'app.id' => 'yii-console',
    'app.name' => 'Yii Console',
    'commands' => [
        'serve' => \Yiisoft\Yii\Console\Command\Serve::class,
    ],
];
