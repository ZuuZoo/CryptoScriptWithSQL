-- Resource manifest data
resource_manifest_version '44febabe-d386-4d18-afbe-5e627f4af937'

-- Resource information
name 'bitcoin-trader'
description 'Bitcoin vásárlós/eladós script FiveM-hez'
version '1.0.0'

-- Server script
server_script 'server.lua'

-- Config script
client_script 'config.lua'


dependencies {
    'mysql-async'
}
