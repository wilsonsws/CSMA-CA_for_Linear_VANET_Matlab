
function y = Pop(PacketBuff,n)
PacketBuff(n,:) = [PacketBuff(n,1),PacketBuff(n,3:1501),0];%数据发送成功后，修改缓存器中的值
PacketBuff(n,1) = PacketBuff(n,1) - 1;
y = PacketBuff;
