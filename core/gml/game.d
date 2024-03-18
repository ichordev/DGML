module gml.game;

import core.time;
import std.math;

void init(){
	gameState = GameState.starting;
	frameDelay = 1.usecs / 30;
}

void quit(){
	
}

enum GameState{
	starting,
	running,
	ending,
	restarting,
}
GameState gameState;
int returnCode = 0;

void gameEnd(int returnCode=0) nothrow @nogc @safe{
	gameState = GameState.ending;
	.returnCode = returnCode;
}
alias game_end = gameEnd;

void gameRestart() nothrow @nogc @safe{
	gameState = GameState.restarting;
}

enum GameSpeed{
	fps,
	microSeconds,
	microseconds = microSeconds,
}
alias gamespeed = GameSpeed;

Duration frameDelay;

void gameSetSpeed(ulong speed, GameSpeed type) nothrow @nogc @safe{
	frameDelay = {
		final switch(type){
			case GameSpeed.fps:          return 1.usecs / speed;
			case GameSpeed.microSeconds: return speed.usecs;
		}
	}();
}
alias game_set_speed = gameSetSpeed;

ulong gameGetSpeed(GameSpeed type) nothrow @nogc @safe{
	final switch(type){
		case GameSpeed.fps:          return cast(ulong)round(1.usecs.total!"usecs"() / cast(double)frameDelay.total!"usecs"());
		case GameSpeed.microSeconds: return frameDelay.total!"usecs"();
	}
}
alias game_get_speed = gameGetSpeed;

struct HighScore{
	string name = "Unknown";
	ulong score = 0;
}
HighScore[10] highScores;

void highScoreAdd(string str, ulong numb) nothrow @nogc @safe{
	foreach(i, highScore; highScores){
		if(numb > highScore.score){
			HighScore prevScore = HighScore(str, numb);
			foreach(ref thisScore; highScores[i..$]){
				auto storedScore = thisScore;
				thisScore = prevScore;
				prevScore = storedScore;
			}
			break;
		}
	}
}
alias highscore_add = highScoreAdd;

string highscoreName(uint place) nothrow @nogc @safe
in(place >= 1 && place <= 10) =>
	highScores[place - 1].name;
alias highscore_name = highscoreName;

ulong highscoreValue(uint place) nothrow @nogc @safe
in(place >= 1 && place <= 10) =>
	highScores[place - 1].score;
alias highscore_value = highscoreValue;

unittest{
	highScoreAdd("Tom", 2395);
	highScoreAdd("Dick", 8533);
	highScoreAdd("Harry", 5001);
	assert(highScores[0..3] == [
		HighScore("Dick", 8533),
		HighScore("Harry", 5001),
		HighScore("Tom", 2395),
	]);
	assert(highscoreName(2) == "Harry");
	assert(highscoreValue(1) == 8533);
}

void highscoreClear(){
	highScores[] = HighScore.init;
}
alias highscore_clear = highscoreClear;
