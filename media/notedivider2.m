%notedivider2 takes in an audio file and detects note onsets in the
%frequency domain using a spectrogram



function [bpm, notes, notetimes] = notedivider2(data, fs)
tol = .15;
window = round(fs*.04);
overlap = window/2;

%Use Spectrogram function
[S, ~, T]=spectrogram(data, ones(1,window), overlap, window*8, fs, 'yaxis');
power = sum(abs(S), 1);

smoothed = conv(hann(round(fs*.15/length(T))), power);
smoothed=smoothed./max(smoothed);

plot(smoothed)

[~, peaks] = findpeaks(smoothed,'minpeakheight',0.3, 'minpeakdistance', 10);
%The length of each 
notetimes = zeros(length(peaks), 1);
N = length(T);

for i = 1:length(peaks)
    if (i == length(peaks))
        notetimes(i) = N+peaks(1) - peaks(i);
    else
        notetimes(i) = peaks(i+1) - peaks(i);
    end
end

notetimes = T(notetimes)*fs;


%Identify tempo.
%Find the shortest interval to make our smallest note.
beat = 1;
smallest = min(notetimes);
smallest = mean(notetimes(notetimes < smallest*(1+tol)));
while(smallest/beat/fs < .3)
    beat = .5*beat;
end

bpm = beat*fs/smallest*60;

%Construct notes
notes = .5*round(2*beat*notetimes/smallest);

return