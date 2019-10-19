@{
    AllNodes = 
    @(
        @{
            NodeName                    = '*'
            PSDscAllowPlainTextPassword = $true
            PSDscAllowDomainUser        = $true
        },
        @{
            NodeName                    = 'localhost'
            Role                        = 'DC'
        }

    )
}

