function [shuffled_vector_lengths, shuffled_vector_dirs, p_val] = get_shuffled_vectors(time_points, in_data, n_shuffles, shuffle_mode, detrend, stat)
% function [SHUFFLED_VECTOR_LENGTHS, SHUFFLED_VECTOR_DIRS, P_VAL] = get_shuffled_vectors(TIME_POINTS, IN_DATA, N_SHUFFLES, SHUFFLE_MODE, DETREND, STAT)
% 
% Get the circadian resultant vectors for shuffled data, and compare the
% actual resultant vector length with the distribution from the shuffled
% data to obtain a p-value P_VAL that represents the probability of
% observing a circadian vector of this length in the shuffled distribution.
% 
% Returns SHUFFLED_VECTOR_LENGTHS and SHUFFLED_VECTOR_DIRS which together
% specify the resultant vectors for the shuffled data.
% 
% The number of shuffles is determined by N_SHUFFLES, and SHUFFLE_MODE
% provides the option of shuffling all data points within each day
% ('complete') or whether to apply a random circular shift to all values
% within each day ('circshift') so as to preserve any local correlations in
% the signal apart from those determined by time of day.
% 
% Data can be normalised within-day using the DETREND option, to ensure
% that trends 
% 
% INPUTS:
% 
% TIME_POINTS: A vector of datetimes or durations specifying the times at
% which events or measurements occurred.
% 
% IN_DATA: A vector of values equal in size to IN_TIMES, corresponding to 
% the value / weight associated with each time point.
% 
% N_SHUFFLES: How many times should the data be shuffled? Larger numbers of
% shuffles will result in a better approximation of the p-value but take
% longer. Defaults to 1000.
% 
% SHUFFLE_MODE: 'complete' for complete shuffle of all values within each
% day, or 'circshift' for 
% 
% DETREND: true or false. If true, will remove variability between days by
% dividing each day by its mean or median value (mean vs. median determined
% by STAT).
% 
% STAT: What summary statistic to use for de-trending the data - options
% are 'mean' or 'median'.
% 
% 
% OUTPUTS:
% 
% SHUFFLED_VECTOR_LENGTHS: N_SHUFFLES x 1 vector with 1 circadian resultant
% vector length for each shuffled data set.
% 
% SHUFFLED_VECTOR_DIRS: N_SHUFFLES x 1 vector with 1 circadian resultant
% vector direction (as radian angle) for each shuffled data set.
% 
% P_VAL: p value of observing a circadian resultant vector of the same
% length as that obtained from the non-shuffled data set or greater in the 
% shuffled distribution.
% 
% 
% Joram van Rheede, 2021

% If no n_shuffles has been specified, default to 1000
if nargin < 3 || isempty(n_shuffles)
    n_shuffles = 1000;
end

% Default to complete shuffle rather than circshift
if nargin < 4
    shuffle_mode = 'complete';
end

% Don't normalise within day by default
if nargin < 5
    detrend = false;
end

% Default to using 'mean' for normalising values within each day
if nargin < 6
    stat = 'mean';
end

% pre-allocate the vector lengths and vector dirs for each shuffle
shuffled_vector_lengths  = NaN(n_shuffles, 1);
shuffled_vector_dirs     = NaN(n_shuffles, 1);
for a = 1:n_shuffles
    
    if mod(a,100) == 0
        disp([num2str(a) ' shuffles complete...'])
    end
    
    % Get shuffled data points
    shuffled_data_points    = within_day_shuffle(time_points, in_data, shuffle_mode, detrend, stat);
    
    % Calculate resultant vector
    [shuffled_vector_lengths(a), shuffled_vector_dirs(a)] = circadian_vect(time_points,shuffled_data_points);
    
end

% Get vector length for original data
vector_length   = circadian_vect(time_points, in_data);

% Get p-value of original vector compared to the distribution of shuffled 
% vectors:
p_val = sum(shuffled_vector_lengths > vector_length) / n_shuffles;