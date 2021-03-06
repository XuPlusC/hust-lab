% design2_5.m

sym t;
f=sym('exp(-1*t)*Heaviside(t)');  % 信号的符号表达式
F=fourier(f);  % 得到 Fourier 变换的符号表达式
FF=maple('convert',F,'piecewise');  % 对 Fourier 变换的符号表达式进行转换，使其便于画图
FFF=abs(FF);  % 得到频谱符号表达式
figure
subplot(1,2,1)
ezplot(f,[-10*pi,10*pi])
title('时域波形 f(t)');
subplot(1,2,2)
ezplot(FFF,[-pi,pi])
title('频域波形 F(jw)');