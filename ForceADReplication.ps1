##Force replicate all your domain controllers.  Be sure to change the DOMAIN and TLD in line 11.

$DomainControllers = Get-ADDomainController -Filter *
ForEach ($DC in $DomainControllers.Name) {
    Write-Host "Processing for "$DC -ForegroundColor Green
    If ($Mode -eq "ExtraSuper") { 
        REPADMIN /kcc $DC
        REPADMIN /syncall /A /e /q $DC
    }
    Else {
        REPADMIN /syncall $DC "dc=DOMAIN,dc=TLD" /d /e /q
    }
}
