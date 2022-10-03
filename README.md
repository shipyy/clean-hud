# Clean HUD

This plugins allows for a more in-depth customization of various aspects from [SurfTimer](https://github.com/surftimer/SurfTimer).
</br>_Supported [SurfTimer](https://github.com/surftimer/SurfTimer)_ versions **1.1.2** or above.

___Commands:___
- sm_chud / !chud
- sm_chud_save / !chud_save
- sm_chud_export / !chud_export
- sm_chud_imort / !chud_import

___Currently allows customization for:___
1. Center Speed
2. Checkpoints
3. Key/Mouse Inputs
4. Map/Stage Info
5. Finishing Map Info
6. Timer

# Installation
* Download latest release, exctract and drop the contents of `CleanHUD-v*.*.*.zip` into your `csgo/addons/sourcemod` folder

* Create a new MySQL database configuration  called `cleanhud` on `csgo/addons/sourcemod/configs/databases.cfg`

```
"cleanhud"
	{
		"driver"			"mysql"
		"host"				""
		"database"			""
		"user"				""
		"pass"				""
		"port"				""
	}
```

# Requirements

* version **1.1.2** or above from [SurfTimer](https://github.com/surftimer/SurfTimer) (and its requirements)
* A MySQL database

