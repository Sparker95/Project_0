#include "defineCommon.inc"

/*
    By: Jeroen Notenbomer

    Create dialogue based on given conversation ID.

	Input:
		_unit_1:
		_unit_2(optional): 
		_conversation_id: The id of the conversation you want to start
	Output:
		nil
*/

#define INT_ID_UNDEFINED -1
#define INT_ID_WALKED_AWAY -2
#define INT_ID_OUT_OF_TIME -3
#define INT_ID_UNIT_KILLED -4


params[["_unit_1",objNull,[objNull]],["_unit_2",objNull,[objNull]],["_conversation_id","",[""]]];

if(isnull _unit_1)exitWith {diag_log format["ERROR SENTENCE UNIT_1 CANT BE A NONE: %1",_conversation_id]};

private _allPLayers = (Allplayers - entities "HeadlessClient_F");

//player needs to be unit_1
if(_unit_2 in _allPLayers)exitWith{diag_log format["ERROR SENTENCE UNIT_2 CANT BE A PLAYER: %1",_unit_2]};

//run code on client if possible
if(_unit_1 in _allPLayers && { !(_unit_1 isEqualTo player) })then{
	[_unit_1, _unit_2, _conversation_id] remoteExecCall ["pr0_fnc_dialogue_createConversation",_unit_1];
};

