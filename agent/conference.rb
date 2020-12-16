# A part of Elten - EltenLink / Elten Network desktop client.
# Copyright (C) 2014-2020 Dawid Pieper
# Elten is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, version 3. 
# Elten is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details. 
# You should have received a copy of the GNU General Public License along with Elten. If not, see <https://www.gnu.org/licenses/>. 



class Conference
class Transmitter
attr_reader :decoder, :stream
attr_reader :listener_x, :listener_y, :transmitter_x, :transmitter_y
attr_reader :username
def initialize(x, y, username, volume=nil)
@listener_x=x
@listener_y=y
@transmitter_x=7
@transmitter_y=7
@decoder = Opus::Decoder.new(48000, 2)
@stream = Bass::BASS_StreamCreate.call(48000, 2, 0, -1, nil)
@username=username
setvolume(volume)
Bass::BASS_ChannelPlay.call(@stream, 0)
end
def setvolume(volume)
if volume.is_a?(Array)
vol=volume[0]
vol=0 if volume[1]==true
@volume=vol
else
@volume=100
end
update_position
end
def update_baseposition(x, y)
@listener_x=x
@listener_y=y
update_position
end
def move(nx, ny)
@transmitter_x=nx
@transmitter_y=ny
update_position
end
def update_position
rx=(@transmitter_x-@listener_x)/8.0
ry=(@transmitter_y-@listener_y)/8.0
pos=rx
vol=(1-(ry.abs*rx.abs)*0.9)*@volume/100.0
Bass::BASS_ChannelSetAttribute.call(@stream, 3, [pos].pack("F").unpack("i")[0])
Bass::BASS_ChannelSetAttribute.call(@stream, 2, [vol].pack("f").unpack("I")[0])
end
def reset
@decoder.reset
end
def put(frame)
pcm=@decoder.decode(frame)
Bass::BASS_StreamPutData.call(@stream, pcm, pcm.bytesize)
end
def free
Bass::BASS_StreamFree.call(@stream)
@decoder.free
end
end

