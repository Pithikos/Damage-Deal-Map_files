local options={
    {
       key="dd_options",
       name="Damage Deal - Options",
       desc="Damage Deal - Options",
       type="section",
    },
	{
		key     = "mo_dummyhealth",
		name    = "Dummy Health",
		desc    = "Dummy's health",
		type    = "number",
		section = "dd_options",
		def     = 50000,
		min     = 100,
		max     = 90000000,
		step    = 100,
	},
	{
		key     = "mo_dummyautohealrate",
		name    = "Dummy autoheal",
		desc    = "Dummy's autoheal rate",
		type    = "number",
		section = "dd_options",
		def     = 40,
		min     = 0,
		max     = 9000000,
		step    = 5,
	},
}
return options
