module gml.audio;

import std.algorithm.comparison, std.string;

version(Have_bindbc_sdl):
import bindbc.sdl;
static if(bindSDLMixer):

struct SoundAsset{
	Mix_Chunk* data;
	double playPos = 0.0;
	
	this(Mix_Chunk* data) nothrow @nogc pure @safe{
		this.data = data;
	}
	this(SoundInstanceID index) nothrow @nogc {
		this.data = Mix_GetChunk(index);
	}
}

alias SoundInstanceID = int;

SoundInstanceID findPlayingSoundInstance(SoundAsset index) nothrow @nogc{
	auto channels = Mix_AllocateChannels(-1);
	foreach(channel; 0..channels){
		if(Mix_GetChunk(index) is index.data){
			return channel;
		}
	}
	return -1;
}

struct PlayingSoundInstances{
	const Mix_Chunk* searchQuery;
	const int channels;
	SoundInstanceID id = 0;
	
	this(SoundAsset index) nothrow @nogc{
		searchQuery = index.data;
		channels = Mix_AllocateChannels(-1);
		popFront();
	}
	
	SoundInstanceID front() nothrow @nogc pure @safe => id;
	bool empty() nothrow @nogc pure @safe => id == channels;
	
	void popFront() nothrow @nogc{
		foreach(channel; id..channels){
			if(Mix_GetChunk(channel) is searchQuery){
				this.id = channel;
				return;
			}
		}
		this.id = channels;
	}
}

//Asset Info

bool audioExists(SoundAsset index) => index.data !is null;
alias audio_exists = audioExists;

//TODO: audio_get_name

//TODO: audio_get_type

double audioSoundLength(SoundAsset index) nothrow @nogc{
	int sampleRate, channelNum;
	SDL_AudioFormat format;
	if(!Mix_QuerySpec(&sampleRate, &format, &channelNum)){
		return double.nan;
	}
	
	auto multiChannelSamples = index.data.alen / ((format & 0xFF) / 8);
	return (multiChannelSamples / channels) / cast(double)sampleRate;
}
double audioSoundLength(SoundInstanceID index) nothrow @nogc => audioSoundLength(SoundAsset(index));
alias audio_sound_length = audioSoundLength;

bool audioSoundIsPlayable(SoundAsset index) nothrow @nogc pure @safe => true;
alias audio_sound_is_playable = audioSoundIsPlayable;

//Playing Sounds

///Note that priority is currently ignored.
SoundInstanceID audioPlaySound(SoundAsset index, float priority, bool loop) nothrow @nogc{
	if(index.playPos > 0.0){
		return audioPlaySoundAtTime(ret, priority, loop, playPos);
	}else{
		return Mix_PlayChannel(-1, index.data, loop ? -1 : 0);
	}
}
alias audio_play_sound = audioPlaySound;

private{
	struct TimeData{
		bool fromStart = false;
		bool loop = false;
		int offset;
		ubyte[] buffer;
		
	}
	extern(C) void channelStartTimeMix(int channel, void* stream, int streamLen, void* userData) nothrow @nogc{
		auto timeData = cast(TimeData*)userData;
		
		if(loop){
			timeData.buffer[] = stream[0..offset];
		}
		stream[0..streamLen-offset] = stream[offset..streamLen];
		if(loop){
			stream[streamLen-offset..streamLen] = timeData.buffer[];
		}else{
			stream[streamLen-offset..streamLen] = 0;
		}
		
		timeData.offset = (timeData.offset + timeData.offset) % streamLen;
	}
	extern(C) void channelStartTimeDone(int channel, void* userData) nothrow @nogc{
		auto timeData = cast(TimeData*)userData;
		if(timeData.loop){
			SDL_free(timeData.buffer.ptr);
		}
		SDL_free(userData);
	}
}
SoundInstanceID audioPlaySoundAtTime(SoundAsset index, float priority, bool loop, double time, SoundInstanceID channel=-1) nothrow @nogc{
	auto timeData = cast(TimeData*)SDL_malloc(StartTimeData.sizeof);
	timeData = StartTimeData.init;
	timeData.loop = loop;
	timeData.offset = {
		int sampleRate, channelNum;
		SDL_AudioFormat format;
		if(!Mix_QuerySpec(&sampleRate, &format, &channelNum)){
			return 0;
		}
		return cast(int)round(time * sampleRate * ((format & 0xFF) / 8) * channels);
	}();
	if(loop){
		timeData.buffer = (cast(ubyte*)SDL_malloc(timeData.offset))[0..timeData.offset];
	}
	
	channel = Mix_PlayChannel(channel, index.data, 0);
	Mix_RegisterEffect(channel, &channelStartTimeMix, &channelStartTimeDone, cast(void*)loopData);
	return channel;
}

