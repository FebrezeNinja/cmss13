/* Gifts and wrapping paper
 * Contains:
 * Gifts
 * Wrapping Paper
 */

/*
 * Gifts
 */
/obj/item/a_gift
	name = "gift"
	desc = "PRESENTS!!!! eek!"
	icon = 'icons/obj/items/gifts.dmi'
	icon_state = "gift1"
	item_state = "gift1"

/obj/item/a_gift/Initialize()
	. = ..()
	pixel_x = rand(-10,10)
	pixel_y = rand(-10,10)
	if(w_class > 0 && w_class < 4)
		icon_state = "gift[w_class]"
	else
		icon_state = "gift[pick(1, 2, 3)]"
	return

/obj/item/gift/attack_self(mob/user)
	..()
	user.drop_held_item()
	if(gift)
		user.put_in_active_hand(gift)
		gift.add_fingerprint(user)
	else
		to_chat(user, SPAN_NOTICE("The gift was empty!"))
	deconstruct(TRUE)
	return

/obj/item/a_gift/ex_act()
	deconstruct(FALSE)
	return

/obj/effect/spresent/relaymove(mob/user)
	if (user.stat)
		return
	to_chat(user, SPAN_NOTICE(" You can't move."))

/obj/effect/spresent/attackby(obj/item/W as obj, mob/user as mob)
	..()

	if (!HAS_TRAIT(W, TRAIT_TOOL_WIRECUTTERS))
		to_chat(user, SPAN_NOTICE(" I need wirecutters for that."))
		return

	to_chat(user, SPAN_NOTICE(" You cut open the present."))

	for(var/mob/M in src) //Should only be one but whatever.
		M.forceMove(src.loc)
		if (M.client)
			M.client.eye = M.client.mob
			M.client.perspective = MOB_PERSPECTIVE

	deconstruct()

/obj/item/a_gift/attack_self(mob/M)
	..()

	var/gift_type = pick(
		/obj/item/storage/wallet,
		/obj/item/storage/photo_album,
		/obj/item/storage/box/snappops,
		/obj/item/storage/fancy/crayons,
		/obj/item/storage/belt/champion,
		/obj/item/tool/soap/deluxe,
		/obj/item/tool/pickaxe/silver,
		/obj/item/tool/pen/white,
		/obj/item/explosive/grenade/smokebomb,
		/obj/item/corncob,
		/obj/item/poster,
		/obj/item/book/manual/barman_recipes,
		/obj/item/book/manual/chef_recipes,
		/obj/item/toy/bikehorn,
		/obj/item/toy/beach_ball,
		/obj/item/weapon/banhammer,
		/obj/item/toy/balloon,
		/obj/item/toy/blink,
		/obj/item/toy/crossbow,
		/obj/item/toy/gun,
		/obj/item/toy/katana,
		/obj/item/toy/prize/deathripley,
		/obj/item/toy/prize/durand,
		/obj/item/toy/prize/fireripley,
		/obj/item/toy/prize/gygax,
		/obj/item/toy/prize/honk,
		/obj/item/toy/prize/marauder,
		/obj/item/toy/prize/mauler,
		/obj/item/toy/prize/odysseus,
		/obj/item/toy/prize/phazon,
		/obj/item/toy/prize/ripley,
		/obj/item/toy/prize/seraph,
		/obj/item/toy/spinningtoy,
		/obj/item/toy/sword,
		/obj/item/reagent_container/food/snacks/grown/ambrosiadeus,
		/obj/item/reagent_container/food/snacks/grown/ambrosiavulgaris,
		/obj/item/clothing/accessory/tie/horrible)

	if(!ispath(gift_type,/obj/item))
		return

	var/obj/item/I = new gift_type(M)
	M.temp_drop_inv_item(src)
	M.put_in_hands(I)
	I.add_fingerprint(M)
	qdel(src)
	return

/*
 * Wrapping Paper
 */
/obj/item/wrapping_paper
	name = "wrapping paper"
	desc = "You can use this to wrap items in."
	icon = 'icons/obj/items/tools.dmi'
	icon_state = "wrap_paper"
	var/amount = 20

/obj/item/wrapping_paper/attackby(obj/item/W as obj, mob/user as mob)
	..()
	if (!( locate(/obj/structure/surface/table, src.loc) ))
		to_chat(user, SPAN_NOTICE(" You MUST put the paper on a table!"))
	if (W.w_class < 4)
		var/obj/item/left_item = user.l_hand
		var/obj/item/right_item = user.r_hand
		if ( (left_item && HAS_TRAIT(left_item, TRAIT_TOOL_WIRECUTTERS)) || (right_item && HAS_TRAIT(right_item, TRAIT_TOOL_WIRECUTTERS)) )
			var/a_used = 2 ** (src.w_class - 1)
			if (src.amount < a_used)
				to_chat(user, SPAN_NOTICE(" You need more paper!"))
				return
			else
				if(istype(W, /obj/item/smallDelivery) || istype(W, /obj/item/gift)) //No gift wrapping gifts!
					return

				if(user.drop_held_item())
					amount -= a_used
					var/obj/item/gift/G = new /obj/item/gift( src.loc )
					G.size = W.w_class
					G.w_class = G.size + 1
					G.icon_state = text("gift[]", G.size)
					G.gift = W
					W.forceMove(G)
					G.add_fingerprint(user)
					W.add_fingerprint(user)
					add_fingerprint(user)
			if (src.amount <= 0)
				deconstruct(TRUE)
				return
		else
			to_chat(user, SPAN_NOTICE(" You need scissors!"))
	else
		to_chat(user, SPAN_NOTICE(" The object is FAR too large!"))
	return

/obj/item/wrapping_paper/deconstruct(disassembled = TRUE)
	if(disassembled)
		new /obj/item/trash/c_tube( src.loc )
	return ..()

/obj/item/wrapping_paper/get_examine_text(mob/user)
	. = ..()
	. += "There is about [amount] square units of paper left!"


/obj/item/wrapping_paper/attack(mob/target as mob, mob/user as mob)
	if (!istype(target, /mob/living/carbon/human)) return
	var/mob/living/carbon/human/H = target

	if (istype(H.wear_suit, /obj/item/clothing/suit/straight_jacket) || H.stat)
		if (src.amount > 2)
			var/obj/effect/spresent/present = new /obj/effect/spresent (H.loc)
			src.amount -= 2

			if (H.client)
				H.client.perspective = EYE_PERSPECTIVE
				H.client.eye = present

			H.forceMove(present)

			H.attack_log += text("\[[time_stamp()]\] <font color='orange'>Has been wrapped with [src.name]  by [user.name] ([user.ckey])</font>")
			user.attack_log += text("\[[time_stamp()]\] <font color='red'>Used the [src.name] to wrap [H.name] ([H.ckey])</font>")
			msg_admin_attack("[key_name(user)] used [src] to wrap [key_name(H)] in [get_area(user)] ([user.loc.x], [user.loc.y], [user.loc.z]).", user.loc.x, user.loc.y, user.loc.z)

		else
			to_chat(user, SPAN_NOTICE(" You need more paper."))
	else
		to_chat(user, "They are moving around too much. A straightjacket would help.")
