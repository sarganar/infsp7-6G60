Version 1/100713 of Multi P (for Glulx only) by Sarganar begins here.

"Extension que permite juegos multijugador en I7. Para usar junto con dispachers, como Rebot."

"FOR BUILD 6E72. Many Thanx to Jesse McGrew for the main code, from Guncho project."

[TODO:

*Multivamp/MultiZX:QuienesSub
	! El objeto multiobject puede proporcionar una rutina
	! quienes_extra que recibe como parámetro un jugador, y
	! muestra información adicional sobre él.

*ojo al usar tell combinado con say en una rule: Tell, cierra el tags y los siguientes says salen como PUBLICO. BUG?

NEW:
2010.713
* Sync with Build6E72

901.15
* To polite reject player command
* Codding para soportar personajes reservados (Multivamp)
*cleanup the current PC
*set PC gender rule deshabilitado, mejora trabajar con los female y male comunes
]


[Use authorial modesty.]
Use full-length room descriptions.
Use dynamic memory allocation of at least 16384.
Use MAX_STATIC_DATA of 500000.

Part 1 - Player characters

[We don't want "your former self" hanging around.]

[When play begins: move yourself to the PC-corral.]
When play begins: move yourself to the Recibidor, without printing a room description 

[ La habitación Recibidor es donde comienza el "metajuego", desde la que
   se espera a que alguien se añada al juego real. No se mueve el objeto yourself al corral porque eso genera
   un error en tiempo de ejecucion]

Recibidor is a room. The description of Recibidor is usually "Bienvenido al recibidor del juego. Para entrar escribe 'jugar como tu_nombre'. Ej: jugar como Sancho."


Chapter 1 - The PC kind

A PC is a kind of person. A PC is usually proper-named. The PC kind translates into I6 as "i7_pc_kind".

Include (- with pronouns 0 0 0 0, -) when defining a PC.

A PC can be action-observant. 
[The action-observant property translates into I6 as "i7_action_observant".]

A PC can be reserved or unreserved. A PC is usually unreserved.

A PC has indexed text called the mud-name. Rule for printing the name of a PC (called whoever) (this is the PC name printing rule): say mud-name of whoever. Understand the mud-name property as describing a PC.

A PC has indexed text called the low-mud-name.

[The description of a PC is "[possibly customized description of the item described]".]

After examining a PC (this is the list PC possessions after examining rule):
    if the noun is wearing something, say "[The noun] is wearing [a list of things worn by the noun.";
    if the noun is carrying something, say "[The noun] is carrying [a list of things carried by the noun]."

[To say possibly customized description of (victim - PC):
	let custom desc be player attribute "description" of the victim;
	if custom desc is "" begin;
        issue library message examining action number 2 for the victim;
	otherwise;
		replace the text "\$" in custom desc with "&dollar;";
		say custom desc;
	end if.]

[A PC has a number called the mud-id. The mud-id property translates into I6 as "i7_mud_id". The mud-id of a PC is usually 0.

Mud-identification relates a number (called ID) to a PC (called whomever) when ID is the mud-id of whomever. The verb to identify (it identifies, they identify, it identified, it is identified) implies the mud-identification relation.]

A PC has indexed text called the mud-id.The mud-id of a PC is usually "".

Mud-identification relates indexed text (called ID) to a PC (called whomever) when ID is the mud-id of whomever. The verb to identify (it identifies, they identify, it identified, it is identified) implies the mud-identification relation.

Mud-naming relates indexed text (called the name) to a PC (called whomever) when the name is the low-mud-name of whomever. The verb to name (it names, they name, it named, it is named) implies the mud-naming relation.

The PC-corral is a container. The PC-corral object translates into I6 as "i7_pc_corral". 25 PCs are in the PC-corral.

Definition: a PC is connected if it is not in the PC-corral.
Definition: a PC is disconnected if it is in the PC-corral.

To transfer consciousness from (source - a PC) to (target - PC):
	now the mud-name of target is the mud-name of source;
	now the mud-name of source is "";
	now the mud-id of target is the mud-id of source;
	now the mud-id of source is "".


[New Props]
A PC has a text called the waygone.
A PC has a text called the PCgender. The PCgender of PC is usually "m".
[A PC can be human or bot. A PC is usually human.]

Chapter 2 - Special input handling

When play begins (this is the hide command prompt rule):
	now the command prompt is "".

Before starting the virtual machine (this is the hide status line rule): 
    now the left hand status line is ""; 
    now the right hand status line is "". 

After reading a command (this is the handle directed input rule):
	if the player's command matches the regular expression "^(.+?),(.*)" begin;
		let the target-id be the text matching subexpression 1;
		let L be the text matching subexpression 2;
		if the target-id identifies a PC (called the target) begin;
			now the player is the target;
			change the text of the player's command to L;
			won target-id;
		otherwise;
			if L matches the regular expression "(jugar como) (.*)" begin;
			  let the new mud-name be the text matching subexpression 2;
			  let the new location be "Test2";
		       	  add a player named the new mud-name with ID the target-id at location the new location;
			  rule succeeds;
			otherwise if L matches the regular expression "quien|QUIEN";
		              won target-id;
		 	  list connected people;
			  woff;
	 		otherwise; [any other unknow command]
		        won target-id;
			   polite reject player command; [explicacion ante comandos desconocidos]
			  woff;
			end if;
			reject the player's command;
			rule succeeds;
		end if;
	end if.


After reading a command (this is the handle special commands rule):
	if character number 1 in the player's command is "$" begin;
		follow the special command handling rules;
		reject the player's command;
	end if.

To polite reject player command:
	say "Estás en el recibidor del juego. Para entrar escribe 'jugar como mi_nombre'."


Special command handling is a rulebook.

The last special command handling rule (this is the unknown special command rule):
	say "No such special command.";
	rule fails.

Chapter E - Whisper Tag Manager

Whisperopen is a truth state that varies. 

To won (player-id - indexed text):
	if whisperopen is true:
		say "</whisper>";
	say "<whisper [player-id]>";
	now whisperopen is true.

To woff:
	if whisperopen is true:
		say "</whisper>";
	now whisperopen is false.

To say openw:
	if whisperopen is true:
		say "</whisper>";
	say "<whisper";
	now whisperopen is true.

To say closew:
	if whisperopen is true:
		say "</whisper>";
	now whisperopen is false.

[ -- whispers de marcado visual: ]

[To won (player-id - indexed text):
	if whisperopen is true:
		say "----------------------------------------";
	say "[line break][player-id]:[line break]";
	change whisperopen to true.

To woff:
	if whisperopen is true:
		say "----------------------------------------";
	change whisperopen to false.]

[To say openw:
	if whisperopen is true:
		say "----------------------------------------";
	say "[line break]";
	change whisperopen to true.

To say closew:
	if whisperopen is true:
		say "----------------------------------------";
	change whisperopen to false.]

Before reading a command:woff.


Chapter 3 - Special output handling

[BUGFIX: 5J39 contains a bug where passing indexed text from one phrase to another can cause I6 compilation errors when the second phrase has parameters that are runtime type checked. The "target" parameters here should be typed PC, but they're objects instead to work around this bug.]

To tell (message - indexed text) to (target - an object):
	won mud-id of the target;
	say "[message]";
	woff.

To tell (message - indexed text) to everyone else near (target - an object):
	repeat with X running through connected [human] PCs who can see the target begin;
		if X is not the target, say "[openw] [mud-id of X]>[message][closew]";
	end repeat.

To tell (message - indexed text) to everyone who can see (spectacle - an object), except the actor:
	repeat with X running through connected [human] PCs who can see the spectacle begin;
		let skipping be false;
		if except the actor, let skipping be whether or not X is the player;
		if skipping is false, say "[openw] [mud-id of X]>[message][closew]";
	end repeat.

[un broadcast generico]
[todo: se podria usar una etiqueta para el dispacher? "<$a>[message]</$a>]
Multi-announce-tags is a truth state that varies. [usado para protos que no tiene saloon room estilo IRC]
Multi-announce-tags is usually true.[true: la aventura genera tags por cada PC. false: la aventura solo 1 msg imprime sin tags, que va directo al canal IRC]

To announce (message - indexed text): 
	if multi-announce-tags is true:
		repeat with X running through connected [human] PCs:
			say "[openw] [mud-id of X]>[message][closew]";
	otherwise:
		say "[closew][message]".

[	say "<$a>[message]</$a>".]


Chapter 4 - Winning and losing

[Tratamiento de fin de partida segun el tipo de juego:
     COMPETITIVE_SCORING: Uno solo es el que gana/pierde
     NO COMPETITIVE_SCORING: Todos ganan/pierden la partida al mismo tiempo
    El resultado se anuncia a todos con tag <$a> ]


Use competitive scoring translates as (- Constant COMPETITIVE_SCORING; -).

Include (-
[ PRINT_OBITUARY_HEADLINE_R;
    print "<$a>^^    ";
    VM_Style(ALERT_VMSTY);
    print "***";
    #ifdef COMPETITIVE_SCORING;
    if (deadflag == 1) print " ", (the) player, " has lost ";
    if (deadflag == 2) print " ", (the) player, " has won ";
    #ifnot; ! cooperative scoring
    if (deadflag == 1) print " You have lost ";
    if (deadflag == 2) print " You have won ";
    #endif; ! scoring type
    if (deadflag == 3) L__M(##Miscellany, 75);
    
    if (deadflag ~= 0 or 1 or 2 or 3)  {
        print " ";
        if (deadflag ofclass Routine) (deadflag)();
        if (deadflag ofclass String) print (string) deadflag;
        print " ";
    }
    print "***";
    VM_Style(NORMAL_VMSTY);
    print "^^"; #Ifndef NO_SCORE; print "^"; #Endif;
    rfalse;
];
-) instead of "Print Obituary Headline Rule" in "OrderOfPlay.i6t".

The ask the final question rule is not listed in the shutdown rulebook.

Part 2 - Player commands

Chapter 1 - Game engine metacommands

Section 1 - Joining

A special command handling rule (this is the handle joining rule):
	if the player's command matches the regular expression "^\$join (.+)=(-?\d+)(?:,(.*))?$", case insensitively begin;
		let the new mud-name be the text matching subexpression 1;
		let the new mud-id be the text matching subexpression 2;
		let the new location be the text matching subexpression 3;
		add a player named the new mud-name with ID the new mud-id at location the new location;
		rule succeeds;
	end if.


To add a player named (new mud-name - indexed text) with ID (new mud-id - indexed text) at location (new path - indexed text):
	let uncase-name be new mud-name in lower case;[esto no anda, no impide el bug de nombres iguales Sancho:sancho]
	[say "....[uncase-name].";]
	if no PC is in the PC-corral begin;
		won new mud-id;
		say "Lo siento, se han creado demasiados jugadores.";
		woff;
	otherwise if the new mud-id identifies a PC;
		won new mud-id;
		say "ID #[new mud-id] ya está en uso. Lo lamento.";
		woff;
	otherwise if the uncase-name names an unreserved PC;
		won new mud-id;
		say "El nombre '[new mud-name]' ya está en uso. Piensa en otro.";
		woff;
	otherwise if the uncase-name names a connected PC;
		won new mud-id;
		say "El nombre '[new mud-name]' ya está en uso. Piensa en otro.";
		woff;
	otherwise if the uncase-name names a reserved PC (called the reserved body); [juegos con personajes reservados]
[		say "adding reserved player.";]
		let newbie be the reserved body;
		[now the newbie is unreserved;]
	        	now the newbie is proper-named;
		reset pronouns for the newbie;
		now the mud-id of the newbie is the new mud-id;
		now the mud-name of the newbie is the new mud-name;
		follow the player joining rules for the newbie;
	otherwise;
		[if a PC (called the reserved body) is reserved, let newbie be the reserved body;
		otherwise let newbie be a random PC in the PC-corral;]
[		say "adding unreserved player.";]
		let newbie be a random unreserved PC in the PC-corral;
[		now the newbie is unreserved;]
        	now the newbie is proper-named;
		reset pronouns for the newbie;
		[move the newbie along entrance path the new path;]
		now the mud-id of the newbie is the new mud-id;
		now the mud-name of the newbie is the new mud-name;
		now the low-mud-name of the newbie is the uncase-name;
		follow the player joining rules for the newbie;
	end if.

To reset pronouns for (victim - object): (- ResetPronouns({victim}); -).

Include (-
[ ResetPronouns victim  p;
	p = victim.&pronouns;
	if (~~p) rfalse;
	p-->0 = 0; p-->1 = 0; p-->2 = 0; p-->3 = 0;
]; -).

Player joining is an object-based rulebook. The player joining rulebook has a PC called the current PC.

The first player joining rule for a PC (called the newbie):
	now the current PC is the newbie.

A first player joining rule (this is the initial PC location rule):
	if the current PC is in the PC-corral begin;
		let R be the first room;
		move the current PC to R;
	end if;
	now the player is the current PC;	
	won mud-id of the current PC;
	try looking.

[A first player joining rule (this is the set PC gender rule):
	let gender be the PCgender of the current PC in lower case;
	if gender is "m" begin;
		now the current PC is male;
		now the current PC is not neuter;
	otherwise if gender is "f";
		now the current PC is female;
		now the current PC is not neuter;
	otherwise;
		now the current PC is neuter;
	end if.
]
A player joining rule for a PC (called newbie) (this is the announce PC connection rule):
[	let waygone be the waygone of the current PC;
[	let dir be the direction known as waygone;]
	let msg be indexed text;
	if dir is a direction, let msg be "[The newbie] appears from [directional opposite of dir].";
	otherwise let msg be "[The newbie] fades into view.";]
	tell "[The newbie] fades into view." to everyone else near the current PC.

To say directional opposite of (dir - a direction):
    if dir is up begin;
        say "below";
    otherwise if dir is down;
        say "above";
    otherwise;
        say the opposite of dir;
    end if.

Initial Room is a room that varies. Initial Room is usually the Recibidor.

To decide which room is the first room:
	if Initial Room is Recibidor begin;
	   repeat with R running through rooms begin;
		if R is not Recibidor, decide on R;
	   end repeat;
	otherwise;
	  decide on Initial Room;
	end if;
	decide on nothing.

Section 2 - Leaving

Check quitting the game (this is the handle leaving rule):
		let ID-killed be the mud-id of the player;
		remove the player with ID ID-killed;
		stop the action.

To remove the player with ID (parting mud-id - indexed text):
	if the parting mud-id identifies a PC (called the goner), follow the player leaving rules for the goner;
	otherwise say "No such player."

Player leaving is an object-based rulebook. The player leaving rulebook has a PC called the current PC.

The first player leaving rule for a PC (called the goner):
	now the current PC is the goner.

A player leaving rule for a PC (called the goner) (this is the drop possessions when leaving rule):
	if the goner has something begin;
		let msg be indexed text;
		let msg be "You leave behind [the list of things had by the goner] as you exit the realm.";
		tell msg to the goner;
		let msg be "[The goner] drops [a list of things had by the goner].";
		tell msg to everyone else near the goner;
		now everything had by the goner is in the location of the goner;
	end if.

A player leaving rule for a PC (called the goner) (this is the announce PC disconnection rule):
[	let waygone be the waygone of the goner;
	[let dir be the direction known as waygone;]
	if dir is a direction, tell "[The goner] disappears [motion toward dir]." to everyone else near the goner;]
	tell "[The goner] fades away into nothingness." to everyone else near the goner.

To say motion toward (dir - a direction):
    if dir is up begin;
        say "upward";
    otherwise if dir is down;
        say "downward";
    otherwise;
        say "to [the dir]";
    end if.

The last player leaving rule (this is the low-level PC cleanup rule):
	now the player is yourself;	
	now the mud-id of the current PC is "";
	now the mud-name of the current PC is "";
	now the low-mud-name of the current PC is "";
	move the current PC to the PC-corral.

Object-homing relates various things to one thing (called the object-home). The verb to be at home in implies the object-homing relation.

When play begins (this is the initial object homes rule):
	repeat with X running through things begin;
		now X is at home in the holder of X;
	end repeat.

To send (X - a thing) home:[actualmente no se usa]
	tell "[The X] disappears." to everyone who can see X;
	move X to the object-home of X;
	tell "[The X] appears." to everyone who can see X.

To cleanup (X - a PC):
	now the player is yourself;
	now the mud-id of X is "";
	now the mud-name of X is "";
	move X to the PC-corral.

To transfer (character - a PC) to (destiny - a room):
	now the player is the character;
	won mud-id of the character;
	move the character to the destiny.


Section 3 - Polling for info

A special command handling rule (this is the handle info requests rule):
	if the player's command matches "$info" begin;
		say "Info text goes here!";
		rule succeeds;
	end if.


Helping is an action applying to nothing.
Understand "ayuda" or "help" as helping.


Instead of helping (this is the standard helping rule):
	say "Comandos básicos [line break]
      - para hablar con otros: personaje, bla bla[line break]
      - para hablar con otros 2: di a personaje bla bla[line break]
      - para hablar a TODOS: todos mi_texto (lo escucharán los personajes de las cercanías)[line break]
      - para emocion: emo tal_cosa[line break]
      - para salir: quit (salir del juego, no se refiere a finalizar programa...)[line break]";
[      - resto de las acciones: gramática Inform usual.";]
	say other helpies.

To say other helpies:
	do nothing.


Asking Connected is an action out of world.
Understand "who", "quien" and "quienes" as Asking Connected.

Report Asking Connected:
	list connected people.

To list connected people:
	say "Jugadores actuales ([number of connected PC]): [line break]";
	repeat with X running through connected PCs:
		say "[X][line break]";
	if the number of connected PC is 0, say "NINGUNO."


Chapter 2 - Chat commands

The text spoken is an indexed text that varies.
The chat direction is an indexed text that varies.

Answering is speech action. Telling someone about something is speech action. Asking someone about something is speech action. 

Quietly idling is an action out of world, applying to nothing. Understand "qidle" as quietly idling.

Instead of telling someone about something, try asking the noun about it. Instead of answering the noun that something, try asking the noun about it. 

Instead of asking the noun about something (this is the standard chatting rule):
	tell "You say, '[topic understood]'" to the player;
	tell "[The player] says, '[topic understood]'" to everyone else near the player.


Emoting is an action applying to one topic.
Understand "emo [text]" as emoting.

Instead of emoting (this is the standard emoting rule):
	let the full emote be "[The player] [topic understood]";
	tell the full emote to the player;
	tell the full emote to everyone else near the player.

ChatAlling is an action applying to one topic.
Understand "todos [text]" as ChatAlling.

Instead of ChatAlling (this is the standard ChatAlling rule):
	let the full emote be "[The player]:'[topic understood]'";
	tell the full emote to the player;
	tell the full emote to everyone else near the player.

Chapter 4 - Aborting game

Aborting is an action out of world applying to nothing.
Understand "Abortar este juego" as Aborting.

Carry out aborting: follow the immediately quit rule.


Chapter 3 - Modified Inform actions

This is the new other people looking rule:
	if the actor is not the player and the actor is not a PC, say "[The actor] looks around."

The new other people looking rule is listed instead of the other people looking rule in the report looking rules.

This is the new other people examining rule:
	if the actor is not the player and the actor is not a PC, say "[The actor] looks closely at [the noun]."

The new other people examining rule is listed instead of the report other people examining rule in the report examining rulebook.

Report waiting (this is the new report waiting rule):
    stop the action with library message waiting action number 1 for the player.

The standard report waiting rule is not listed in any rulebook.

The block thinking rule is not listed in any rulebook.

Report thinking (this is the standard report thinking rule):
	say "You contemplate your situation."

Report someone thinking (this is the standard report someone thinking rule):
	say "[The actor] pauses for a moment, lost in thought."

The block waving hands rule is not listed in any rulebook.

Report waving hands (this is the standard report waving hands rule):
	say "You wave."

Report someone waving hands (this is the standard report someone waving hands rule):
	say "[The actor] waves."

The block smelling rule is not listed in any rulebook.

Report smelling (this is the standard report smelling rule):
	say "You smell nothing unexpected."

Report someone smelling (this is the standard report someone smelling rule):
	say "[The actor] sniffs[if the noun is the player] you[otherwise if the noun is not the location] [the noun][end if]."

The block listening rule is not listed in any rulebook.

Report listening (this is the standard report listening rule):
	say "You hear nothing unexpected."

Report someone listening (this is the standard report someone listening rule):
	say "[The actor] listens[if the noun is the player] to you[otherwise if the noun is not the location] to [the noun][end if]."

The block tasting rule is not listed in any rulebook.

Report tasting (this is the standard report tasting rule):
	say "You taste nothing unexpected."

Report someone tasting (this is the standard report someone tasting rule):
	say "[The actor] licks [if the noun is the player]you[otherwise][the noun][end if]."

The block jumping rule is not listed in any rulebook.

Report jumping (this is the standard report jumping rule):
	say "You jump on the spot, fruitlessly." 

Report someone jumping (this is the standard report someone jumping rule):
	say "[The actor] jumps."

The block rubbing rule is not listed in any rulebook.

Check an actor rubbing a person (this is the block rubbing people rule):
	if the actor is the player, say "That seems intrusively personal." instead;
	stop the action.

Report rubbing (this is the standard report rubbing rule):
	say "You achieve nothing by this."

Report someone rubbing (this is the standard report someone rubbing rule):
	say "[The actor] rubs [the noun]." instead. 

The block singing rule is not listed in any rulebook.

Report singing (this is the standard report singing rule):
	say "You sing a beautiful tune."

Report someone singing (this is the standard report someone singing rule):
	say "[The actor] assails your ears with an out-of-tune ditty."

[Check quitting the game (this is the block quitting rule):
    say "To disconnect, just type 'quit' by itself." instead.]
Check saving the game (this is the block saving rule):
    say "Saving the game state is not permitted." instead.
Check restoring the game (this is the block restoring rule):
    say "Restoring a saved game is not permitted." instead.
Check restarting the game (this is the block restarting rule):
    say "Restarting the game is not permitted." instead.
Check switching the story transcript on (this is the block transcript on rule):
    say "Transcripting is not permitted." instead.
Check switching the story transcript off (this is the block transcript off rule):
    say "Transcripting is not permitted." instead.
Check preferring abbreviated room descriptions (this is the block superbrief rule):
    say "Changing the room description setting is not permitted." instead.
Check preferring unabbreviated room descriptions (this is the block verbose rule):
    say "Changing the room description setting is not permitted." instead.
Check preferring sometimes abbreviated room descriptions (this is the block brief rule):
    say "Changing the room description setting is not permitted." instead.
Check switching score notification on (this is the block notify on rule):
    say "Changing the score notification setting is not permitted." instead.
Check switching score notification off (this is the block notify off rule):
    say "Changing the score notification setting is not permitted." instead.

Understand "undo" as a mistake ("Sorry, undo is not available.").
Understand "oops" as a mistake ("Don't worry about it.").
Understand "oops [text]" as a mistake ("Sorry, typo correction is not available.").

Chapter 4 - Player interactions

Section 1 - Giving items to other players

Generosity relates various things to one PC (called the potential recipient). The verb to be offered to implies the generosity relation.

Definition: a thing is offered if it is offered to the person asked.

Accepting is an action applying to one thing. Understand "accept [something offered]" as accepting. Understand "accept [something]" as accepting.

Check giving something to a PC (this is the translate giving to offering rule): try offering the noun to the second noun instead. The translate giving to offering rule is listed before the block giving rule in the check giving it to rules. The translate giving to offering rule is listed after the can't give to a non-person rule in the check giving it to rules.

Offering it to is an action applying to two things.

Carry out offering it to:
	now the noun is offered to the second noun.

Report offering it to (this is the standard report offering rule):
	say "You offer [the noun] to [the second noun]."

Report someone offering (this is the standard report someone offering rule):
	if the second noun is the player, say "[The actor] offers you [a noun]. (To accept it, type 'accept [the noun]'.)";
	otherwise say "[The actor] offers [the noun] to [the second noun]."

The accepting action has a person called the person offering (matched as "from").

Setting action variables for accepting:
	if the noun is enclosed by a person (called the current holder), now the person offering is the current holder.

Check accepting a person (this is the block accepting people rule):
	say "You resolve to accept [if the noun is the player]yourself[otherwise][the noun][end if] as a person, faults and all." instead.

Check accepting something (this is the can't accept what's not offered rule):
	if the noun is not offered to the player, say "[The noun] is not being offered to you." instead.

Carry out accepting:
	now the player carries the noun;
	now the noun is not offered to anyone.

Report accepting something (this is the standard report accepting rule):
	say "You accept [the noun][if the person offering is a person] from [the person offering][end if]."

Report someone accepting something (this is the standard report someone accepting rule):
	say "[The actor] accepts [the noun][if the person offering is the player] from you[otherwise if the person offering is a person] from [the person offering][end if]."

Every turn (this is the cancel expired offers rule):
	repeat with item running through things that are offered to someone begin;
		if the potential recipient of the item cannot see the item, now the item is not offered to anyone;
	end repeat.

Section 2 - Showing items to other players

The block showing rule is not listed in any rulebook.

Report showing something to someone (this is the standard report showing rule):
    say "You hold up [the noun] for [the second noun] to see."

Report someone showing something to someone (this is the standard report someone showing rule):
	say "[The actor] holds up [the noun] for ";
	if the second noun is the player
	begin;
		say "you to see. [run paragraph on]"; 
		try examining the noun;
	otherwise;
		say "[the second noun] to see.";
	end if.

Part 3 - Multi-realm awareness

Chapter 1 - Sending the player away

To send (victim - a PC) to (destination - text):
[	if we are going a direction (called dir), change the waygone of the victim to "[dir in short form]";]
	[otherwise change the waygone of the victim to "?";]
	say "[openw] [mud-id of the victim]><$b [destination]>[closew]".

Chapter 5 - Shutdown notification

A special command handling rule (this is the handle shutdown notices rule):
	if the player's command matches "$shutdown" begin;
		follow the realm shutdown rules;
		rule succeeds;
	end if.

Realm shutdown is a rulebook.

Part 4 - Library patches

Chapter 1 - Standard Rules

The investigate multiplayer awareness before action rule is listed instead of the investigate player's awareness before action rule in the specific action-processing rules.
The investigate multiplayer awareness after action and report rule is listed instead of the investigate player's awareness after action rule in the specific action-processing rules.
The report stage rule is not listed in the specific action-processing rules.

This is the investigate multiplayer awareness before action rule:
	if action keeping silent is false:
		let the original player be the player;
		repeat with X running through connected PCs:
[			say "investigate [mud-id of X].";]
			now the player is X;
			consider the player's action awareness rules;
			if rule succeeded, now X is action-observant;
			otherwise now X is not action-observant;
		now the player is the original player.

This is the investigate multiplayer awareness after action and report rule:
	if action keeping silent is false [and the player is human]:
		let the original player be the player;
		repeat with X running through connected PCs:
			if X is not the original player: [hacer los reportes de todos los observadores primero]
				now the player is X;
				if X is not action-observant:
					consider the player's action awareness rules;
					if rule succeeded, now X is action-observant;
				if X is action-observant:
					won mud-id of X;
					consider the specific report rulebook;
					woff;
		now the player is the original player;
		if the player is a connected PC:
			consider the player's action awareness rules;
			if rule succeeded:
				won mud-id of the player;
				consider the specific report rulebook;
				woff.


Chapter 2 - "Parser" segment

[all 'again' section has been dropped.]
Include (-

    if (held_back_mode == 1) {
        held_back_mode = 0;
        VM_Tokenise(buffer, parse);
        jump ReParse;
    }

  .ReType;

	cobj_flag = 0;
    BeginActivity(READING_A_COMMAND_ACT); if (ForActivity(READING_A_COMMAND_ACT)==false) {
		Keyboard(buffer,parse);
		players_command = 100 + WordCount();
		num_words = WordCount();
    } if (EndActivity(READING_A_COMMAND_ACT)) jump ReType;

  .ReParse;

    parser_inflection = name;

    ! Initially assume the command is aimed at the player, and the verb
    ! is the first word

    num_words = WordCount();
    wn = 1;

    #Ifdef LanguageToInformese;
    LanguageToInformese();
    ! Re-tokenise:
    VM_Tokenise(buffer,parse);
    #Endif; ! LanguageToInformese

    num_words = WordCount();

    k=0;
    #Ifdef DEBUG;
    if (parser_trace >= 2) {
        print "[ ";
        for (i=0 : i<num_words : i++) {

            #Ifdef TARGET_ZCODE;
            j = parse-->(i*2 + 1);
            #Ifnot; ! TARGET_GLULX
            j = parse-->(i*3 + 1);
            #Endif; ! TARGET_
            k = WordAddress(i+1);
            l = WordLength(i+1);
            print "~"; for (m=0 : m<l : m++) print (char) k->m; print "~ ";

            if (j == 0) print "?";
            else {
                #Ifdef TARGET_ZCODE;
                if (UnsignedCompare(j, HDR_DICTIONARY-->0) >= 0 &&
                    UnsignedCompare(j, HDR_HIGHMEMORY-->0) < 0)
                     print (address) j;
                else print j;
                #Ifnot; ! TARGET_GLULX
                if (j->0 == $60) print (address) j;
                else print j;
                #Endif; ! TARGET_
            }
            if (i ~= num_words-1) print " / ";
        }
        print " ]^";
    }
    #Endif; ! DEBUG
    verb_wordnum = 1;
    actor = player;
    actors_location = ScopeCeiling(player);
    usual_grammar_after = 0;

  .AlmostReParse;

    scope_token = 0;
    action_to_be = NULL;

    ! Begin from what we currently think is the verb word

  .BeginCommand;

    wn = verb_wordnum;
    verb_word = NextWordStopped();

    ! If there's no input here, we must have something like "person,".

    if (verb_word == -1) {
        best_etype = STUCK_PE;
        jump GiveError;
    }

    ! Now try for "again" or "g", which are special cases: don't allow "again" if nothing
    ! has previously been typed; simply copy the previous text across

    if (verb_word == AGAIN2__WD or AGAIN3__WD) verb_word = AGAIN1__WD;
    if (verb_word == AGAIN1__WD) {
	print "['again' may only be used on a line by itself. Sorry.]^"; ! guncho; all 'again' section has been dropped.
            jump ReType;
        }

    ! Save the present input in case of an "again" next time

    if (verb_word ~= AGAIN1__WD)
        for (i=0 : i<INPUT_BUFFER_LEN : i++) buffer3->i = buffer->i;

    if (usual_grammar_after == 0) {
        j = verb_wordnum;
        i = RunRoutines(actor, grammar); 
        #Ifdef DEBUG;
        if (parser_trace >= 2 && actor.grammar ~= 0 or NULL)
            print " [Grammar property returned ", i, "]^";
        #Endif; ! DEBUG

        if ((i ~= 0 or 1) && (VM_InvalidDictionaryAddress(i))) {
            usual_grammar_after = verb_wordnum; i=-i;
        }

        if (i == 1) {
            parser_results-->ACTION_PRES = action;
            parser_results-->NO_INPS_PRES = 0;
            parser_results-->INP1_PRES = noun;
            parser_results-->INP2_PRES = second;
            if (noun) parser_results-->NO_INPS_PRES = 1;
            if (second) parser_results-->NO_INPS_PRES = 2;
            rtrue;
        }
        if (i ~= 0) { verb_word = i; wn--; verb_wordnum--; }
        else { wn = verb_wordnum; verb_word = NextWord(); }
    }
    else usual_grammar_after = 0;
    
    
-) instead of "Parser Letter A" in "Parser.i6t".

[NounDomain: el flujo de desambiguacion se interrumpe.
La cadena completa de desambiguar no se usa en multiplayer, ya que la siguiente 'respuesta' puede venir de
otro jugador.
]

Include (-
[ NounDomain domain1 domain2 context
	first_word i j k l answer_words marker;
    #Ifdef DEBUG;
    if (parser_trace >= 4) {
        print "   [NounDomain called at word ", wn, "^";
        print "   ";
        if (indef_mode) {
            print "seeking indefinite object: ";
            if (indef_type & OTHER_BIT)  print "other ";
            if (indef_type & MY_BIT)     print "my ";
            if (indef_type & THAT_BIT)   print "that ";
            if (indef_type & PLURAL_BIT) print "plural ";
            if (indef_type & LIT_BIT)    print "lit ";
            if (indef_type & UNLIT_BIT)  print "unlit ";
            if (indef_owner ~= 0) print "owner:", (name) indef_owner;
            new_line;
            print "   number wanted: ";
            if (indef_wanted == INDEF_ALL_WANTED) print "all"; else print indef_wanted;
            new_line;
            print "   most likely GNAs of names: ", indef_cases, "^";
        }
        else print "seeking definite object^";
    }
    #Endif; ! DEBUG

    match_length = 0; number_matched = 0; match_from = wn;

    SearchScope(domain1, domain2, context);

    #Ifdef DEBUG;
    if (parser_trace >= 4) print "   [ND made ", number_matched, " matches]^";
    #Endif; ! DEBUG

    wn = match_from+match_length;

    ! If nothing worked at all, leave with the word marker skipped past the
    ! first unmatched word...

    if (number_matched == 0) { wn++; rfalse; }

    ! Suppose that there really were some words being parsed (i.e., we did
    ! not just infer).  If so, and if there was only one match, it must be
    ! right and we return it...

    if (match_from <= num_words) {
        if (number_matched == 1) {
            i=match_list-->0;
            return i;
        }

        ! ...now suppose that there was more typing to come, i.e. suppose that
        ! the user entered something beyond this noun.  If nothing ought to follow,
        ! then there must be a mistake, (unless what does follow is just a full
        ! stop, and or comma)

        if (wn <= num_words) {
            i = NextWord(); wn--;
            if (i ~=  AND1__WD or AND2__WD or AND3__WD or comma_word
                   or THEN1__WD or THEN2__WD or THEN3__WD
                   or BUT1__WD or BUT2__WD or BUT3__WD) {
                if (lookahead == ENDIT_TOKEN) rfalse;
            }
        }
    }

    ! Now look for a good choice, if there's more than one choice...

    number_of_classes = 0;

    if (number_matched == 1) i = match_list-->0;
    if (number_matched > 1) {
        i = Adjudicate(context);
        if (i == -1) rfalse;
        if (i == 1) rtrue;       !  Adjudicate has made a multiple
                             !  object, and we pass it on
    }

    ! If i is non-zero here, one of two things is happening: either
    ! (a) an inference has been successfully made that object i is
    !     the intended one from the user's specification, or
    ! (b) the user finished typing some time ago, but we've decided
    !     on i because it's the only possible choice.
    ! In either case we have to keep the pattern up to date,
    ! note that an inference has been made and return.
    ! (Except, we don't note which of a pile of identical objects.)

    if (i ~= 0) {
        if (dont_infer) return i;
        if (inferfrom == 0) inferfrom=pcount;
        pattern-->pcount = i;
        return i;
    }

    ! If we get here, there was no obvious choice of object to make.  If in
    ! fact we've already gone past the end of the player's typing (which
    ! means the match list must contain every object in scope, regardless
    ! of its name), then it's foolish to give an enormous list to choose
    ! from - instead we go and ask a more suitable question...

!    if (match_from > num_words) jump Incomplete;
    if (match_from > num_words)  rfalse; !infsp MultiP; interrumpir flujo.



    ! Now we print up the question, using the equivalence classes as worked
    ! out by Adjudicate() so as not to repeat ourselves on plural objects...

	BeginActivity(ASKING_WHICH_DO_YOU_MEAN_ACT);
	if (ForActivity(ASKING_WHICH_DO_YOU_MEAN_ACT)) jump SkipWhichQuestion;

    if (context==CREATURE_TOKEN) L__M(##Miscellany, 45);
    else                         L__M(##Miscellany, 46);

    j = number_of_classes; marker = 0;
    for (i=1 : i<=number_of_classes : i++) {
        while (((match_classes-->marker) ~= i) && ((match_classes-->marker) ~= -i)) marker++;
        k = match_list-->marker;

        if (match_classes-->marker > 0) print (the) k; else print (a) k;

        if (i < j-1)  print (string) COMMA__TX;
        if (i == j-1) {
			#Ifdef SERIAL_COMMA;
			print ",";
        	#Endif; ! SERIAL_COMMA
        	print (string) OR__TX;
        }
    }
    L__M(##Miscellany, 57);

	.SkipWhichQuestion; EndActivity(ASKING_WHICH_DO_YOU_MEAN_ACT);

	rfalse; !infsp MultiP; interrumpir flujo de pregunat para desambiguar. Devuelve false

    ! ...and get an answer:

  .WhichOne;
    #Ifdef TARGET_ZCODE;
    for (i=2 : i<INPUT_BUFFER_LEN : i++) buffer2->i = ' ';
    #Endif; ! TARGET_ZCODE
    answer_words=Keyboard(buffer2, parse2);

    ! Check for another player's command or a system command [Guncho]
    if (IsOtherCommand(buffer2)) {
        VM_CopyBuffer(buffer, buffer2);
        jump RECONSTRUCT_INPUT;
    }![/Guncho]

    ! Conveniently, parse2-->1 is the first word in both ZCODE and GLULX.
    first_word = (parse2-->1);

    ! Take care of "all", because that does something too clever here to do
    ! later on:

    if (first_word == ALL1__WD or ALL2__WD or ALL3__WD or ALL4__WD or ALL5__WD) {
        if (context == MULTI_TOKEN or MULTIHELD_TOKEN or MULTIEXCEPT_TOKEN or MULTIINSIDE_TOKEN) {
            l = multiple_object-->0;
            for (i=0 : i<number_matched && l+i<MATCH_LIST_WORDS : i++) {
                k = match_list-->i;
                multiple_object-->(i+1+l) = k;
            }
            multiple_object-->0 = i+l;
            rtrue;
        }
        L__M(##Miscellany, 47);
        jump WhichOne;
    }

    ! If the first word of the reply can be interpreted as a verb, then
    ! assume that the player has ignored the question and given a new
    ! command altogether.
    ! (This is one time when it's convenient that the directions are
    ! not themselves verbs - thus, "north" as a reply to "Which, the north
    ! or south door" is not treated as a fresh command but as an answer.)

    #Ifdef LanguageIsVerb;
    if (first_word == 0) {
        j = wn; first_word = LanguageIsVerb(buffer2, parse2, 1); wn = j;
    }
    #Endif; ! LanguageIsVerb
    if (first_word ~= 0) {
        j = first_word->#dict_par1;
        if ((0 ~= j&1) && ~~LanguageVerbMayBeName(first_word)) {
            VM_CopyBuffer(buffer, buffer2);
            jump RECONSTRUCT_INPUT;
        }
    }

    ! Now we insert the answer into the original typed command, as
    ! words additionally describing the same object
    ! (eg, > take red button
    !      Which one, ...
    !      > music
    ! becomes "take music red button".  The parser will thus have three
    ! words to work from next time, not two.)

    #Ifdef TARGET_ZCODE;
    k = WordAddress(match_from) - buffer; l=buffer2->1+1;
    for (j=buffer + buffer->0 - 1 : j>=buffer+k+l : j-- ) j->0 = 0->(j-l);
    for (i=0 : i<l : i++) buffer->(k+i) = buffer2->(2+i);
    buffer->(k+l-1) = ' ';
    buffer->1 = buffer->1 + l;
    if (buffer->1 >= (buffer->0 - 1)) buffer->1 = buffer->0;
    #Ifnot; ! TARGET_GLULX
    k = WordAddress(match_from) - buffer;
    l = (buffer2-->0) + 1;
    for (j=buffer+INPUT_BUFFER_LEN-1 : j>=buffer+k+l : j-- )   j->0 = j->(-l);
    for (i=0 : i<l : i++) buffer->(k+i) = buffer2->(WORDSIZE+i);
    buffer->(k+l-1) = ' ';
    buffer-->0 = buffer-->0 + l;
    if (buffer-->0 > (INPUT_BUFFER_LEN-WORDSIZE)) buffer-->0 = (INPUT_BUFFER_LEN-WORDSIZE);
    #Endif; ! TARGET_

    ! Having reconstructed the input, we warn the parser accordingly
    ! and get out.

	.RECONSTRUCT_INPUT;

	num_words = WordCount();
    wn = 1;
    #Ifdef LanguageToInformese;
    LanguageToInformese();
    ! Re-tokenise:
    VM_Tokenise(buffer,parse);
    #Endif; ! LanguageToInformese
	num_words = WordCount();
    players_command = 100 + WordCount();
	FollowRulebook(Activity_after_rulebooks-->READING_A_COMMAND_ACT, true);

    return REPARSE_CODE;

    ! Now we come to the question asked when the input has run out
    ! and can't easily be guessed (eg, the player typed "take" and there
    ! were plenty of things which might have been meant).

  .Incomplete;

    if (context == CREATURE_TOKEN) L__M(##Miscellany, 48);
    else                           L__M(##Miscellany, 49);


    #Ifdef TARGET_ZCODE;
    for (i=2 : i<INPUT_BUFFER_LEN : i++) buffer2->i=' ';
    #Endif; ! TARGET_ZCODE
!    DisambigMode(); ! Guncho
    answer_words = Keyboard(buffer2, parse2);

    ! Check for another player's command or a system command - Guncho
    if (IsOtherCommand(buffer2)) {
        VM_CopyBuffer(buffer, buffer2);
        jump RECONSTRUCT_INPUT;
    }

    first_word=(parse2-->1);
    #Ifdef LanguageIsVerb;
    if (first_word==0) {
        j = wn; first_word=LanguageIsVerb(buffer2, parse2, 1); wn = j;
    }
    #Endif; ! LanguageIsVerb

    ! Once again, if the reply looks like a command, give it to the
    ! parser to get on with and forget about the question...

    if (first_word ~= 0) {
        j = first_word->#dict_par1;
        if (0 ~= j&1) {
            VM_CopyBuffer(buffer, buffer2);
            return REPARSE_CODE;
        }
    }

    ! ...but if we have a genuine answer, then:
    !
    ! (1) we must glue in text suitable for anything that's been inferred.

    if (inferfrom ~= 0) {
        for (j=inferfrom : j<pcount : j++) {
            if (pattern-->j == PATTERN_NULL) continue;
            #Ifdef TARGET_ZCODE;
            i = 2+buffer->1; (buffer->1)++; buffer->(i++) = ' ';
            #Ifnot; ! TARGET_GLULX
            i = WORDSIZE + buffer-->0;
            (buffer-->0)++; buffer->(i++) = ' ';
            #Endif; ! TARGET_

            #Ifdef DEBUG;
            if (parser_trace >= 5)
            	print "[Gluing in inference with pattern code ", pattern-->j, "]^";
            #Endif; ! DEBUG

            ! Conveniently, parse2-->1 is the first word in both ZCODE and GLULX.

            parse2-->1 = 0;

            ! An inferred object.  Best we can do is glue in a pronoun.
            ! (This is imperfect, but it's very seldom needed anyway.)

            if (pattern-->j >= 2 && pattern-->j < REPARSE_CODE) {
                PronounNotice(pattern-->j);
                for (k=1 : k<=LanguagePronouns-->0 : k=k+3)
                    if (pattern-->j == LanguagePronouns-->(k+2)) {
                        parse2-->1 = LanguagePronouns-->k;
                        #Ifdef DEBUG;
                        if (parser_trace >= 5)
                        	print "[Using pronoun '", (address) parse2-->1, "']^";
                        #Endif; ! DEBUG
                        break;
                    }
            }
            else {
                ! An inferred preposition.
                parse2-->1 = VM_NumberToDictionaryAddress(pattern-->j - REPARSE_CODE);
                #Ifdef DEBUG;
                if (parser_trace >= 5)
                	print "[Using preposition '", (address) parse2-->1, "']^";
                #Endif; ! DEBUG
            }

            ! parse2-->1 now holds the dictionary address of the word to glue in.

            if (parse2-->1 ~= 0) {
                k = buffer + i;
                #Ifdef TARGET_ZCODE;
                @output_stream 3 k;
                 print (address) parse2-->1;
                @output_stream -3;
                k = k-->0;
                for (l=i : l<i+k : l++) buffer->l = buffer->(l+2);
                i = i + k; buffer->1 = i-2;
                #Ifnot; ! TARGET_GLULX
                k = Glulx_PrintAnyToArray(buffer+i, INPUT_BUFFER_LEN-i, parse2-->1);
                i = i + k; buffer-->0 = i - WORDSIZE;
                #Endif; ! TARGET_
            }
        }
    }

    ! (2) we must glue the newly-typed text onto the end.

    #Ifdef TARGET_ZCODE;
    i = 2+buffer->1; (buffer->1)++; buffer->(i++) = ' ';
    for (j=0 : j<buffer2->1 : i++,j++) {
        buffer->i = buffer2->(j+2);
        (buffer->1)++;
        if (buffer->1 == INPUT_BUFFER_LEN) break;
    }
    #Ifnot; ! TARGET_GLULX
    i = WORDSIZE + buffer-->0;
    (buffer-->0)++; buffer->(i++) = ' ';
    for (j=0 : j<buffer2-->0 : i++,j++) {
        buffer->i = buffer2->(j+WORDSIZE);
        (buffer-->0)++;
        if (buffer-->0 == INPUT_BUFFER_LEN) break;
    }
    #Endif; ! TARGET_

    ! (3) we fill up the buffer with spaces, which is unnecessary, but may
    !     help incorrectly-written interpreters to cope.

    #Ifdef TARGET_ZCODE;
    for (: i<INPUT_BUFFER_LEN : i++) buffer->i = ' ';
    #Endif; ! TARGET_ZCODE

    return REPARSE_CODE;

]; ! end of NounDomain

-) instead of "Noun Domain" in "Parser.i6t".

Include (-
[ DisambigMode  i end c;
	print "[$d ";

	i = WordAddress(1) - buffer;
	#ifdef TARGET_ZCODE;
	end = WORDSIZE + buffer->1;
	#ifnot;
	end = WORDSIZE + buffer-->0;
	#endif;
	for (: i<end: i++) {
		c = buffer->i;
		if (c ~= '>') print (char) c;
	}

	print "]";
];

[ IsOtherCommand buf  i end c;
	! if it starts with a dollar sign...
	if (buf->WORDSIZE == '$') rtrue;

	#ifdef TARGET_ZCODE;
	end = WORDSIZE + buf->1;
	#ifnot;
	end = WORDSIZE + buf-->0;
	#endif;

	! if it starts with digits and then a colon...
	for (i = WORDSIZE: i<end: i++) {
		c = buf->i;
		if (c == ':' && i > WORDSIZE) rtrue;
		else if (c < '0' || c > '9') rfalse;
	}

	rfalse;
];
-).

Chapter 3 - "WorldModel" segment

[ChangePlayer: Set spanish pronoums slots correctly]

Include (-
[ ChangePlayer obj  pn;
    if (~~(obj ofclass K8_person)) return RunTimeProblem(RTP_CANTCHANGE, obj);
    if (~~(OnStage(obj, -1))) return RunTimeProblem(RTP_CANTCHANGEOFFSTAGE, obj);
    if (obj == player) return;
! guncho zone: set pronouns correctly
    if (player ofclass i7_pc_kind) {
        pn = player.&pronouns;
!        pn-->0 = PronounValue('him');
!        pn-->1 = PronounValue('her');
!        pn-->2 = PronounValue('it');
!        pn-->3 = PronounValue('them');
        pn-->0 = PronounValue('-lo');
        pn-->1 = PronounValue('-los');
        pn-->2 = PronounValue('-la');
        pn-->3 = PronounValue('-las');
    }
    if (obj ofclass i7_pc_kind) {
        pn = obj.&pronouns;
!        SetPronoun('him', pn-->0);
!        SetPronoun('her', pn-->1);
!        SetPronoun('it', pn-->2);
!        SetPronoun('them', pn-->3);
	SetPronoun('-lo', pn-->0);
	SetPronoun('-los', pn-->1);
	SetPronoun('-la', pn-->2);
	SetPronoun('-las', pn-->3);
    }
! guncho zone

    give player ~concealed;
    ! if (player has remove_proper) give player ~proper;
    if (player == selfobj) {
    	player.saved_short_name = player.short_name; player.short_name = FORMER__TX;
    }
    player = obj;
    if (player == selfobj) {
    	player.short_name = player.saved_short_name;
    }
    ! if (player hasnt proper) give player remove_proper; ! when changing out again
    ! give player concealed proper;
    give player concealed;

    location = LocationOf(player); real_location = location;
    MoveFloatingObjects();
    SilentlyConsiderLight();
];
-) instead of "Changing the Player" in "WorldModel.i6t".

Chapter 4 - "Printing" segment

Include (-
Replace CDefArt;
-) after "Definitions.i6t". 

[CDefArt: no se tiene en cuenta player]
Include (-
[ CDefArt obj i;
    i = indef_mode; indef_mode = false;
    if ((obj ofclass Object) && (obj has proper)) {
    	indef_mode = NULL;
    	caps_mode = true;
    	print (PSN__) obj;
    	indef_mode = i;
    	caps_mode = false;
    	return;
    }
    if ((~~obj ofclass Object) || obj has proper) {
        indef_mode = NULL; print (PSN__) obj; indef_mode = i;
        return;
    }
    PrefaceByArticle(obj, 0); indef_mode = i;
];

-) after "Object Names III" in "Printing.i6t".

Chapter 7 - "Actions" segment

[Evitar dar ordenes a otros jugadores]
Include (-
[ REQUESTED_ACTIONS_REQUIRE_R;
	if ((actor ~= player) && (act_requester)) { ! guncho
		if (actor ofclass i7_pc_kind) {
!			print "You can't order other players.^";
			print "No puedes dar ordenes a otros jugadores.^";
			RulebookFails(); rtrue;
		}! /guncho
		@push say__p;
		say__p = 0;
		ProcessRulebook(PERSUADE_RB);
		if (RulebookSucceeded() == false) {
			if (say__p == FALSE) L__M(##Miscellany, 72, actor);
			RulebookFails(); rtrue;
		}
		@pull say__p;
	}
	rfalse;
];
-) instead of "Requested Actions Require Persuasion Rule" in "Actions.i6t".

After asking which do you mean: say "(Debes re-escribir la orden COMPLETA.)";woff.


Part 6 - Spanish Section

[Part 2 - Player characters]

Chapter 1 - The PC kind

The list PC possessions after examining rule is not listed in any rulebook.
After examining a PC (this is the spanish list PC possessions after examining rule):
    if the noun is wearing something, say "[The noun] viste [a list of things worn by the noun].";
    if the noun is carrying something, say "[The noun] lleva [a list of things carried by the noun]."

Chapter 2 - Player commands

Section 1 - Game engine metacommands

[Section 1 - Joining]

A player joining rule for a PC (called newbie) (this is the spanish announce PC connection rule):
[	let waygone be the waygone of the current PC;
	let dir be the direction known as waygone;
	let msg be indexed text;
	if dir is a direction, let msg be "[The newbie] aparece desde [directional opposite of dir].";
	otherwise let msg be "[The newbie] aparece de la nada.";]
	announce "[The newbie] se ha conectado.";
	tell "[The newbie] aparece de la nada." to everyone else near the current PC.

[The spanish announce PC connection rule is listed instead of the english announce PC connection rule in the player joining rules.]
The announce PC connection rule is not listed in the player joining rules.

[TODO: esto podria no hacer falta y trabajar directamente con los printed name?]
To say directional opposite of (dir - a direction): [spanish overload]
    if dir is up begin;
        say "arriba";
    otherwise if dir is down;
        say "abajo";
    otherwise;
        say the opposite of dir;
    end if.

[Section 2 - Leaving]


A player leaving rule for a PC (called the goner) (this is the spanish drop possessions when leaving rule):
	if the goner has something begin;
		let msg be indexed text;
		let msg be "Al salir del reino, dejas [the list of things had by the goner].";
		tell msg to the goner;
		let msg be "[The goner] deja [a list of things had by the goner].";
		tell msg to everyone else near the goner;
		now everything had by the goner is in the location of the goner;
	end if.

[The spanish drop possessions when leaving rule is listed instead of the drop possessions when leaving rule in the player leaving rules.]
The drop possessions when leaving rule is not listed in the player leaving rules.


A player leaving rule for a PC (called the goner) (this is the spanish announce PC disconnection rule):
[	let waygone be the waygone of the goner;
	let dir be the direction known as waygone;
	if dir is a direction, tell "[The goner] desaparece [motion toward dir]." to everyone else near the goner;
	otherwise tell "[The goner] desaparece en la nada." to everyone else near the goner.]
	tell "Hasta otra! Feliz aventura!" to the goner;
	tell "[The goner] desaparece en la nada." to everyone else near the goner;
	announce "[The goner] se ha desconectado.".

[The spanish announce PC disconnection rule is listed instead of the announce PC disconnection rule in the player leaving rules.]
The announce PC disconnection rule is not listed in the player leaving rules.

To say motion toward (dir - a direction):[spanish overload]
    if dir is up begin;
        say "por arriba";
    otherwise if dir is down;
        say "por abajo";
    otherwise;
        say "por [the dir]";
    end if.

To send (X - a thing) home:[spanish overload]
	tell "[The X] desaparece." to everyone who can see X;
	move X to the object-home of X;
	tell "[The X] aparece." to everyone who can see X.


Section 2 - Chat commands

Instead of asking the noun about something (this is the spanish standard chatting rule):
	tell "Dices a [noun], '[topic understood]'" to the player;
[	tell "[The player] te dice, '[topic understood]'" to everyone else near the player.]
	if the noun is not the player, tell "[The player] te dice, '[topic understood]'" to the noun.

The standard chatting rule is not listed in any rulebook.


Chapter 3 - Modified Inform actions


This is the spanish other people looking rule:
[	say "spanish other people for [the actor]."; [debug]]
	if the actor is not the player and the actor is not a PC, say "[The actor] mira alrededor."

The spanish other people looking rule is listed instead of the new other people looking rule in the report looking rules.

This is the spanish other people examining rule:
	if the actor is not the player and the actor is not a PC, say "[The actor] examina [the noun]."

The spanish other people examining rule is listed instead of the new other people examining rule in the report examining rulebook.

The standard report thinking rule is not listed in any rulebook.
Report thinking (this is the spanish standard report thinking rule):
	say "Contemplas la situación."

The standard report someone thinking rule is not listed in any rulebook.
Report someone thinking (this is the spanish standard report someone thinking rule):
	say "[The actor] pausa un momento, sumido en sus pensamientos."


The standard report waving hands rule is not listed in any rulebook.
Report waving hands (this is the spanish standard report waving hands rule):
	say "Saludas."

The standard report someone waving hands rule is not listed in any rulebook.
Report an actor waving hands when the actor is not the player (this is the spanish standard report someone waving hands rule):
	say "[The actor] saluda ridículamente..."


[Report someone waving hands (this is the spanish report someone waving rule):
	say "[The actor] saluda."]

The standard report smelling rule is not listed in any rulebook.
Report smelling (this is the spanish standard report smelling rule):
	say "No hueles nada extraño."

The standard report someone smelling rule is not listed in any rulebook.
Report someone smelling (this is the spanish standard report someone smelling rule):
	say "[The actor][if the noun is the player] te huele[otherwise if the noun is not the location] huele [the noun][end if]."

The standard report listening rule is not listed in any rulebook.
Report listening (this is the spanish standard report listening rule):
	say "No escuchas nada fuera de lo común."

The standard report someone listening rule is not listed in any rulebook.
Report someone listening (this is the spanish standard report someone listening rule):
	say "[The actor][if the noun is the player] te escucha[otherwise if the noun is not the location] escucha [the noun][end if]."

The standard report tasting rule is not listed in any rulebook.
Report tasting (this is the spanish standard report tasting rule): 
	say "No saboreas nada inesperado."

The standard report someone tasting rule is not listed in any rulebook.
Report someone tasting (this is the spanish standard report someone tasting rule):
	say "[The actor][if the noun is the player] te lame[otherwise] saborea [the noun][end if]."

The standard report jumping rule is not listed in any rulebook.
Report jumping (this is the spanish standard report jumping rule):
	say "Saltas en el sitio, sin ningún resultado."

The standard report someone jumping rule is not listed in any rulebook.
Report someone jumping (this is the spanish standard report someone jumping rule):
	say "[The actor] salta."

The block rubbing people rule is not listed in any rulebook.
Check an actor rubbing a person (this is the spanish block rubbing people rule):
	if the actor is the player, say "Eso es un poco mal educado." instead;
	stop the action.

The standard report rubbing rule is not listed in any rulebook.
Report rubbing (this is the spanish standard report rubbing rule):
	say "No lograrás nada así."

The standard report someone rubbing rule is not listed in any rulebook.
Report someone rubbing (this is the spanish standard report someone rubbing rule):
	say "[The actor] frota [the noun]." instead. 

The standard report singing rule is not listed in any rulebook.
Report singing (this is the spanish standard report singing rule):
	say "Cantas una bonita melodía."

The standard report someone singing rule is not listed in any rulebook.
Report someone singing (this is the spanish standard report someone singing rule):
	say "[The actor] tortura tus oídos con una desentonada melodía."


The block saving rule is not listed in any rulebook.
Check saving the game (this is the spanish block saving rule):
    say "No puedes salvar el estado del juego." instead.

The block restoring rule is not listed in any rulebook.
Check restoring the game (this is the spanish block restoring rule):
    say "No puedes recuperar una partida." instead.

The block restarting rule is not listed in any rulebook.
Check restarting the game (this is the spanish block restarting rule):
    say "No puedes reiniciar." instead.

The block transcript on rule is not listed in any rulebook.
Check switching the story transcript on (this is the spanish block transcript on rule):
    say "No puedes iniciar una transcripción en este juego." instead.

The block transcript off rule is not listed in any rulebook.
Check switching the story transcript off (this is the spanish block transcript off rule):
    say "Las transcripiones no están permitidas." instead.

The block superbrief rule is not listed in any rulebook.
Check preferring abbreviated room descriptions (this is the spanish block superbrief rule):
    say "No se puede cambiar el modo de descripción de localidades." instead.

The block verbose rule is not listed in any rulebook.
Check preferring unabbreviated room descriptions (this is the spanish block verbose rule):
    say "No se puede cambiar el modo de descripción de localidades." instead.

The block brief rule is not listed in any rulebook.
Check preferring sometimes abbreviated room descriptions (this is the spanish block brief rule):
    say "No se puede cambiar el modo de descripción de localidades." instead.

The block notify on rule is not listed in any rulebook.
Check switching score notification on (this is the spanish block notify on rule):
    say "No se puede cambiar las opciones de puntuación." instead.

The block notify off rule is not listed in any rulebook.
Check switching score notification off (this is the spanish block notify off rule):
    say "No se puede cambiar las opciones de puntuación." instead.

Understand "undo" as a mistake ("Lo lamento, undo no está permitido.").
Understand "oops" as a mistake ("No te preocupes.").
Understand "oops [text]" as a mistake ("Lo siento, no puedes corregir ordenes previas.").


Chapter 4 - Player interactions

Section 1 - Giving items to other players

Understand the command "acepta" as "accept".

The standard report offering rule is not listed in any rulebook.
Report offering it to (this is the spanish standard report offering rule):
	say "Le ofreces [the noun] a [the second noun]."

The standard report someone offering rule is not listed in any rulebook.
Report someone offering (this is the spanish standard report someone offering rule):
	if the second noun is the player, say "[The actor] te ofrece [a noun]. (Para aceptar, escribe 'aceptar [the noun]'.)";
	otherwise say "[The actor] ofrece [the noun] a [the second noun]."

The block accepting people rule is not listed in any rulebook.
Check accepting a person (this is the spanish block accepting people rule):
	say "Decides aceptar[if the noun is the player]te[otherwise] [the noun][end if] como una persona, con errores y todo." instead.

The can't accept what's not offered rule is not listed in any rulebook.
Check accepting something (this is the spanish can't accept what's not offered rule):
	if the noun is not offered to the player, say "Nadie te ofreció nada." instead.

The standard report accepting rule is not listed in any rulebook.
Report accepting something (this is the spanish standard report accepting rule):
	say "Aceptas [the noun][if the person offering is a person] de [the person offering][end if]."

The standard report someone accepting rule is not listed in any rulebook.
Report someone accepting something (this is the spanish standard report someone accepting rule):
	say "[The actor] acepta [the noun][if the person offering is the player] de parte tuya[otherwise if the person offering is a person] de parte de [the person offering][end if]."

Section 2 - Showing items to other players

The standard report showing rule is not listed in any rulebook.
Report showing something to someone (this is the spanish standard report showing rule):
    say "Exhibes [the noun] para que [the second noun] pueda verlo."

The standard report someone showing rule is not listed in any rulebook.
Report someone showing something to someone (this is the spanish standard report someone showing rule):
	say "[The actor] exhibe [the noun] para que ";
	if the second noun is the player
	begin;
		say "puedas verlo. [run paragraph on]"; 
		try examining the noun;
	otherwise;
		say "[the second noun] pueda verlo.";
	end if.



Multi P ends here.

---- Documentation ----

Chapter: Abstracto

Esta extension está pensada para permitir el 'efecto multiplayer' en juegos compilados para Glulx.
Crea una cantidad de objetos jugadores llamados PC y los va asignando a los jugadores reales a medida que van 'entrando' al juego (luego de pasar por un 'Recibidor').
Ante cada acción, se encarga de avisar sus efectos a los demás.
La entrada y salida del texto del juego sigue una sintaxis especial (me gusta llamarla 'protoclo FloydZX'), para poder comunicarse con una aplicación capaz de manejar conexiones de red y despachar los mensajes a cada jugador remoto; como por ejemplo Rebot.

Puedes ejecutar la aventura en un intérprete común (como WinGlulxe o Gargoyle), pero verás los mensajes envueltos en etiquetas especiales, además de que cómo demonios vas a jugar un multiplayer así?!?!?


Chapter: Conceptos 

Section: La aventura Mínima

Con solo una habitación, ya puedes tener una aventura minima multiplayer.
Ten en cuenta de setear a Glulx antes de compilar (para todas las aventuras multiplayer será asi).
Lo que debes indicar es dónde comenzarán la aventuras los jugadores que ingresen al juego.
Esto lo indicas con la variable Initial Room.

	The Initial Room is Hall Central.

(Ver el resto del código en la sección Ejemplos)

Section: Arranque de la aventura

Cuando ejecutes la aventura, no comenzará en la Initial Room que has puesto, sino más bien en un Recibidor especial.
	Recibidor
	Bienvenido al recibidor del juego. Para entrar escribe "jugar como tu_nombre". Ej: jugar como Sancho.

Cada nuevo jugador que se conecte a Rebot, recibirá esta invitación. De esa manera podrá ponerle nombre al personaje que la aventura va a asignarle; antes de entrar a la aventura propiamente dicha. Por ejemplo, el jugador puede escribir:

	jugar como Grendel

Luego de procesar el comando, la aventura asignará un objeto PC al nuevo jugador, le asignará el nombre dado (Grendel) y lo pondrá en la Initial Room. Esta extensión se encarga de toda esa faena.
Nota: Si intentas escribir este comando en la pestaña Game del IDE, verás que no lo reconoce. ¿Por qué? Sigue leyendo...

Section: Protocolo FloydZX

Se trata de una sintaxis especial que hay que usar para comunicarse con la aventura. Pero no te asustes. Programas tales como Rebot implementan este protoclo y lo hacen de manera transparente o invisible para los jugadores (o sea: ni se enteran).
Conviene que lo sepas, solo para hacer pruebas en la pestaña Game del IDE de I7.

El protocolo se define asi:

Ingreso de comandos a la aventura:
	id de usuario, comando

	ej: nicko.gmail.com, jugar como Grendel

El id de usuario es un valor interno con que Rebot y la aventura identifican al jugador remoto. Es alfanumerico y puede contener puntos.

Salida de texto de la aventura:
	<whisper id de usuario>
	salida de texto de la aventura
	</whisper>

	<whisper nicko.gmail.com>
	Hall Central
	Un amplio hall, parece que aquí se baila por las noches.
	</whisper>

La salida siempre está envueta en las etiquetas 'whisper'.

Para hacer pruebas en el IDE de I7; debes inventarte un id para cada jugador.
	sa, jugar como Presi
	te, jugar como Grendel
	me, jugar como Sarganar

Section:  Tipos de juegos multiplayer

Con esta extensión pueden abordarse distintas ópticas de juegos multiplayer :

* Genérico:
Se trata de un mapeado con puzzles. Los jugadores son personajes genéricos de la aventura (o genéricos pero de diferentes clases) . Ej: algunos muds

* Especifico:
La aventura esta guionada y pensada en personajes, como una obra de teatro. Por ejemplo: una historia que necesite 6 personajes. Cada jugador encarna uno de ellos. No se admite un 7mo jugador. Ej: Multivamp, donde puedes tomar el rol de Irelda o de Von Kaufman.

* Party Game:
La historia se centra en la peña que se junta para jugarla, para echarse unas risas. Son adaptaciones de juegos de mesa y consiste en una sola habitación. Ej: Lobos y aldeanos o Mafia.


Chapter: Codificando

Section: La Clase PC

Todos los jugadores pertenecen a una clase llamada "PC", que a su vez deriva de la clase "person" de Inform. Cada PC tiene una propiedad de texto llamada mud-name, que almacena el nombre del jugador que lo controla.

Esta librería viene con un número fijo de PCs disponibles (25 por defecto, puede ampliarse o reducirse antes de compilar la aventura). Cuando no se utilizan, están guardados en un contenedor especial llamado PC-corral. Los adjetivos connected y disconnected se pueden usar para verificar si un PC está en uso. Por ejemplo, podrías averiguar la cantidad de PCs conectados con:

	... the number of connected PCs ...

o
	
	if at least two PCs are connected, ...

o

	repeat with X running through connected PCs ...

Si todos los PCs de tu reino (tu aventura) se encuentran "connected", el reino está lleno y nadie más puede entrar.
Cuando todos se desconectan, la aventura no termina. Es un mundo persistente que se quedará a la espera de nuevos jugadores.
Salvo que el autor diga lo contrario, claro. Por ejemplo, en MultiVamp, cuando todos los jugadores salen, la aventura se reinicia.

Section: Ingreso y egreso de jugadores

Para reaccionar ante una salida o entrada de jugadores a tu reino, puedes utilizar los rulebooks:
	player joining
	player leaving

El jugador 'entra' a la aventura luego de que pasó por el Recibidor; y sale de la aventura cuando da la orden 'quit' o cuando se desconecta remotamente.
Toma nota de que el PC actual ya está conectado al momento de ejecutarse las player joining rules para ese PC; y que también continúa conectado al ejecutarse sus player leaving rules. Para saber si el PC que se ha desconectado era el último , usa el código siguiente:

	A player leaving rule: if exactly one PC is connected,...


Section: Reporte de Acciones

Las acciones de fábrica de Inform vienen con reglas de Reporte para PNJs, como se describen en el manual de I7 (12.13, Report rules for actions by other people). La libreria Multi P ejecuta automáticamente las reglas de reporte para PJ y PNJ todas las veces que haga falta, enviando el texto de salida a cada jugador que observa la acción.

Entonces, si tu defines nuevas acciones, la manera más fácil de hacerlo (bien) es asegurarse de escribir tanto reglas de reporte tipo "Report dancing" (para la persona que ejecuta la accion) como también tipo "Report someone dancing" (para cualquier otro que esté observando la acción). Esto es en general una buena practica en Inform, incluso si tienes pensado incluir PNJs en tu juego.

Nota: Las reglas de reporte deben usar "say" para imprimir, no "tell". Así el texto automáticamente será enviado a los jugadores pertinentes.

Ej:
	Report jumping (this is the spanish standard report jumping rule):
		say "Saltas en el sitio, sin ningún resultado."

	Report someone jumping (this is the spanish standard report someone jumping rule):
		say "[The actor] salta."


Section: "Say" vs. "tell", y "announce"

La frase "say" de Inform hace exactamente lo que esperas de ella durante el proceso de las reglas de acciones: envía texto a quien se supone que ejecuta la acción, y en el caso de las reglas de reporte para NPCs, a cualquiera que observe la acción.

Good! Sin embargo, debido a la intromición interna de Multi P, fuera de las reglas de acciones, "say" no tendrá ningún efecto, y cualquier texto que tu imprimas con ella será descartado. En su lugar necesitarás usar una de las "tell" phrases para decirle a Rebot exactamente a qué jugadores quieres enviarle el texto.

Si tenemos la variable X apuntando a un PC:
	tell "Nadie saldrá vivo de aquí." to X

Un mensaje para todos los PC cercanos a X (en la misma localidad):
	tell "Sientes que hay un traidor en el grupo" to everyone else near X

Un mensaje para todos los PC cercanos al objeto espada (en la misma localidad):
	tell "La espada taiwanesa se evapora como si nada" to everyone who can see the espada

Igual que el anterior, pero saltándose al actor actual.
	tell "La manzana no está madura." to everyone who can see the manzana except the actor

Un mensaje para todos los jugadores, sin importar dónde estén:
	announce "Todos a casa. No hay nada que ver aquí."


Section: Comandos Utiles

Esta extensión implemeta los siguientes comandos:

*especial: Para entrar al juego:
	jugar como Grendel

Solo es válido en el Recibidor.


*todos: para hablar a los personajes de las cercanías:
	todos hola cómo les va?

*emo: para emocion:
	emo llora al ver semejante inteligencia

Esto les mostrará a todos en la misma localidad el texto
	sarganar llora al ver semejante inteligencia

*quit: para salir del juego (no matar el programa...)
	quit

Con este comando, la aventura ejecutará la rulebook player leaving y -entre otras cosas-  'limpiará' el PC de ese personaje y lo devolerá al PC-Corral.

*abortar este juego: para matar el programa.
	abortar este juego

Eso cierra la aventura. Rebot queda funcionando en Modo Comando (sin aventura cargada). Creo que te das cuenta de que este comando es delicadillo.

*Para hablar puedes usar los tipicos comandos de Inform:
	jenesis, dónde está Presi
	di a jenesis dónde está Presi

Recuerda: si usas la sintaxis "personaje, texto"; ten en cuenta que Inform puede interpretarlo como una orden a un personaje no jugador (si logra parsear el texto como una orden).

*listado de los conectados:
	quien

Presentará los personajes conectados a la aventura.

*ayuda: Muestra una breve ayuda
	ayuda

Mostrará la mayoria de los comandos aquí descriptos. Si quieres agregar mas texto a ese mensaje (quizas porque tu aventura implementa un par de comandos más), puedes hacerlo mediante la phrase "say other helpies":

	To say other helpies:
		say " - Para datos y usos de un objeto: hint objeto."

Si agregas ese código en tu aventura, el texto se mostrará junto con el texto de ayuda original.


Section: Personajes no jugadores (PNJs)

La extension Multi P no hace nada especial con ellos. Puedes usar el código Inform normal (segun el manual) para PNJs.
Deberian funcionar bien.

Section: Ganar o Perder

No yet implemented.

Section: Limitaciones de Meta Comandos

La aventura no te dejará salvar o recuperar partidas, reiniciar, hacer undo o habilitar transcripción.
Cosas nada saludables para un juego multiplayer en máquina Glulx.

Chapter: Frases disponibles

Section: To polite reject player command

En el contexto del Recibidor, se puede usar para personalizar texto para comandos no admitidos en el Recibidor. Por defecto la aventura te dirá:
	Estás en el recibidor del juego. Para entrar escribe 'jugar como mi_nombre'.

Pero se puede poner otro mensaje, redefiniendo la phrase.
ej:
	To polite reject player command: 
		say "[The description of Recibidor]".[* simplemente que vuelva a imprimir el texto explicativo]

En el momento apropiado, la aventura llamará a dicha frase y se imprimirá el texto personalizado.

Section: To cleanup (X - a PC)

Devuelve el PC indicado al corral. Usado en aventuras con personaje reservado, como MultiVamp. Para las aventuras genéricas no es necesario.

Ej:

	A first player joining rule (this is the check right character name rule):
		if the current PC is unreserved begin;
			tell "En este juego solo puedes ser Irelda o Kaufman." to the current PC;
			cleanup the current PC;[* devolver PC al corral]
			rule fails; [* detener todo el proceso del rulebook join]
		end if.


Section: To transfer (character - a PC) to (destiny - a room)

Mueve al jugador-personaje a otra habitación.

Ej:

	if Irelda is connected and Kaufman is connected begin;
		if Irelda is in Hall de espera, transfer Irelda to the Vestibulo;
		if Kaufman is in Hall de espera, transfer Kaufman to the Vestibulo;
	end if.


Chapter: Agradecimientos

A vaporware, por dejarme re-utilizar parte de codigo usado en Guncho.
A Presi, por su genial Rebot.
A Grendel, por motivarme a terminar esta extensión.
A los testers ocasionales del IRC (Jenesis, Al-K, Netskaven, etc.)

Section: Contacto
	
	Foro: www caad es/foro
	Main Developer: Sarganar

	Feedbacks: sarganar (at) gmail (dot) com


Example: *	Aventura Minima - Una pequeña demo multiplayer con una habitacion llamada Hall Central.

	*: "Aventura Minima"

	Include Spanish by Sebastian Arg.
	Include Multi P by Sarganar.

	The Initial Room is Hall Central.

	Hall Central is a Room. "Un amplio hall, parece que aquí se baila por las noches."



Example: *	Aventura Minima II - Una pequeña demo multiplayer con una habitacion llamada Hall Central. Esta vez personalizamos algo del texto del Recibidor.

	*: "Aventura Minima"

	Include Spanish by Sebastian Arg.
	Include Multi P by Sarganar.

	The Initial Room is Hall Central.

	Hall Central is a Room. "Un amplio hall, parece que aquí se baila por las noches."
	The description of Recibidor is "Multimaze, el laberinto final. [line break]Bienvenido al recibidor de Multimaze. Para entrar escribe 'jugar como tu_nombre'. Ej: jugar como Naills." The printed name of Recibidor is "Multimaze Welcome Hall".


Example: **	MultiVamp - Vampiro Multiplayer. Una pequeña demo de una aventura específica, es decir, con jugadores reservados.

	*:"Multivamp"

	Consulta su codigo en www.caad.es/informate/infsp/MultiVamp


