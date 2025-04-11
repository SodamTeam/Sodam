'use client'

export default function MainScreen() {
  return (
    <div className="w-96 h-[812px] relative bg-white overflow-hidden">
    <div className="w-96 h-11 left-0 top-0 absolute overflow-hidden">
        <div className="w-5 h-3 left-[336px] top-[17.33px] absolute opacity-30 rounded-sm border border-black" />
        <div className="w-[1.33px] h-1 left-[359px] top-[21px] absolute opacity-40 bg-black" />
        <div className="w-4 h-2 left-[338px] top-[19.33px] absolute bg-black rounded-sm" />
        <div className="w-14 h-5 left-[21px] top-[12px] absolute rounded-[32px]">
            <div className="w-7 h-3 left-[12.45px] top-[5.17px] absolute bg-black" />
        </div>
    </div>
    <div className="w-96 h-14 left-0 top-[44px] absolute">
        <img className="w-6 h-6 left-[335px] top-[16px] absolute rounded-full" src="https://placehold.co/24x24" />
        <div className="left-[151px] top-[14px] absolute text-center justify-start text-black text-xl font-semibold font-['Inter'] leading-7">Sodam</div>
        <div className="w-6 h-6 left-[16px] top-[16px] absolute">
            <div className="w-4 h-0.5 left-[3.10px] top-[5.10px] absolute bg-black" />
            <div className="w-3.5 h-0.5 left-[3.10px] top-[11.10px] absolute bg-black" />
            <div className="w-4 h-0.5 left-[3.10px] top-[17.10px] absolute bg-black" />
        </div>
        <div className="w-4 h-5 left-[308px] top-[19px] absolute outline outline-2 outline-offset-[-1px] outline-Main-bulma" />
    </div>
    <div className="left-[99px] top-[133px] absolute justify-start text-black text-4xl font-semibold font-['Inter']">안녕하세요!</div>
    <div className="left-[67px] top-[192px] absolute justify-start text-black text-2xl font-medium font-['Inter']">맞춤형 챗봇을 선택해봐!</div>
    <div className="w-80 left-[19px] top-[738px] absolute inline-flex flex-col justify-start items-start gap-2">
        <div className="self-stretch pl-3 pr-4 py-3 bg-Main-gohan rounded-lg outline outline-1 outline-offset-[-1px] outline-Main-beerus inline-flex justify-start items-center gap-2">
            <div className="w-6 h-6 relative">
                <div className="w-3.5 h-3.5 left-[5.25px] top-[5.25px] absolute outline outline-[0.75px] outline-offset-[-0.38px] outline-Main-bulma" />
            </div>
            <div className="flex-1 justify-center text-Main-trunks text-base font-normal font-['DM_Sans'] leading-normal">무엇을 도와드릴까요?</div>
            <div className="justify-center text-Main-trunks text-sm font-normal font-['DM_Sans'] leading-tight">지우기</div>
        </div>
    </div>
    <div className="w-36 h-14 left-[114px] top-[233px] absolute bg-blue-200 rounded-3xl">
        <div className="w-36 h-36 left-[13.64px] top-[40.04px] absolute rounded-[10px]" />
        <div className="left-[35.16px] top-[20.21px] absolute justify-start text-black text-base font-bold font-['Inter']">AI 챗봇 선택</div>
    </div>
    <div className="w-96 h-96 left-[7px] top-[304px] absolute bg-Grays-Gray-3 rounded-[34.42px]" />
    <div className="w-80 h-12 left-[19px] top-[314px] absolute bg-Grays-Gray-3">
        <div className="w-28 h-14 left-[65.05px] top-[3.01px] absolute bg-blue-200 rounded-3xl shadow-[0px_4px_4px_0px_rgba(0,0,0,0.25)]" />
        <div className="w-10 h-9 left-[9px] top-[8px] absolute rounded-full">
            <img className="w-12 h-14 left-0 top-0 absolute rounded-full" src="https://placehold.co/50x53" />
        </div>
        <div className="w-32 h-6 left-[75px] top-[26px] absolute justify-start"><span className="text-black text-[10px] font-bold font-['Inter']">📖</span><span className="text-black text-[8px] font-bold font-['Inter']"> - 문학소녀 미소녀 하린</span></div>
    </div>
    <div className="w-16 h-1.5 left-[156px] top-[646px] absolute bg-Grays-Gray-3 inline-flex justify-start items-start gap-1.5">
        <div className="w-8 h-1.5 bg-white rounded-lg" />
        <div className="w-2 h-1.5 bg-white/50 rounded-lg" />
        <div className="w-2 h-1.5 bg-white/50 rounded-lg" />
        <div className="w-2 h-1.5 bg-white/50 rounded-lg" />
    </div>
</div>
  )
}