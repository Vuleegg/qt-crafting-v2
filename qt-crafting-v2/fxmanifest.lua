fx_version 'cerulean'
game 'gta5'
framework 'ESX, QB, QBOX'
description 'Advanced Crafting V2'
author 'qt-dev'
version '2.1.0'
lua54 'yes'

shared_scripts {
    '@ox_lib/init.lua',
    'shared.lua',
    'shared/framework.lua',
    'locales.lua', 
    'locales/*.lua'
}

client_scripts {
    'shared/modules/client/*.lua',
    'cl_main.lua'
}

server_scripts {
    'shared/modules/server/*.lua',
    'sv_main.lua'
}

ui_page 'web/index.html'

files {
    'web/*.*',
}

keymapping {
    name = "Setup POS Key",
    key = "ENTER", 
    description = "Key to confirm and set position",
    action = "setup_pos_key"
}
