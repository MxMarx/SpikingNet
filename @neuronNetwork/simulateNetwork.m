function o = simulateNetwork(o)
% rng('default')


%% Now simulate the dyamics with Euler!
spike_timespan = 0:o.dt:30;
epsp = (1/(o.tau2_e-o.tau1))*(exp(-spike_timespan/o.tau2_e) - exp(-spike_timespan/o.tau1)); % Excitatory output waveform
ipsp = (1/(o.tau2_i-o.tau1))*(exp(-spike_timespan/o.tau2_i) - exp(-spike_timespan/o.tau1)); % Inhibitory output waveform
epsp(end+1) = 0;
ipsp(end+1) = 0;

stimulusTrain = generateStimulusTrain(o, epsp);


%define vector of inital cell voltages:
V = rand(length(o.W),1)+.2;

%define vector of cells' synaptic output. This should be the length of
%f_template:
syn_out = zeros(length(o.W), 1);

%initialize synaptic input vector ON TO each cell:
syn_idx = repmat(length(epsp), length(o.W), 1);

% build matrix to save cell voltages:
o.voltageHistory = zeros(length(o.W),round(o.t_span/o.dt));
% build matrix to save spike outputs:
o.syn_out_history = zeros(length(o.W),round(o.t_span/o.dt));
% initialize matrix to save spike times:
o.spikes = false(length(o.W),floor(o.t_span/o.dt));

%add in o.refractory counter:
refract_counter = zeros(length(o.W),1);

%now run the dynamics:


for i = 1:o.t_span/o.dt
    
    %update  syn_out:
    syn_idx = min(syn_idx + 1, length(ipsp));
    syn_out(o.excitatory_idx) = epsp(syn_idx(o.excitatory_idx));
    syn_out(o.inhibitory_idx) = ipsp(syn_idx(o.inhibitory_idx));
    o.syn_out_history(:,i) = syn_out;
    
    %update o.refractory counter:
    refract_counter = refract_counter-1;
    
    %assign Isyn:
    Isyn =  o.W' * syn_out;
    
    v_old = V; %keep record of previous value
    
    Isyn(1:o.Ne) = Isyn(1:o.Ne) + stimulusTrain(:,i)*o.W_ee*4;
    
    
    V = V + o.dt*((1./o.tau).*(o.mu - V) + Isyn);
    
    %keep the cells that are in their o.refractory period at their previous
    %value:
    V(refract_counter > 0) = v_old(refract_counter > 0);
    
    %look for spikes and store them:
    o.spikes(:,i) = V >= o.V_thr;
    
    %set all the spiking cells on their o.refractory clock:
    refract_counter(o.spikes(:,i)) = o.refractory/o.dt;
    
    syn_idx(o.spikes(:,i))  = 1;
    
    %reset the voltage of the cells that just spiked:
    V(o.spikes(:,i)) = o.V_reset;
    
    %store voltages:
    o.voltageHistory(:,i) = V;
    
    
    % Display the progress
    if ~mod(i,1000)
        fprintf('%-10.3f %10g\n',...
            i / (o.t_span/o.dt),...
            sum(refract_counter > 0))
    end
end

% Put the spikes in a cell array
spikes = cell(size(o.N));
for i = 1:length(o.W)
    spikes{i} = find(o.spikes(i,:)) * o.dt;
end
o.spikes = spikes;



function stimulusTrain = generateStimulusTrain(o, epsp)
%% Generate the output from DLM bu converting spike timings to EPSPs
stimulusTrain = repmat(-1,length(o.DLM),round(630/o.dt));
for i = 1:length(o.DLM)
    y = ceil([0; o.DLM{i}'] / o.dt);
    y(diff(y)==0) = [];
    stimulusTrain(i,y(2:end)) = diff(y) - 1;
end
stimulusTrain = cumsum(-stimulusTrain, 2)+1;

inputClusters = 8;

clustedInput = {};
DLMOutputCluster = [];
edges = round(linspace(1,o.Ne,inputClusters + 1));

time_padding = 250;
time_padding = 10;

for i = 1:inputClusters
    % Circularly shift the input, and pad with 500ms of zeros
    shift = randi(length(stimulusTrain),1);
%     shift = 1;
    clusterInput{i} = [zeros(length(o.DLM), time_padding/o.dt),...
        circshift(stimulusTrain,shift,2)];
    DLMOutputCluster(edges(i):edges(i+1)) = i;
end 

stimulusTrain = {};
% rng('default')

k2 = randi(25);
for j = 1:ceil(o.t_span / (630+time_padding))
    for i = 1:inputClusters
        k = randi(25);
        k = mod(k2+i,24)+1;
        stimulusTrain{i,j} = datasample(clusterInput{i}([k,k],:), sum(DLMOutputCluster==i));
%         stimulusTrain{i,j} = datasample(clusterInput{i}, sum(DLMOutputCluster==i));

%         for k = 1:2
%         stimulusTrain{i,j} = stimulusTrain{i,j} + datasample(clusterInput{i}, sum(DLMOutputCluster==i));
%         end
    end
end
stimulusTrain = cell2mat(stimulusTrain);
stimulusTrain = stimulusTrain(:, 1:round(o.t_span/o.dt));
stimulusTrain(randsample(o.Ne,round(o.Ne*0.8)), :) = 0;

% Put the spikes in a cell array
spikes = cell(size(o.Ne));
for i = 1:o.Ne
    spikes{i} = find(stimulusTrain(i,:)==1) * o.dt;
end
o.stimulusTrain = spikes;


stimulusTrain = min(stimulusTrain, length(epsp));
stimulusTrain = max(stimulusTrain, 1);
stimulusTrain = epsp(stimulusTrain);

