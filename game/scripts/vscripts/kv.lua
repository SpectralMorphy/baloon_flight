KV = {}

KV.HEROES = table.overlay(
	LoadKeyValues('scripts/npc/npc_heroes.txt'),
	LoadKeyValues('scripts/npc/npc_heroes_custom.txt')
)

KV.HERO_LIST = LoadKeyValues('scripts/npc/herolist.txt')