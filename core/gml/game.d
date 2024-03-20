module gml.game;

import gml.options;

import core.time;
import std.math;
import ic.calc;

void init(){
	gameState = GameState.starting;
	gameSetSpeed(options.fps, GameSpeed.fps);
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
	microseconds,
}
alias gamespeed = GameSpeed;

Duration frameDelay;

void gameSetSpeed(double speed, GameSpeed type) nothrow @nogc @safe{
	frameDelay = {
		final switch(type){
			case GameSpeed.fps:          return 100_000.seconds / cast(ulong)round(speed * 100_000.0);
			case GameSpeed.microseconds: return nsecs(cast(ulong)round(speed * cast(double)1.usecs.total!"nsecs"()));
		}
	}();
}
alias game_set_speed = gameSetSpeed;

double gameGetSpeed(GameSpeed type) nothrow @nogc @safe{
	final switch(type){
		case GameSpeed.fps:          return 1.seconds.total!"nsecs"() / cast(double)frameDelay.total!"nsecs"();
		case GameSpeed.microseconds: return frameDelay.total!"nsecs"() / cast(double)(1.usecs.total!"nsecs"());
	}
}
alias game_get_speed = gameGetSpeed;
unittest{
	gameSetSpeed(60.0, GameSpeed.fps);
	assert(gameGetSpeed(GameSpeed.fps).eqEps(60.0, 0.001));
	assert(gameGetSpeed(GameSpeed.microseconds).eqEps(16_666.6, 0.01));
	gameSetSpeed(16_666, GameSpeed.microseconds);
	assert(gameGetSpeed(GameSpeed.fps).eqEps(60.0, 0.0025));
	assert(gameGetSpeed(GameSpeed.microseconds) == 16_666.0);
	gameSetSpeed(59.94, GameSpeed.fps);
	assert(gameGetSpeed(GameSpeed.fps).eqEps(59.94, 0.001));
	assert(gameGetSpeed(GameSpeed.microseconds).eqEps(16_683.3, 0.01));
}

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
