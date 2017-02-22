function [Channels_prev, Channels_curr] = GenerateChannels(I_prev, I_curr)

%------------------------------------------------------------------------------------------
%% Texture feature generation:
Texture_prev = CalculateLF(I_prev);
Texture_curr = CalculateLF(I_curr);

%------------------------------------------------------------------------------------------
%% Channels struct creation:
[~,Channels_prev.ch1] = PreProcess(I_prev);
[~,Channels_prev.ch2] = PreProcess(Texture_prev);

[~,Channels_curr.ch1] = PreProcess(I_curr);
[~,Channels_curr.ch2] = PreProcess(Texture_curr);