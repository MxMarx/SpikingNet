function o = generateStimulusTrain(o, DLM)
%% Generate the output from DLM by converting spike timings to EPSPs
% I don't quite remember what I did here, good luck! :)

stimulusMatrix = false(length(DLM),round(630/o.dt));
for i = 1:length(DLM)
    y = ceil(DLM{i} / o.dt);
    stimulusMatrix(i,y) = 1;
end

inputClusters = 8;

clustedInput = {};

time_padding = 10;

for i = 1:inputClusters
    % Circularly shift the input, and pad with 500ms of zeros
    shift = randi(length(stimulusMatrix),1);
    clusterInput{i} = [zeros(length(DLM), time_padding/o.dt),...
        circshift(stimulusMatrix,shift,2)];
end

edges = round(linspace(1,o.Ne,inputClusters + 1));
for i = 1:inputClusters
    DLMOutputCluster(edges(i):edges(i+1)) = i;
end
        
k2 = randi(25);
stimulusMatrix = {};
for i = 1:inputClusters
            k = randi(20);
    for j = 1:ceil(o.t_span / (630+time_padding))
        k = mod(k2+i,24)+1;
x = datasample(clusterInput{i}([k,k+4],:), sum(DLMOutputCluster==i)) + datasample(clusterInput{i}([k,k+4],:), sum(DLMOutputCluster==i));
        stimulusMatrix{i,j} = circshift(x,  randi(length(x),1), 2);
%                 stimulusMatrix{i,j} = datasample(clusterInput{i}, sum(DLMOutputCluster==i));
    end
end


% for i = 1:inputClusters
%     k = randi(20);
%     stimulusMatrix{i,1} = repmat(...
%         datasample(clusterInput{i}(k:k+4,:), sum(DLMOutputCluster==i)) + datasample(clusterInput{i}(k:k+4,:), sum(DLMOutputCluster==i)),...
%         1, ceil(o.t_span / (630+time_padding)));
% end


stimulusMatrix = cell2mat(stimulusMatrix);
stimulusMatrix = stimulusMatrix(:, 1:round(o.t_span/o.dt));
% stimulusMatrix = stimulusMatrix .* (rand(size(stimulusMatrix)) > .8);

o.stimulusTrain = cell(size(o.Ne));
for i = 1:o.Ne
    o.stimulusTrain{i} = find(stimulusMatrix(i,:)) * o.dt;
end

spike_timespan = 0:o.dt:30;
epsp = (1/(o.tau2_e-o.tau1))*(exp(-spike_timespan/o.tau2_e) - exp(-spike_timespan/o.tau1)); % Excitatory output waveform
stimulusMatrix = conv2(stimulusMatrix,epsp) * o.W_ee ;

o.stimulusMatrix = stimulusMatrix;