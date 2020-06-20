classdef neuronNetwork < handle
    %UNTITLED3 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        
        % ratio of mean to std for the out degree
        sigma = 1
        % Coordinates of the neurons in space
        neuronCoordinates = [];
        
        stimulusMatrix = [];
        stimulusTrain = [];
        
        %% Set the options
        
        % Save figures
        saveFigures = false
        saveDirectory = 'C:\Users\russe\OneDrive - UW\Grad School\Fairhall Lab\Figures'
        
        % Total number of neurons
        N = 1000;
        proportion_e = 0.75;
        
        % Number of clusters
        clusters = 1;
        clusterIndex = [];
        
        % p_ee within cluster / p_ee between cluster
        cluster_p_ratio = 2.5;
        cluster_w_ratio = 1.9; % ratio of within/between cluster weights
        
        %define numbers of connections per neuron of connection:
        p_ee = 100;
        p_ii = 200;
        p_ei = 200; %probablity of excitatory neuron connecting to inhibitory neuron
        p_ie = 200; %probablity of inhibitory neuron connecting to excitatory neuron
%         %define probabilities of connection:
%         p_ee = .1;
%         p_ii = .2;
%         p_ei = .2; %probablity of excitatory neuron connecting to inhibitory neuron
%         p_ie = .2; %probablity of inhibitory neuron connecting to excitatory neuron
        
        %define connection strengths:
        W_ee = 0.024;
        W_ei = 0.045;
        W_ie = -0.044;
        W_ii = -.057;
        
        %define range of biases
        mu_e_range = [1.1, 1.2];
        mu_i_range = [1.0, 1.05];
        
        %define time constants
        tau_e = 15; % excitatory time constant in units of ms
        tau_i = 10; % inhibitory time constant in units of ms
        
        Ne % Number of excitatory neurons
        Ni % Number of inhibitory neurons
        excitatory_idx % Index of e neurons
        inhibitory_idx % Index of i neurons
        
        W % Weight matrix
        mu % Bias vector
        tau % Time constant vector
        
        
        refractory = 5; %refractory period in units of ms
        
        %define total time of sim:
        t_span = 5000; %total time of ms of simulation
        
        dt = .2; %time step in units of ms.
        
        %build the additive waveform that follows a spike:
        tau1 = 1;
        tau2_e = 3;
        tau2_i = 2;
        
        % Make the time constants 10-15 ms
        
        V_thr = 1; %threshhold for spiking in non-dimensional units
        V_reset = 0; %in non-dimensional units
        
        voltageHistory
        syn_out_history
        spikes
        
        neuron_names
    end
    
    methods
        function o = neuronNetwork()
        end
    end
end

