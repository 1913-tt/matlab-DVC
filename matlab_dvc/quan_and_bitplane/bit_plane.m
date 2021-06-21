function [bit_stream]=bit_plane(seq,q)
    len=length(seq);
    bit_stream=zeros(q,len,'uint8');
    for k=1:q
       for i=1:len
          bit_stream(k,i)=bitget(seq(i),q+1-k); 
       end
    end
    %bit_stream=logic(bit_stream);
%     bit_stream=bit_stream';
%     bit_stream=bit_stream(:)';
end