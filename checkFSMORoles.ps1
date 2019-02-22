$domain = read-Host 'FQDN:'
get-adforest $domain | format-list schemamaster,domainnamingmaster
get-addomain $domain | format-list pdcemulator,ridmaster,infrastructuremaster