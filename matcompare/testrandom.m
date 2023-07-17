trials = 10000;
counter = 1;

outs = zeros(1,trials-1);

while counter < trials;
    out = randomcompare();
    outs(counter) = out;

    counter = counter + 1
end


std(outs)
histogram(outs)