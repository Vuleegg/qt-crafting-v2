Shared = {}
Shared.Locale = "sr"
Shared.ImagePath = "ox_inventory/web/images/" -- # where images for items will display
Shared.DefaultModel = "gr_prop_gr_bench_02a" -- # if you dont want other prop or just dont want to fulfil prop field into creation menu 

-- # DISCORD LOGS shared/bridge/server/editable.lua 

-- # inventory paths 
--[[
    "qb-inventory/html/images/"
    "lj-inventory/html/images/"
    "ox_inventory/web/images/"
    "qs-inventory/html/images/"
    "ps-inventory/html/images/"
]]

Shared.FrameworkNames = { -- # this is name of your framework directory do not delete any of this
    esx = "es_extended",
    qb = "qb-core",
    qbox = "qb-core"
}

--===================================================================================--
--                               ADMIN PERMISSIONS                                   --
--===================================================================================--
-- # add in cfg add_ace group.admin create allow or deny 
-- # add in cfg add_ace group.admin edit allow or deny  -- ALSO REPEAT THIS FOR OTHER STAFF GROUPS
--===================================================================================--
--                                   ANIMATIONS                                      --
--===================================================================================--

Shared.CraftAnimation = {
    anim = "mini@repair",
    dict = "fixing_a_ped",
    isAnim = true, 
    isScenario = false,
    scenario = "PROP_HUMAN_SEAT_CHAIR_MP_PLAYER"
}
--===================================================================================--
--                                   UPDATED                                         --
--===================================================================================--

-- 1.  Fixed blip bug 
-- 2.  Fixed js problem with freezing cursor 
-- 3.  Fixed canAccess function for gangs and jobs 
-- 4.  Optimized table strucure 
-- 5.  Changed edit menu from qt-context to ox_lib context 
-- 6.  Cleaned code 
-- 7.  Instead of selecting framework, target and everything added resource state checker and automatically selecting which framework and target you're using 
-- 8.  Animation configuration into config added 
-- 9.  Permissions are chanegd to ace perms system ( a lot of easier solution for beginners )
-- 10. Identifier function created into server for logs ( xPlayer nil problem resolved ) 
-- 11. Complete disabled qt-library functionality into this script 
-- 12. Reworked checkbox and create menu functionality 
-- 13. Added disabling functionality into edit menu if is something enabled disabeld or table is empty option into context menu will be disabled 
-- 14. Added delete blip and disable job and gang check functionality 
-- 15. Fixed raycast camera finish control button 
-- 15. Html added to locales 
-- 16. Fixed crafting check for hasitems and optimized
-- 17. Table structure optimized
-- 18. For ESX users loading jobs table problem resolved