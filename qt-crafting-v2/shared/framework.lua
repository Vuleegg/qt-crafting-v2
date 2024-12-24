if GetResourceState(Shared.FrameworkNames.esx) ~= 'missing' then 
    ESX = exports[Shared.FrameworkNames.esx]:getSharedObject()
elseif GetResourceState(Shared.FrameworkNames.qb) ~= 'missing' then 
    QBCore = exports[Shared.FrameworkNames.qb]:GetCoreObject()
elseif GetResourceState(Shared.FrameworkNames.qbox) ~= 'missing' then 
    QBOX = exports[Shared.FrameworkNames.qbox]:GetCoreObject()
end