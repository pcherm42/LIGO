function out = peakmaker(data, halfwidth, height, centerindex)

    ini=zeros(size(data));
    left_edge = centerindex - halfwidth;
    right_edge = centerindex + halfwidth;
    slope = height/halfwidth;


    for x = 1:length(data)
        val = 0;
        if ( left_edge < x ) && ( x < centerindex )
            val = slope*(x - left_edge);
        end
        if x == centerindex
            val = height;
        end
        if (centerindex < x) && (x < right_edge)
            val = height - slope*(x-centerindex);
        end
        ini(x) = val;
    end

    final = ini + data;
    out = final;

end