//TODO: audio_play_sound_ext

//TODO: audio_play_sound_at using Mix_SetPosition stuff

void audioPauseSound(SoundInstanceID index) nothrow @nogc{
	Mix_Pause(index);
}
void audioPauseSound(SoundAsset index) nothrow @nogc{
	foreach(id; PlayingSoundInstances(index)){
		audioPauseSound(id);
	}
}
alias audio_pause_sound = audioPauseSound;

void audioPauseAll() nothrow @nogc{
	Mix_Pause(-1);
}
alias audio_pause_all = audioPauseAll;

void audioResumeSound(SoundInstanceID index) nothrow @nogc{
	Mix_Resume(index);
}
void audioResumeSound(SoundAsset index) nothrow @nogc{
	foreach(id; PlayingSoundInstances(index)){
		audioResumeSound(id);
	}
}
alias audio_resume_sound = audioResumeSound;

void audioResumeAll() nothrow @nogc{
	Mix_Pause(-1);
}
alias audio_resume_all = audioResumeAll;

void audioStopSound(SoundInstanceID index) nothrow @nogc{
	Mix_Halt(index);
}
void audioStopSound(SoundAsset index) nothrow @nogc{
	foreach(id; PlayingSoundInstances(index)){
		audioStopSound(id);
	}
}
alias audio_stop_sound = audioStopSound;

void audioStopAll() nothrow @nogc{
	Mix_Halt(-1);
}
alias audio_stop_all = audioStopAll;

bool audioIsPlaying(SoundInstanceID index) nothrow @nogc =>
	Mix_Playing(index) != 0;
bool audioIsPlaying(SoundAsset index) nothrow @nogc{
	foreach(id; PlayingSoundInstances(index)){
		if(audioIsPlaying(id)) return true;
	}
	return false;
}
alias audio_is_playing = audioIsPlaying;

bool audioIsPaused(SoundInstanceID index) nothrow @nogc =>
	Mix_Paused(index) != 0;
bool audioIsPaused(SoundAsset index) nothrow @nogc{
	foreach(id; PlayingSoundInstances(index)){
		if(audioIsPaused(id)) return true;
	}
	return false;
}
alias audio_is_paused = audioIsPaused;

//Audio Properties

//TODO: audio_sound_gain

//TODO: audio_sound_get_gain

//TODO: audio_sound_pitch

//TODO: audio_sound_get_pitch

void audioSoundSetTrackPosition(SoundAsset index, double time) nothrow @nogc pure @safe{
	index.playPos = clamp(time, 0.0, audioSoundLength(index));
}
///Function requires extra `loop` parameter, because we cannot retrieve whether a chunk is looping or not from SDL_Mixer :(
void audioSoundSetTrackPosition(SoundInstanceID index, double time, bool loop=true) nothrow @nogc{
	auto asset = Mix_GetChunk(index);
	if(asset is null) return;
	audioStopSound(index);
	audioPlaySoundAtTime(asset, float.infinity, loop, time, index);
}
alias audio_sound_set_track_position = audioSoundSetTrackPosition;

double audioSoundGetTrackPosition(SoundAsset index) nothrow @nogc pure @safe =>
	index.playPos;
//TODO: double audioSoundGetTrackPosition(SoundInstanceID index) nothrow @nogc{}
alias audio_sound_get_track_position = audioSoundGetTrackPosition;

//TODO: audio_sound_set_listener_mask

//TODO: audio_sound_get_listener_mask

//Audio Loop Points

//TODO: audio_sound_loop

//TODO: audio_sound_get_loop

//TODO: audio_sound_loop_start

//TODO: audio_sound_get_loop_start

//TODO: audio_sound_loop_end

//TODO: audio_sound_get_loop_end

//Configuration

//TODO: audio_master_gain

//TODO: audio_set_master_gain

//TODO: audio_get_master_gain

void audioChannelNum(uint num){
	Mix_AllocateChannels(num);
}
alias audio_channel_num = audioChannelNum;

//TODO: audio_falloff_set_model

//TODO: audio_system_is_available

//TODO: audio_system_is_initialised

//Debugging

//TODO: audio_debug

//Gain Conversion

//TODO: lin_to_db

//TODO: db_to_lin

//Audio Streams

SoundAsset audioCreateStream(string filename) nothrow @nogc =>
	SoundAsset(Mix_LoadWAV(filename.toStringz()));
alias audio_create_stream = audioCreateStream;

int audioDestroyStream(SoundAsset sound) nothrow @nogc{
	if(sound.data is null) return -1;
	Mix_FreeChunk(sound.data);
	return 1;
}
alias audio_destroy_stream = audioDestroyStream;