_this spawn {
	params[["_unit_1",objNull,[objNull]],["_unit_2",objNull,[objNull]],["_conversation_id","",[""]]];





	//main loop for the conversation
	while{true}do{
	
		//check if both units are alive is dead or unconsious and stup conversation
		if(
			(!alive _unit_1 || {_unit_1 getVariable ["ace_isunconscious",false]}) ||
			{!(isnull _unit_2) && {!alive _unit_2 || _unit_2 getVariable ["ace_isunconscious",false]}} //can be null if talking to no one
		)exitWith{};
	
		private _conversation_script = _conversation_id call pr0_fnc_dialogue_findConversation;//returns {} when not found
		private _conversation_array = [_unit_1,_unit_2] call _conversation_script;
		if(isnil "_conversation_array")exitWith{diag_log format["ERROR SENTENCE ID NOT FOUND: %1",_conversation_id]};
		
		diag_log str["CREATE CONVERSTAION 1", _conversation_array];

		private _sentences = [];
		private _question = "";
		private _options = [];
		private _new_conversation_id = "";
		private _event_walkAway = "#end";
		private _event_outOfTime = "#end";
		{
			_x params ["_type", "_a", "_b","_c"];
			if(isnil "_type" || {!(_type isEqualType 0)})exitWith{diag_log format["ERROR WRONG OR NO TYPE GIVEN FOR: %1 (%2)",_conversation_id]};
			switch (_type) do {
				case TYPE_SENTENCE: {_sentences pushBack [_a,_b,_c]};
				case TYPE_QUESTION: {_question = _a};
				case TYPE_OPTION:   {_options pushBack [_a,_b,_c]};
				case TYPE_JUMP_TO:  {_new_conversation_id = _a};
				case TYPE_EVENT_WALKED_AWAY: 	{_event_walkAway = _a};
				case TYPE_EVENT_OUT_OF_TIME: 	{_event_outOfTime = _a};
				default {};
			};
		}forEach _conversation_array;
		
		//check if conversation is properly structured 
		if((count _sentences + count _question) == 0)exitWith{diag_log format["ERROR NO SENTENCE OR QUESTION: %1 (%2)",_conversation_id]};
		if(count _question > 0 && count _options == 0)exitWith{diag_log format["ERROR NO OPTIONS FOR QUESTION: %1 (%2)",_conversation_id]};

		//select random sentence if array was given
		{
			_x params ["_array"];
			if(_array isEqualType [])then{
				_x set [0, selectRandom _array];
			};
		}forEach _sentences;
		if(_question isEqualType [])then{_question = selectRandom _question};

		//loop all sentences and show them one by one
		{
			_x params [["_sentence","",[""]],["_who",-1,[0]],["_script",{},[{}]]];

			[_unit_1,_unit_2] call _script;//run optional code if it was given

			private _speaker = [_unit_1,_unit_2] select (_who-1);
			private _listener = [_unit_2,_unit_1] select (_who-1);
			
			{
				if(_x distance _speaker < FLOAT_MAX_LISTENING_DISTANCE)then{
					[_speaker, _listener, _sentence] remoteExecCall ["pr0_fnc_dialogue_createSentence",_x];
				};
			}forEach (Allplayers - entities "HeadlessClient_F");
			
			sleep ((count _sentence)/12 + 0.5);
		}foreach _sentences;

		//create question and show it to the player
		if(count _question > 0)then{
		
			disableSerialization;
			private _display = findDisplay 46;
	
			private _speaker = _unit_2;
			private _listener = player;
			
			
			//show the question to all players except player. 
			{
				if(_x distance _speaker < FLOAT_MAX_LISTENING_DISTANCE)then{
					[_speaker, _listener, _question] remoteExecCall ["pr0_fnc_dialogue_createSentence",_x];
				};
			}forEach (Allplayers - entities "HeadlessClient_F" - [player]);
			
			//Create sentence with answers for player
			private _ctrl_question = [_speaker,_listener,_question,_options] call pr0_fnc_dialogue_createSentence;
			
			private _ctrl_questions = _display getvariable ["pr0_dialogue_question_list" ,[]];
			_ctrl_questions pushBack _ctrl_question;
			_display setvariable ["pr0_dialogue_question_list" ,_ctrl_questions];
			
			
			private _keyDownEvent = _display getVariable "pr0_dialogue_keyDownEvent";
			if(isNil "_keyDownEvent")then{
				private _keyDownEvent = _display displayAddEventHandler ["KeyDown", { 
					params ["_display", "_key", "_shift", "_ctrl", "_alt"];
					_key = _key-1;//normalize to number on keyboard key_1 == 2
					if (_key >0 && _key  <=9) then {
						private _ctrl_questions = _display getvariable ["pr0_dialogue_question_list" ,[]];
						private _answers_total = 0;
						{
							private _ctrl_question = _x;
							private _answers_ = count (_ctrl_question getVariable ["_options",[]]);
							if(_key<=_answers_)exitWith{
								_ctrl_question setVariable ["answer_index", _key-1-_answers_total];
							};
							_answers_total = _answers_total + _answers_;
						}forEach _ctrl_questions;
						true;//disable default key events (commanding menu)
					}else{
						false;
					};   
				}];
				_display setVariable ["pr0_dialogue_keyDownEvent",_keyDownEvent];
			};
			
			//wait untill we get an answer
			private _selected_index = INT_ID_UNDEFINED;
			private _waiting_since = time; 
			waitUntil {
				sleep 0.1;
				_selected_index = _ctrl_question getVariable ["answer_index",-1];
				
				if(_unit_1 distance _unit_2 > 10)then{_selected_index = INT_ID_WALKED_AWAY};
				if(time > _waiting_since + FLOAT_MAX_WAIT_FOR_ANSWER)then{_selected_index = INT_ID_OUT_OF_TIME};
				if(
					!alive _unit_2 || {
					_unit_2 getVariable ["ace_isunconscious",false] || {
					_unit_2 getVariable ["ace_isunconscious",false] }}
				)then{_selected_index = INT_ID_UNIT_KILLED};
				
				_selected_index != -1;
			};
			
			//Remove options from question sentence
			_ctrl_question setVariable ["_options",[]];
			[_ctrl_question] call pr0_fnc_dialogue_updateSentence;
			
			//remove question from question list so its not being used anymore
			private _ctrl_questions = _display getvariable ["pr0_dialogue_question_list" ,[]];
			_ctrl_questions pushBack _ctrl_question;
			_display setvariable ["pr0_dialogue_question_list" ,_ctrl_questions];
			
			//update all questions (renumber answers and remove answers from the question that has been answered)
			{_x  call pr0_fnc_dialogue_updateSentence;}foreach _ctrl_questions;
			
			//change type so it can be removed
			_ctrl_question setVariable ["_type", TYPE_SENTENCE];
			
			//No answer given waited to long or player walked away.
			if(_selected_index == INT_ID_WALKED_AWAY)exitWith {_new_conversation_id = _event_walkAway};
			if(_selected_index == INT_ID_OUT_OF_TIME)exitWith {_new_conversation_id = _event_outOfTime};
			if(_selected_index == INT_ID_UNIT_KILLED)exitWith {_new_conversation_id = "#end"};
			
			//what did we answer?
			private _selected_option = _options#(_selected_index);
			//update conversation_id
			_new_conversation_id = _selected_option#1;
			
			//let everone know what we have answers!
			{
				if(_x distance _unit_1 < FLOAT_MAX_LISTENING_DISTANCE)then{
					[_unit_1, _unit_2, _selected_option#0] remoteExecCall ["pr0_fnc_dialogue_createSentence",_x];
				};
			}forEach (Allplayers - entities "HeadlessClient_F");		
		
			sleep (count(_selected_option#0)/12 + 0.5);
		};// end if question
		
		if(_new_conversation_id == "#end")exitWith{};
		if(_new_conversation_id == "")exitWith{
			diag_log format["ERROR NO NEW SENTENCE_ID OR OPTIONS ARE GIVEN IN: %1",_conversation_id]
		};
		
		_conversation_id = _new_conversation_id;
		
	};
};