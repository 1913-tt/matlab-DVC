function [seq]=re_bit_plane(bit_stream,q)
%     len=length(bit_stream);
%     bit_stream=reshape(bit_stream,len/q,q);
%     bit_stream=bit_stream';
    len=size(bit_stream,2);
    seq=zeros(1,len);
    for k=1:q
       for i=1:len
          seq(i)=bit_stream(k,i)*2^(q-k)+seq(i);
       end
    end
    %bit_stream=logic(bit_stream);
end