-- get some of dummy's characteristics from mod options
local modoptions=Spring.GetMapOptions()
local dummyhealth=50000
local idleautoheal=40
for key,val in pairs(modoptions) do
	if (key=="mo_dummyhealth") then
		dummyhealth=val
	end
	if (key=="mo_dummyautohealrate") then
		idleautoheal=val
	end
end

--unit definitions
unitDef = {
  unitname            = "dummy",
  name                = "Dummy",
  description         = "Tool of sadism",
  category            = "ALL NOTLAND NOTAIR NOTSHIP NOWEAPON",
  corpse              = "DUMMY_DEAD",
  defaultmissiontype  = "Standby",
  explodeAs           = "NUCLEAR_MISSILE",
  floater             = false,
  footprintX          = 12,
  footprintZ          = 12,
  iconType            = "dummy",
  idleAutoHeal        = idleautoheal,
  idleTime            = 0;
  leaveTracks         = false,
  mass                = 15000,
  maxDamage           = dummyhealth,
  maxSlope            = 40,
  seismicSignature    = 0,
  turninplace         = 0,
  objectName          = "DUMMY",
  selfDestructAs      = "NUCLEAR_MISSILE",
  collisionVolumeType = "box",
  collisionVolumeOffsets = "0 -3 -3",
  collisionVolumeScales = "18 26 40",
  
  buildTime           = 20000,
  buildCostMetal      = 10000,
  buildCostEnergy     = 10000,
  soundCategory       = "ARM_TARG",
  reclaimable         = 0,
  
  side                = "DUMMY",
  sightDistance       = 1024,
  waterline           = 0,
 
  featureDefs         = {

    DEAD = {
				world="All Worlds";
				description="Dummy Wreckage";
				category="corpses";
				object="DUMMY_DEAD";
				featuredead="DUMMY_DEAD";
				footprintx=12;
				footprintz=12;
				height=40;
				blocking=1;
				hitdensity=100;
				metal=17850;
				damage=10440;
				reclaimable=1;
				featurereclamate="SMUDGE01";
				seqnamereclamate="TREE1RECLAMATE";
				energy=0;
    },


    HEAP = {
				world="All Worlds";
				description="Dummy Wreckage";
				category="corpses";
				object="DUMMY_DEAD";
				featuredead="DUMMY_DEAD";
				footprintx=12;
				footprintz=12;
				height=15;
				blocking=1;
				hitdensity=100;
				metal=17850;
				damage=10440;
				reclaimable=1;
				featurereclamate="SMUDGE01";
				seqnamereclamate="TREE1RECLAMATE";
				energy=0;
    },

  },

}

return lowerkeys({ dummy = unitDef })
