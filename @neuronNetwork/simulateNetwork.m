function [o, V, syn_out, syn_idx, refract_counter]  = simulateNetwork(o,V, syn_out, syn_idx, refract_counter)
% rng('default')

% build matrix to save cell voltages:
o.voltageHistory = zeros(length(o.W),round(o.t_span/o.dt));
% build matrix to save spike outputs:
o.syn_out_history = zeros(length(o.W),round(o.t_span/o.dt));
% initialize matrix to save spike times:
o.spikes = false(length(o.W),floor(o.t_span/o.dt));
    
    
%% Now simulate the dyamics with Euler!
spike_timespan = 0:o.dt:30;
epsp = (1/(o.tau2_e-o.tau1))*(exp(-spike_timespan/o.tau2_e) - exp(-spike_timespan/o.tau1)); % Excitatory output waveform
ipsp = (1/(o.tau2_i-o.tau1))*(exp(-spike_timespan/o.tau2_i) - exp(-spike_timespan/o.tau1)); % Inhibitory output waveform
epsp(end+1) = 0;
ipsp(end+1) = 0;

if nargin < 2
    %define vector of inital cell voltages:
    V = rand(length(o.W),1);
    % V = zeros(length(o.W),1)+.2;
    
    
    %define vector of cells' synaptic output. This should be the length of
    %f_template:
    syn_out = zeros(length(o.W), 1);
    
    %initialize synaptic input vector ON TO each cell:
    syn_idx = repmat(length(epsp), length(o.W), 1);
    

    %add in o.refractory counter:
%     refract_counter = zeros(length(o.W),1);
    refract_counter = randi(25,length(o.W),1)-10;
end
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
    
    % DLM input
    if ~isempty(o.stimulusMatrix)
        Isyn(1:o.Ne) = Isyn(1:o.Ne) + o.stimulusMatrix(:,i);
    end
    
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









