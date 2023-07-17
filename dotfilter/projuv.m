function out = projuv(u,v) %Project vector v onto u
    udotv = sum(eucdot(u,v), 'all');
    udotu = sum(eucdot(u,u), 'all');

    N = udotv/udotu;
    p = N;
    out = p;
end