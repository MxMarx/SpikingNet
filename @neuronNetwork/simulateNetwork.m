function o = simulateNetwork(o,varargin)

p = inputParser;
p.addParameter('plasticity',false);
p.parse(varargin{:});

%% Now simulate the dyamics with Euler!
spike_timespan = 0:o.dt:30;
epsp = (1/(o.tau2_e-o.tau1))*(exp(-spike_timespan/o.tau2_e) - exp(-spike_timespan/o.tau1)); % Excitatory output waveform
ipsp = (1/(o.tau2_i-o.tau1))*(exp(-spike_timespan/o.tau2_i) - exp(-spike_timespan/o.tau1)); % Inhibitory output waveform
epsp(end+1) = 0;
ipsp(end+1) = 0;

%define vector of inital cell voltages:
V = rand(length(o.W),1)+.2;

%define vector of cells' synaptic output. This should be the length of
%f_template:
syn_out = zeros(length(o.W), 1);

%initialize synaptic input vector ON TO each cell:
syn_idx = repmat(length(epsp), length(o.W), 1);

% build matrix to save voltages:
o.voltageHistory = zeros(length(o.W),round(o.t_span/o.dt));
o.syn_out_history = zeros(length(o.W),round(o.t_span/o.dt));
% initialize matrix to save spike times:
o.spikes = false(length(o.W),floor(o.t_span/o.dt));

%add in o.refractory counter:

refract_counter = zeros(length(o.W),1);

if p.Results.plasticity
    o.W = full(o.W);
end
%now run the dynamics:

j = o.excitatory_idx;

for i = 1:o.t_span/o.dt
    
    %update  syn_out:
    syn_idx = min(syn_idx + 1, length(ipsp));
    syn_out(o.excitatory_idx) = epsp(syn_idx(o.excitatory_idx));
    syn_out(o.inhibitory_idx) = ipsp(syn_idx(o.inhibitory_idx));
    o.syn_out_history(:,i) = syn_out;
    %update o.refractory counter:
    refract_counter = refract_counter-1;
    
    %assign Isyn:
    Isyn = (syn_out' * o.W)';
    
    v_old = V; %keep record of previous value
    
    
    % Stimulate the network
    if ~mod(i+10,round(1000/o.dt))
        Isyn(randsample(1:o.Ne, round(o.Ne/8))) = 1 / o.dt;
    end
%     
%     if ~mod(i,round(500/o.dt))
%         Isyn(randsample(1:o.Ne, round(o.Ne/10))) = 1 / o.dt;
%     end
%     
    
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
    
    % Spike-timing dependent plasticity
    if p.Results.plasticity && any(o.spikes(j,i)) && i > o.t_span/o.dt/5
        spike_idx = o.spikes(j,i);
        
        o.W(j,spike_idx) = o.W(j,spike_idx) + .02*(~~o.W(j,spike_idx)).*syn_out(j);
        o.W(spike_idx,j) = o.W(spike_idx,j) - .04*(~~o.W(spike_idx,j)).*syn_out(j)';

% 
%         
%         newVals = o.W(j,spike_idx) + .04*(~~o.W(j,spike_idx)).*syn_out(j);
%         newVals = min(newVals,.3);
%         o.W(j,spike_idx) = newVals;
%         
%         newVals = o.W(spike_idx,j) - .04*(~~o.W(spike_idx,j)).*syn_out(j)';
%         deleted = sum(sum(newVals<0));
%         newVals = max(newVals,0);
%         o.W(spike_idx,j) = newVals;

        o.W(spike_idx,j) = max(o.W(spike_idx,j),0);
        o.W(j,spike_idx) = min(o.W(j,spike_idx),.5);
%         
% 
%         c = randsample(o.Ne,min(deleted*2,o.Ne-1));
%         ind = sub2ind([o.N,o.N],c(1:2:end-1),c(2:2:end));
%         o.W(ind) = .1;
    end
    
    
    if ~mod(i,1000)
        disp(i / (o.t_span/o.dt))
%         disp(nnz(o.W(o.excitatory_idx,o.excitatory_idx)))
        disp(sum(refract_counter > 0))
    end
end


spikes = cell(size(o.N));
for i = 1:length(o.W)
    spikes{i} = find(o.spikes(i,:)) * o.dt;
end
o.spikes = spikes;