def initialize
@x=7
@y=7
Bass.record_prepare
@transmitters={}
@volumes={$name=>[100,true]}
@muted=false
@stream_mutex = Mutex.new
@mixer = Bass::BASS_Mixer_StreamCreate.call(48000, 2, 0x200000|0x1000)
@mymixer = Bass::BASS_Mixer_StreamCreate.call(48000, 2, 0x1000)
Bass::BASS_ChannelPlay.call(@mymixer, 0)
@recordstream = Bass::BASS_StreamCreate.call(48000, 2, 0x200000, -1, nil)
Bass::BASS_Mixer_StreamAddChannel.call(@mixer, @recordstream, 0x4000)
@stream=nil
@record = Bass::BASS_RecordStart.call(48000, 2, 0, 0, 0)
Bass::BASS_ChannelPlay.call(@record, 0)
@voip=VoIP.new
@encoder=nil
@speexdsp=nil
@speexdsp_framesize=0
@encoder_mutex = Mutex.new
@record_mutex = Mutex.new
@voip.on_receive {|userid, type, message, pos_x, pos_y|
if type==1
if @transmitters[userid]!=nil
@transmitters[userid].move(pos_x, pos_y) if @transmitters[userid].transmitter_x!=pos_x || @transmitters[userid].transmitter_y!=pos_y
@transmitters[userid].put(message)
end
end
}
@fsize=0
@voip.on_params {|params|
@encoder_mutex.synchronize {
if params['channel'].is_a?(Hash)
@encoder.free if @encoder!=nil
@encoder = Opus::Encoder.new(48000, 2, :voip)
@encoder.packetloss=10
@encoder.bitrate=params['channel']['bitrate']*1000
@fsize=params['channel']['framesize']*48000*4/1000
sfs=20
sfs=params['channel']['framesize'] if params['channel']['framesize']<20
if @speexdsp_framesize!=sfs
@speexdsp.free if @speexdsp!=nil
@speexdsp=nil
end
if sfs>=10
if @speexdsp==nil
@speexdsp=SpeexDSP::Processor.new(48000, 2, sfs)
@speexdsp.noise_reduction=($usedenoising||0)>0
@speexdsp_framesize = sfs
end
else
@speexdsp_framesize=0
end
frs=@transmitters.size==0
upusers=[]
for u in params['channel']['users']
uid=u['id']
upusers.push(uid)
if @transmitters.include?(uid)
@transmitters[uid].reset
else
@user_hooks.each{|h|h.call(true, u['name'], uid)} if frs==false
@transmitters[uid] = Transmitter.new(@x, @y, u['name'], @volumes[u['name']])
end
end
@channel_hooks.each{|h|h.call(params['channel'])}
@volumes_hooks.each{|h|h.call(@volumes)}
for t in @transmitters.keys
if !upusers.include?(t)
@user_hooks.each{|h|h.call(false, @transmitters[t].username, t)} if frs==false
@transmitters[t].free
@transmitters.delete(t)
end
end
end
}
}
@voip.connect($name, $token)
@recorder_thread = Thread.new {
bufsize = 2097152
buf="\0"*bufsize
loop {
@record_mutex.synchronize {
while (sz=Bass::BASS_ChannelGetData.call(@record, buf, bufsize))>0
audio = buf.byteslice(0...sz)
if !@muted
audio=@speexdsp.process(audio) if @speexdsp!=nil
Bass::BASS_StreamPutData.call(@recordstream, audio, audio.bytesize)
else
audio=("\0"*audio.bytesize).b
Bass::BASS_StreamPutData.call(@recordstream, audio, audio.bytesize)
end
end
}
}
}
@mixer_thread = Thread.new {
bufsize = 2097152
buf="\0"*bufsize
audio=""
loop {
sleep(0.01)
while (sz=Bass::BASS_ChannelGetData.call(@mixer, buf, bufsize))>0
if @fsize>0
au=(audio||"").b+buf.byteslice(0...sz).b
audio=""
index=0
while au.bytesize-index>=@fsize
part=au.byteslice(index...index+@fsize)
if @encoder!=nil
frame=""
@encoder_mutex.synchronize {
frame=@encoder.encode(part, @fsize/4)
}
@voip.send(1, frame, @x, @y)
end
index+=@fsize
end
audio=au[index..-1]
end
end
}
}
@channel_hooks=[]
@volumes_hooks=[]
@user_hooks=[]
end
def set_stream(file)
@stream_mutex.synchronize {
remove_stream if @stream!=nil
@stream = Bass::BASS_StreamCreateFile.call(0, unicode(file), 0, 0, 0, 0, [256|0x80000000|0x200000].pack("I").unpack("i").first)
@stream_uploader = Bass::BASS_Split_StreamCreate.call(@stream, 0x200000, nil)
@stream_listener = Bass::BASS_Split_StreamCreate.call(@stream, 0x200000, nil)
Bass::BASS_Mixer_StreamAddChannel.call(@mixer, @stream_uploader, 0)
Bass::BASS_Mixer_StreamAddChannel.call(@mymixer, @stream_listener, 0x4000)
}
return @stream
end
def remove_stream
@stream_mutex.synchronize {
Bass::BASS_StreamFree.call(@stream) if @stream!=nil
Bass::BASS_StreamFree.call(@stream_uploader) if @stream_uploader!=nil
Bass::BASS_StreamFree.call(@stream_listener) if @stream_listener!=nil
@stream=@mystream=nil
}
end
def volume
vl=[0].pack("f")
Bass::BASS_ChannelGetAttribute.call(@recordstream, 2, vl)
return (vl.unpack("f").first*100).round
end
def volume=(vol)
vol=100 if vol>100
vol=0 if vol<0
Bass::BASS_ChannelSetAttribute.call(@recordstream, 2, [(vol/100.0)].pack("f").unpack("I")[0])
vol
end
def stream_volume
vol=0
@stream_mutex.synchronize {
if @stream_uploader!=nil
vl=[0].pack("f")
Bass::BASS_ChannelGetAttribute.call(@stream_uploader, 2, vl)
vol=(vl.unpack("f").first*100).round
end
}
return vol
end
def stream_volume=(vol)
vol=100 if vol>100
vol=0 if vol<0
@stream_mutex.synchronize {
Bass::BASS_ChannelSetAttribute.call(@stream_uploader, 2, [(vol/100.0)].pack("f").unpack("I")[0]) if @stream_uploader!=nil
Bass::BASS_ChannelSetAttribute.call(@stream_listener, 2, [(vol/100.0)].pack("f").unpack("I")[0]) if @stream_listener!=nil
}
vol
end
def muted
@muted
end
def muted=(mt)
@muted=(mt!=false)
mt
end
def reset
@record_mutex.synchronize {
Bass::BASS_Mixer_ChannelRemove.call(@record)
Bass::BASS_StreamFree.call(@record) if @record!=nil
Bass.record_prepare
@record = Bass::BASS_RecordStart.call(48000, 2, 0, 0, 0)
Bass::BASS_ChannelSetAttribute.call(@record, 2, [(@input_volume||100)/100.0].pack("F").unpack("i")[0])
Bass::BASS_ChannelPlay.call(@record, 0)
@encoder_mutex.synchronize {
@speexdsp.noise_reduction=($usedenoising||0)>0 if @speexdsp!=nil
@encoder.reset if @encoder!=nil
}
}
end
def setvolume(user, volume=100, muted=false)
volume=100 if volume>100
volume=10 if volume<10
v=[volume, muted]
@volumes[user]=v
for t in @transmitters.values
t.setvolume(v) if t.username==user
end
if user==$name
if !muted
Bass::BASS_ChannelStop.call(@mymixer)
else
Bass::BASS_ChannelPlay.call(@mymixer, 1)
end
end
@volumes_hooks.each{|h|h.call(@volumes)}
end
def on_channel(&block)
@channel_hooks.push(block) if block!=nil
end
def on_user(&block)
@user_hooks.push(block) if block!=nil
end
def on_volumes(&block)
@volumes_hooks.push(block) if block!=nil
end
def x
return @x
end
def y
return @y
end
def x=(nx)
nx=1 if nx<1
nx=15 if nx>15
@x=nx
update_baseposition
nx
end
def y=(ny)
ny=1 if ny<1
ny=15 if ny>15
@y=ny
update_baseposition
ny
end
def update_baseposition
for t in @transmitters.values
t.update_baseposition(@x, @y)
end
end
def free
@mixer_thread.exit if @mixer_thread!=nil
@recorder_thread.exit if @recorder_thread!=nil
for t in @transmitters.keys
@transmitters[t].free
end
Bass::BASS_StreamFree.call(@record)
Bass::BASS_Mixer_ChannelRemove.call(@record)
@encoder_mutex.synchronize {
@encoder.free if @encoder!=nil
@speexdsp.free if @speexdsp!=nil
}
Bass::BASS_StreamFree.call(@mymixer)
Bass::BASS_StreamFree.call(@stream) if @stream!=nil
Bass::BASS_StreamFree.call(@mixer)
@voip.disconnect
end
def list_channels
@voip.list_channels||[]
end
def join_channel(ch)
@voip.join_channel(ch)
end
def leave_channel
@voip.leave_channel
end
def create_channel(params)
name=params['name']||"Channel"
bitrate=params['bitrate']||64
framesize=params['framesize']||60
public=params['public']||true
password=params['password']||nil
resp=@voip.create_channel(name, public, framesize, bitrate, password)
if resp.is_a?(Hash)
return resp['id']
else
return nil
end
end
end