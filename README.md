# MandrillMount
WoW addon for summoning mounts.  Originally written by TarraWhite but appears to be abandoned.  This is a continuation to support Battle for Azeroth.  What follows is the original description and usage for the addon.

https://www.curseforge.com/wow/addons/mandrill-mount


# Introduction:
This is a general ground/flying mount addon.
For shamans it allows you to use either ghost wolf (moving, indoors or combat), ground mount (not moving, outdoors, not flyable and not in combat), flying mount (not moving, outdoors, flyable and not in combat) or leave vehicle (when you are in one) with just one button press. I highly recommend to have Secure Ability Toggle enabled (Interface->ActionBars->Secure Ability Toggle). If you are going to use a ground mount it will cast water walking and the ground mount at same time.
For druids, it casts the appropriate form while moving and a mount while standing still. During combat the macro will work as a shape shift macro (slow/root removal) but only using cat and travel form (except flight form). Need a separated macro if you want one for bear/moonkin form (since they are slower and the addon is supposed to pick the quickest form).
For monks, it casts Zen Flight when moving if you have the glyph.

If you choose the Corral in Draenor's Nagrand it will cast the Telaari Talbuk/Frostwolf War Wolf.

It works in Vash'jir. If you are there and swimming the macro will cast Abyssal Seahorse. If you have Sea Turtle or Subdued Sea Horse (Poseidus) it will cast them when you are swimming and not in Vash'jir.

You can also use this addon for your non-shaman characters and it will work the same way except for not doing shaman specific things (water walking and ghost wolf) of course.

For non-shamans (that don't have water walking spell) there are some additional features for aquatic environments. When you want to fly away of the water but have an aquatic mount available, you need to jump above water and use the button within 1s to cast the flying mount. If you are on a non-flyable zone and have Azure Water Strider / Crimson Water Strider you can use the same technique to summon that mount (doesn't work in battlegrounds though).

## Basic usage:
To make the addon work, you need to make a macro like this (macro name is not important but make sure you don't have another macro with the same name and that the macro name is not a number like 1,2,3, etc as it may cause issues, set icon as "?"):

    #showtooltip
    /MandrillMount Raven Lord, Red Proto-Drake
    /click MandrillMount

The first name is the ground mount name and the second name is the flying mount name. Replace Raven Lord by your ground mount name and Red Proto-Drake by your flying mount name. If you want the same mount for both ground and flying (in this case must be mounts like Tyrael's Charger, Celestial Steed etc that can fly and also be used on non-flyable zones as well) then just write the name once like this:

    #showtooltip
    /MandrillMount Celestial Steed
    /click MandrillMount

You can also use random instead of a name and it will cast a random favorite mount (if any is selected in the mount journal).

Bring the macro to action bar and just use it from now on: one button for every thing related to travel. The macro icon will change depending on the situation. Enjoy!

## Advanced usage:
You can also include up to three extra mounts to be cast when using the macro with modifier keys shift, control and alt. The full syntax is:

    #showtooltip
    /MandrillMount ground_mount_name, flying_mount_name, shift_mount_name, control_mount_name, alt_mount_name
    /click MandrillMount

You can just omit the non used names if they are at the end but if the non used names are intermediate (let's say you don't want a special mount with shift but want one with control) then you need to use right amount of comas to define them. Example:

    #showtooltip
    /MandrillMount Raven Lord, Red Proto-Drake, , Traveler's Tundra Mammoth
    /click MandrillMount

will cast Traveler's Tundra Mammoth if you use the macro with control and no special mount will be cast with shift (empty argument) or alt (omitted argument).

