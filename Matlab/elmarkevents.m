function data = elmarkevents(data, events)

if islogical(events) % If supplied events parameter is a logical matrix...
    events = find(events); % Convert to nunmeric indices
end
for ev = events % For each event...
    [~, i] = min(abs([data.Time] - ev)); % Find the timestamp closest to the event
    data(i).Event = true; % Mark an event at that time
end
