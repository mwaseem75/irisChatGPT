Class fhirsetup.Setup
{

ClassMethod SetupFHIRServer(ns = "FHIRSERVER", appKey = "/fhir/r4", testLoad = 1, interactionsStrategy As %String(VALUELIST=",Json,JsonAdvSql") = "Json") As %Status
{
    set st = $$$OK
    Write !,"=== Initialization: Namespace: "_ns_", Webapp: "_appKey,!

    zn "HSLIB"
    set namespace = ns

    if interactionsStrategy = "Json" {
        set strategyClass = "HS.FHIRServer.Storage.Json.InteractionsStrategy"
    } elseif interactionsStrategy = "JsonAdvSql" {
        set strategyClass = "HS.FHIRServer.Storage.JsonAdvSQL.InteractionsStrategy"
    }
    set metadataPackages = $lb("hl7.fhir.r4.core@4.0.1")

    if '##class(%SYS.Namespace).Exists(namespace) {
        Do ##class(HS.Util.Installer.Foundation).Install(namespace)
    }

    zn namespace

    do ##class(HS.FHIRServer.Installer).InstallNamespace()

    if '##class(HS.FHIRServer.ServiceAdmin).EndpointExists(appKey) {
        do ##class(HS.FHIRServer.Installer).InstallInstance(appKey, strategyClass, metadataPackages)
    }

    set strategy = ##class(HS.FHIRServer.API.InteractionsStrategy).GetStrategyForEndpoint(appKey)
    set config = strategy.GetServiceConfigData()
    set config.DebugMode = 4
    do strategy.SaveServiceConfigData(config)

    if testLoad {
        set dir = "/opt/irisbuild/fhirdata/"
        write !," ====== Loading test data from "_dir
        set st = ##class(HS.FHIRServer.Tools.DataLoader).SubmitResourceFiles(dir, "FHIRServer", appKey)
        if 'st write $System.Status.GetErrorText(st)
    }

    quit st
}

}