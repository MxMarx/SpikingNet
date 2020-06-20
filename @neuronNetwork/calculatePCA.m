function [eigValues, eigVectors, momentOfInertia, centroid] = calculatePCA(o)
% https://stats.stackexchange.com/questions/61225/correct-equation-for-weighted-unbiased-sample-covariance

% Calculate the principle components of the network's activity, as well as
% the moment of inertia.

% Allocate variables
momentOfInertia = zeros(size(o.syn_out_history,2), 1);
eigValues = zeros(size(o.neuronCoordinates,2), size(o.syn_out_history,2));
eigVectors = zeros(size(o.neuronCoordinates,2), size(o.neuronCoordinates,2), size(o.syn_out_history,2));

% Create a vector of weights by using o.syn_out_history, the vector of
% EPSPs. I could have instead convolved the spikes with a gaussian, but I
% had a variable containing the synaptic output of each neuron which makes
% things a little more convenient.
weights = o.syn_out_history(o.excitatory_idx, :) ./  sum(o.syn_out_history(o.excitatory_idx, :));
weights(isnan(weights)) = 0;

% Calculate the center of the activity by multiplying the matrix of coordinates with these weights 
centroid = o.neuronCoordinates' * weights;

weightsMask = o.syn_out_history(o.excitatory_idx, :) > 0.05;

for i = 1:size(o.syn_out_history,2)
    
    % Center the coordinates around the centroid
    centeredCoordinates = o.neuronCoordinates - centroid(:,i)';
    % Calculate the weighted covariance matrix
    weightedCov = (weights(:,i) .* centeredCoordinates)' * centeredCoordinates ;

    % Get the eigenvectors of the covariance matrix and sort them
    [eigVector, eigValue] = eig(weightedCov);
    [eigValue, idx] = sort(diag(eigValue), 'descend');
    eigVectors(:,:,i) = eigVector(:, idx);
    eigValues(:,i) = eigValue;
    
    % Calculate the moment of inertia as the sum of squared distance from
    % the centroid.
%     momentOfInertia(i) = sumsqr(centeredCoordinates .* weights(:,i) );
%     momentOfInertia(i) = sum(vecnorm(centeredCoordinates .* weightsMask(:,i),2,2)) ./ sum( weightsMask(:,i));
%         momentOfInertia(i) = sum(vecnorm(centeredCoordinates .* weights(:,i),2,2)) ;

    momentOfInertia(i) = mean(vecnorm(centeredCoordinates(weightsMask(:,i),:), 2, 2));

end

% Weird stuff happens with infinate values, this fixes it
eigVectors = real(eigVectors);
eigValues = abs(real(eigValues));



