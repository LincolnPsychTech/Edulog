function [tonic, phasic] = elsplitgsr(data)

tonic = data;
phasic = data;

t = [NaN, diff(log([data.GSR]))];
for n = 1:length(data)
    tonic(n).GSR = t(n);
end

p = log([data.GSR]) - t;
for n = 1:length(data)
    phasic(n).GSR = p(n);
end

line([data.Time], [phasic.GSR])
