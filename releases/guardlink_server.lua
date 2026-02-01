return {
  ["author"] = "glittershitter",
  ["cct"] = "1.113.1",
  ["version"] = 0.1,
  ["changelog"] = {
    ["1"] = "First alpha release, expect things to break",
  },
  ["date"] = "2026-02-01T21:35:04",
  ["checksum"] = "8b8474cec3df55ecfefa17d9d00b78248725724db1441b2e79eb2f495d0ea577",
  ["target"] = "server",
  ["files"] = {
    ["server/ui/shell.lua"] = "local a;local b;local c={}for d,e in ipairs(fs.list(\"/GuardLink/server/commands\"))do local f=require(\"commands.\"..e:sub(1,#e-4))c[f.name]=f end;local function g()local h=a.mainframe:addFrame():setSize(\"parent.w\",\"parent.h - 1\"):setPosition(1,2):setVisible(true):setZIndex(1)b=h;local i=h:addProgram():setSize(\"parent.w\",\"parent.h\"):setPosition(1,1)i:execute(function()local function j(k)local l={}for m in k:gmatch(\"%S+\")do table.insert(l,m)end;return table.remove(l,1),l end;term.setBackgroundColor(colors.black)term.setTextColor(_G.theme.colors.highlight)write(\"> \")term.setTextColor(colors.white)while true do local k=read()if k and k~=\"\"then local n,l=j(k)local f=c[n]if f then local o,p=pcall(f.run,l)if not o then term.setTextColor(colors.red)print(\"Error: \"..tostring(p))term.setTextColor(colors.white)end else term.setTextColor(colors.red)print(\"Unknown command: \"..n..\", type 'help'!\")term.setTextColor(colors.white)end end;term.setTextColor(_G.theme.colors.highlight)write(\"> \")term.setTextColor(colors.white)end end)end;local function q()b:setVisible(false)b:remove()end;local function r(s)a=s end;return{displayName=\"Shell\",add=g,remove=q,setContext=r}\
",
    ["server/modules/wallet.lua"] = "local a=require\"modules.account\"local b=require\"lib.errors\"local c={}if not _G.vfs:existsDir(\"wallets\")then _G.logger:fatal(\"[walletManager] Failed to load walletManager: malformed partitions?\")error(\"Failed to load walletManager: malformed partitions?\")end;local d={id=\"\",name=\"\",members={},balance=0,locked=false,creationDate=\"\",creationTime=\"\"}function c.getTemplate()return _G.utils.deepCopy(d)end;function c.isValidWalletName(e)if not e or e:match(\"^%s*$\")then return b.WALLET_NAME_EMPTY end;if e:find(\"[/\\\\:*?\\\"<>|]\")then return b.WALLET_INVALID_CHAR end;if#e>20 then return b.WALLET_NAME_TOO_LONG end;if#e<3 then return b.WALLET_NAME_TOO_SHORT end;if _G.vfs:existsFile(\"wallets/\"..e..\".json\")then return b.WALLET_EXISTS end;return 0 end;function c.exists(e)return _G.vfs:existsFile(\"wallets/\"..e..\".json\")end;function c.createWallet(e)local f=c.isValidWalletName(e)if f~=0 then return f end;local g=\"wallets/\"..e..\".json\"local h=c.getTemplate()h.name=e;h.id=_G.utils.randomString(16,\"generic\")h.creationDate=os.date(\"%Y-%m-%d\")h.creationTime=os.date(\"%H:%M:%S\")_G.vfs:newFile(g)_G.vfs:writeFile(g,textutils.serializeJSON(h))return 0 end;function c.getWalletData(e)if e then return textutils.unserializeJSON(_G.vfs:readFile(\"wallets/\"..e..\".json\"))else return nil end end;function c.getWalletValue(e,i)local j=c.getWalletData(e)if not j then return nil end;return j[i]end;function c.isLocked(e)return c.getWalletValue(e,\"locked\")end;function c.deleteWallet(e)if not c.exists(e)then return b.WALLET_NOT_FOUND end;local k=c.getWalletData(e)for l,m in pairs(k.members)do local n=a.getAccountData(l)or{}for o=#n.wallets,1,-1 do if n.wallets[o]==k.id then table.remove(n.wallets,o)end end;a.setAccountValue(l,\"wallets\",n.wallets)end;_G.vfs:deleteFile(\"wallets/\"..e..\".json\")return 0 end;function c.setWalletValue(e,i,p)if not c.exists(e)then return b.WALLET_NOT_FOUND end;local j=c.getWalletData(e)j[i]=p;_G.vfs:writeFile(\"wallets/\"..e..\".json\",textutils.serializeJSON(j))return 0 end;function c.listWallets()local q={}local r=_G.vfs:listDir(\"wallets/\")or{}for m,s in ipairs(r)do if s:sub(-5)==\".json\"then table.insert(q,s:sub(1,-6))end end;return q end;function c.addMember(e,l,t)if not c.exists(e)then return b.WALLET_NOT_FOUND end;if c.isLocked(e)then return b.WALLET_LOCKED end;local u=c.getWalletValue(e,\"members\")or{}if u[l]then return b.WALLET_MEMBER_EXISTS end;if t~=\"owner\"and t~=\"associate\"then return b.WALLET_INVALID_ROLE end;if not a.exists(l)then return b.WALLET_ACCOUNT_NOT_FOUND end;u[l]=t;c.setWalletValue(e,\"members\",u)local v=a.getAccountValue(l,\"wallets\")or{}table.insert(v,c.getWalletValue(e,\"name\"))a.setAccountValue(l,\"wallets\",v)return 0 end;function c.removeMember(e,l)if not c.exists(e)then return b.WALLET_NOT_FOUND end;if c.isLocked(e)then return b.WALLET_LOCKED end;local u=c.getWalletValue(e,\"members\")or{}if not a.exists(l)then return b.WALLET_ACCOUNT_NOT_FOUND end;u[l]=nil;c.setWalletValue(e,\"members\",u)local v=a.getAccountValue(l,\"wallets\")or{}local w=c.getWalletValue(e,\"name\")for o=#v,1,-1 do if v[o]==w then table.remove(v,o)end end;a.setAccountValue(l,\"wallets\",v)return 0 end;function c.lockWallet(e,x)if not c.exists(e)then return b.WALLET_NOT_FOUND end;c.setWalletValue(e,\"locked\",x or true)return 0 end;function c.changeBalance(y,e,p)if c.isLocked(e)then return b.WALLET_LOCKED end;if not c.exists(e)then return b.WALLET_NOT_FOUND end;local k=c.getWalletData(e)if y==\"set\"then k.balance=p elseif _G.utils.isInteger(p)then if y==\"add\"then k.balance=k.balance+p elseif y==\"subtract\"then k.balance=k.balance-p end else return b.BALANCE_INVALID_OPERATION end;_G.vfs:writeFile(\"wallets/\"..e..\".json\",textutils.serializeJSON(k))return 0 end;function c.transferBalance(z,A,p)if p<=0 or _G.utils.isInteger(p)==false or not p then return b.TRANSACTION_INVALID_NUMBER end;if not c.exists(z)then return b.TRANSACTION_UNKNOWN_SENDER end;if not c.exists(A)then return b.TRANSACTION_UNKNOWN_RECEIVER end;if z==A then return b.TRANSACTION_TRANSFER_TO_SELF end;local B=c.getWalletValue(z,\"balance\")if B<p then return b.INSUFFICIENT_FUNDS end;local C=c.changeBalance(\"subtract\",z,p)local D=c.changeBalance(\"add\",A,p)if C~=0 then return C end;if D~=0 then return D end;return 0 end;return c\
",
    ["server/lib/errors.lua"] = "local a={ACCOUNT_EXISTS={client=\"ACCOUNT_EXISTS\",log=\"[AccountManager] Failed to create account: Already exists! \"},ACCOUNT_NAME_EMPTY={client=\"ACCOUNT_NAME_EMPTY\",log=\"[accountManager] Failed to create account: Name cannot be empty! \"},ACCOUNT_PASSWORD_EMPTY={client=\"ACCOUNT_PASSWORD_EMPTY\",log=\"[accountManager] Failed to create account: Password cannot be empty! \"},ACCOUNT_INVALID_CHAR={client=\"ACCOUNT_INVALID_CHAR\",log=\"[accountManager] Failed to create account: Name contains invalid characters! \"},ACCOUNT_NOT_FOUND={client=\"ACCOUNT_NOT_FOUND\",log=\"[accountManager] Account could not be found! \"},ACCOUNT_NAME_TOO_LONG={client=\"ACCOUNT_NAME_TOO_LONG\",log=\"[accountManager] Failed to create account: name too long! \"},ACCOUNT_NAME_TOO_SHORT={client=\"ACCOUNT_NAME_TOO_SHORT\",log=\"[accountManager] Failed to create account: name too short! \"},WALLET_EXISTS={client=\"WALLET_EXISTS\",log=\"[WalletManager] Failed to create wallet: Already exists! \"},WALLET_NAME_EMPTY={client=\"WALLET_NAME_EMPTY\",log=\"[WalletManager] Failed to create wallet: Name cannot be empty! \"},WALLET_INVALID_CHAR={client=\"WALLET_INVALID_CHAR\",log=\"[WalletManager] Failed to create wallet: Name contains invalid characters! \"},WALLET_MEMBER_EXISTS={client=\"WALLET_MEMBER_EXISTS\",log=\"[WalletManager] Failed to add member to wallet: Already a member! \"},WALLET_INVALID_ROLE={client=\"WALLET_INVALID_ROLE\",log=\"[WalletManager] Failed to add member to wallet: Invalid role! \"},WALLET_NOT_FOUND={client=\"WALLET_NOT_FOUND\",log=\"[WalletManager] Unknown error: Wallet could not be found! \"},WALLET_ACCOUNT_NOT_FOUND={client=\"WALLET_ACCOUNT_NOT_FOUND\",log=\"[WalletManager] Failed to add account to wallet: Account could not be found! \"},WALLET_LOCKED={client=\"WALLET_LOCKED\",log=\"[WalletManager] Failed to do operation: Wallet is locked! \"},WALLET_NAME_TOO_LONG={client=\"WALLET_NAME_TOO_LONG\",log=\"[WalletManager] Failed to create wallet: name too long! \"},WALLET_NAME_TOO_SHORT={client=\"WALLET_NAME_TOO_SHORT\",log=\"[WalletManager] Failed to create wallet: name too short! \"},BALANCE_INVALID_OPERATION={client=\"BALANCE_INVALID_OPERATION\",log=\"[WalletManager] Failed to modify balance: Invalid operation! \"},TRANSACTION_INVALID_NUMBER={client=\"TRANSACTION_INVALID_NUMBER\",log=\"[WalletManager] Failed to transfer balance: Invalid number! \"},TRANSACTION_UNKNOWN_SENDER={client=\"TRANSACTION_UNKNOWN_SENDER\",log=\"[WalletManager] Failed to transfer balance: Unknown sender! \"},TRANSACTION_UNKNOWN_RECEIVER={client=\"TRANSACTION_UNKNOWN_RECEIVER\",log=\"[WalletManager] Failed to transfer balance: Unknown receiver! \"},TRANSACTION_TRANSFER_TO_SELF={client=\"TRANSACTION_TRANSFER_TO_SELF\",log=\"[WalletManager] Failed to transfer balance: Cannot transfer to same wallet! \"},INSUFFICIENT_FUNDS={client=\"INSUFFICIENT_FUNDS\",log=\"[WalletManager] Failed to transfer balance: Insufficient funds! \"},DUPLICATE_CLIENT={client=\"DUPLICATE_CLIENT\",log=\"[clientManager] Failed to register client: already connected! \"},UNKNOWN_CLIENT={client=\"UNKNOWN_CLIENT\",log=\"[clientManager] Tried to modify unknown client! \"},SERVER_FULL={client=\"SERVER_FULL\",log=\"[clientManager] Failed to register client: max capacity reached! \"},CHANNEL_ALREADY_OPEN={client=\"CHANNEL_ALREADY_OPEN\",log=\"[networkSession] Failed to open port: port already open! \"},CHANNEL_ALREADY_CLOSED={client=\"CHANNEL_ALREADY_CLOSED\",log=\"[networkSession] Failed to open port: port already closed! \"},CHANNEL_CAPACITY_REACHED={client=\"CHANNEL_CAPACITY_REACHED\",log=\"[networkSession] Failed to open port: Channel capacity reached! \"},INVALID_MESSAGE_FORMAT={client=\"INVALID_MESSAGE_FORMAT\",log=\"[networkSession] Failed to create message: Invalid format! \"},QUEUE_FULL={client=\"QUEUE_FULL\",log=\"[requestQueue] Failed to add request: Queue full! \"},MALFORMED_MESSAGE={client=\"MALFORMED_MESSAGE\",log=\"[requestQueue] Failed to process request: Malformed message! \"},UNKNOWN_DISPATCHER={client=\"MALFORMED_MESSAGE\",log=\"[dispatcher] Failed to process message: Unknown action! \"},MISSING_PAYLOAD={client=\"MALFORMED_MESSAGE\",log=\"[dispatcher] Failed to process message: Missing payload! \"},TOKEN_MISMATCH={client=\"MALFORMED_MESSAGE\",log=\"[dispatcher] Failed to process message: Token mismatch! \"},UNKNOWN_UI={client=\"INTERNAL_ERROR\",log=\"[uiState] Failed to load UI: unknown path! \"}}return a\
",
    ["server/modules/dispatcher.lua"] = "local a=require\"lib.errors\"local b={}b.handlers={}b.callbacks={}b.path=\"/GuardLink/server/dispatchers/\"local c={accounts=require\"modules.account\",wallet=require\"modules.wallet\"}function b.new(d)b.session=d;local e=fs.list(b.path)for f,g in ipairs(e)do local h=g:gsub(\"%.lua$\",\"\")b.handlers[g]=require(b.path..h)end end;function b.register(i,j)b.handlers[i]=j end;function b.dispatch(k,l,m)if not b.handlers[k.action]or not k.action then return a.UNKNOWN_DISPATCHER end;if not k.payload then return a.MISSING_PAYLOAD end;if b.callbacks[m]then local n,o=pcall(b.callbacks[m],k,l,m,c,b.session)b.callbacks[m]=nil;if not n then return a.MALFORMED_MESSAGE end;if o~=0 then return o end else local o=b.handlers[k.action](k,l,m,c,b.session)if o~=0 then return o end end;return 0 end;function b.addCallback(m,j)b.callbacks[m]=j end;return b\
",
    ["server/lib/rsa-keygen.lua"] = "local function a(b)if b<0 then return math.ceil(b)+0 else return math.floor(b)end end;local function c(d,e)local b=d%e;if d<0 and b>0 then b=b-e end;return b end;local f=2^24;local g=a(math.sqrt(f))local h;local function j()local k={}setmetatable(k,h)k.comps={}k.sign=1;return k end;local function l(d)local k=j()k.sign=d.sign;local m=k.comps;local n=d.comps;for i=1,#n do m[i]=n[i]end;return k end;local function o(k,p)local m=k.comps;local q;for i=1,#m-1 do q=m[i]if q<0 then m[i+1]=m[i+1]+a(q/f)-1;q=c(q,f)if q~=0 then m[i]=q+f else m[i]=q;m[i+1]=m[i+1]+1 end end end;if m[#m]<0 then k.sign=-k.sign;for i=1,#m-1 do q=m[i]m[i]=f-q;m[i+1]=m[i+1]+1 end;m[#m]=-m[#m]end;for i=1,#m do q=m[i]if q>f then m[i+1]=(m[i+1]or 0)+a(q/f)m[i]=c(q,f)end end;if not p then for i=#m,2,-1 do if m[i]==0 then m[i]=nil else break end end end;if#m==1 and m[1]==0 and k.sign==-1 then k.sign=1 end end;local function r(d)local k=l(d)k.sign=-k.sign;return k end;local function s(d,e)local n,t=d.comps,e.comps;local u,v=d.sign,e.sign;if n==t then return 0 elseif u>v then return 1 elseif u<v then return-1 elseif#n>#t then return u elseif#n<#t then return-u end;for i=#n,1,-1 do if n[i]>t[i]then return u elseif n[i]<t[i]then return-u end end;return 0 end;local function w(d,e)return s(d,e)<0 end;local function x(d,e)return s(d,e)==0 end;local function y(d,e)return s(d,e)<=0 end;local function z(d,A)local k=l(d)if k.sign==1 then k.comps[1]=k.comps[1]+A else k.comps[1]=k.comps[1]-A end;o(k)return k end;local function B(d,e)if type(d)==\"number\"then return z(e,d)elseif type(e)==\"number\"then return z(d,e)end;local k=l(d)local C=k.sign==e.sign;local m=k.comps;for i=#m+1,#e.comps do m[i]=0 end;local t=e.comps;for i=1,#t do local q=t[i]if C then m[i]=m[i]+q else m[i]=m[i]-q end end;o(k)return k end;local function D(d,e)if type(e)==\"number\"then return z(d,-e)elseif type(d)==\"number\"then d=bigint(d)end;return B(d,r(e))end;local function E(d,e)local k=l(d)if e<0 then e=-e;k.sign=-k.sign end;local t=k.comps;for i=1,#t do t[i]=t[i]*e end;o(k)return k end;local function F(d,e)local k=j()local m=k.comps;local n,t=d.comps,e.comps;for i=1,#n+#t do m[i]=0 end;for i=1,#n do for G=1,#t do m[i+G-1]=m[i+G-1]+n[i]*t[G]end;o(k,true)end;o(k)if k~=bigint(0)then k.sign=d.sign*e.sign end;return k end;local function H(d,e)local n,t=d.comps,e.comps;local I,J=#d.comps,#e.comps;local k,K,L,M=j(),j(),j(),j()local N,O,P,Q=k.comps,K.comps,L.comps,M.comps;local A=a((math.max(I,J)+1)/2)for i=1,A do N[i]=i+A<=I and n[i+A]or 0;O[i]=i<=I and n[i]or 0;P[i]=i+A<=J and t[i+A]or 0;Q[i]=i<=J and t[i]or 0 end;o(k)o(K)o(L)o(M)local R=k*L;local S=K*M;local T=(k+K)*(L+M)-R-S;local U=T.comps;local V=R.comps;local W=S.comps;for i=1,#V+A*2 do W[i]=W[i]or 0 end;for i=1,#U do W[i+A]=W[i+A]+U[i]end;for i=1,#V do W[i+A*2]=W[i+A*2]+V[i]end;S.sign=d.sign*e.sign;o(S)return S end;local X=12;local function Y(d,e)if type(d)==\"number\"then return E(e,d)elseif type(e)==\"number\"then return E(d,e)end;if#d.comps<X or#e.comps<X then return F(d,e)end;return H(d,e)end;local function Z(_,a0)local k=l(_)if a0<0 then a0=-a0;k.sign=-k.sign end;local a1=0;local m=k.comps;for i=#m,1,-1 do a1=a1*f+m[i]m[i]=a(a1/a0)a1=c(a1,a0)end;o(k)return k end;local function a2(_,a0)local A=#a0.comps;local a3=Z(_,a0.comps[A])for i=A,#a3.comps do a3.comps[i-A+1]=a3.comps[i]end;for i=#a3.comps,#a3.comps-A+2,-1 do a3.comps[i]=nil end;local a4=a3*a0-_;if a4<a0 then quotient=a3 else quotient=a3-a2(a4,a0)end;return quotient end;local function a5(_,a0)if a0.comps[#a0.comps]<g then _=E(_,g)a0=E(a0,g)end;return a2(_,a0)end;local function a6(_,a0)if type(a0)==\"number\"then if a0==0 then error(\"divide by 0\",2)end;return Z(_,a0)elseif type(_)==\"number\"then _=bigint(_)end;local C=1;local a7=s(a0,bigint(0))if a7==0 then error(\"divide by 0\",2)elseif a7==-1 then C=-C;a0=r(a0)end;a7=s(_,bigint(0))if a7==0 then return bigint(0)elseif a7==-1 then C=-C;_=r(_)end;a7=s(_,a0)if a7==-1 then return bigint(0)elseif a7==0 then return bigint(C)end;local k;if#a0.comps==1 then k=Z(_,a0.comps[1])else k=a5(_,a0)end;if C==-1 then k=r(k)end;return k end;local a8=0;local function a9()a8=a8+1;if a8>=1000 then a8=0;write(\".\")sleep(0.01)end end;local function aa(k,ab)if ab<0 then ab=-ab end;local ac=1;local a1=0;local t=k.comps;for i=1,#t do a9()local q=t[i]a1=c(a1+q*ac,ab)ac=c(ac*f,ab)end;if k.sign<1 then a1=-a1 end;return a1 end;local function ad(k,ab)local a1=aa(k,ab)if a1<0 then a1=a1+ab end;return a1 end;local function a4(k,ab)if type(ab)==\"number\"then return bigint(aa(k,ab))elseif type(k)==\"number\"then k=bigint(k)end;return k-k/ab*ab end;local function ae(d,ab)local k=a4(d,ab)if k.sign==-1 then k=k+ab end;return k end;local af=10000000;local ag=string.format(\"%%.%dd\",math.log10(af))local function ah(k,ai)if k>=bigint(af)then ah(Z(k,af),ai)end;table.insert(ai,string.format(ag,ad(k,af)))end;local function aj(k)local ai={}if k<bigint(0)then k=r(k)table.insert(ai,\"-\")end;ah(k,ai)ai=table.concat(ai):gsub(\"^0*\",\"\")if ai==\"\"then ai=\"0\"end;return ai end;local function ak(k)return tonumber(aj(k))end;h={__add=B,__sub=D,__mul=Y,__div=a6,__mod=ae,__unm=r,__eq=x,__lt=w,__le=y,__tostring=aj}local al={}local am=0;function bigint(A)if al[A]then return al[A]end;local k;if type(A)==\"string\"then local an={A:byte(1,-1)}for i=1,#an do an[i]=string.char(an[i])end;local ao=1;local C=1;if an[i]=='-'then C=-1;ao=2 end;k=bigint(0)for i=ao,#an do k=z(E(k,10),tonumber(an[i]))end;k=E(k,C)else k=j()k.comps[1]=A;o(k)end;if am>100 then al={}am=0 end;al[A]=k;am=am+1;return k end;local ap=bigint(0)local aq=bigint(1)local function ar(d,e)if e~=ap then return ar(e,d%e)else return d end end;local function as(at,au,av)local a1=1;while true do if au%2==aq then a1=a1*at%av end;au=au/2;if au==ap then break end;at=at*at%av end;return a1 end;local function aw(ax,ay)if not ay then ay=999999999 end;local az=tostring(math.random(100000000,ay))while true do az=az..tostring(math.random(100000000,ay))if#az>=ax then local aA=az:sub(1,ax)if aA:sub(-1,-1)==\"2\"then return bigint(aA:sub(1,-2)..\"3\")elseif aA:sub(-1,-1)==\"4\"then return bigint(aA:sub(1,-2)..\"5\")elseif aA:sub(-1,-1)==\"6\"then return bigint(aA:sub(1,-2)..\"7\")elseif aA:sub(-1,-1)==\"8\"then return bigint(aA:sub(1,-2)..\"9\")elseif aA:sub(-1,-1)==\"0\"then return bigint(aA:sub(1,-2)..\"1\")else return bigint(aA)end end end end;local function aB(aC,aD)if aD<bigint(1000000000)then return bigint(math.random(ak(aC),ak(aD)))end;local aE=tostring(aD)local ay=tonumber(tostring(aD):sub(1,9))local aF=#aE-#tostring(aC)if aF==0 then return aw(#aE,ay)end;if#aE>30 then return aw(#aE-1)end;local aG=math.random(1,2^(#aE-1))for i=1,#aE-1 do if aG<=2^i then return aw(i)end end end;local function aH(A)if type(A)==\"number\"then A=bigint(A)end;if A%2==ap then return false end;local ai,aI=0,A-aq;while aI%2==ap do ai,aI=ai+1,aI/2 end;for i=1,3 do local d=aB(bigint(2),A-2)local b=as(d,aI,A)if b~=aq and b+1~=A then for G=1,ai do b=as(b,bigint(2),A)if b==aq then return false elseif b==A-1 then d=ap;break end end;if d~=ap then return false end end end;return true end;local function aJ()local i=0;while true do local aK=aw(39)if aH(aK)then return aK end end end;local function aL(aM)local aN;while true do aN=aJ()if ar(aM,aN-1)==aq then return aN end end end;local function aO(d,e)local b,aP,aQ,q=ap,aq,aq,ap;while d~=ap do local aR,a1=e/d,e%d;local ab,A=b-aQ*aR,aP-q*aR;e,d,b,aP,aQ,q=d,a1,aQ,q,ab,A end;return e,b,aP end;local function aS(d,ab)local aT,b,aP=aO(d,ab)if aT~=aq then return nil else return b%ab end end;local function aU()while true do local aM=aJ()write(\"-\")sleep(0.1)local aV=aL(aM)write(\"-\")sleep(0.1)local aR=aL(aM)write(\"-\")sleep(0.1)local A=aV*aR;local aW=(aV-1)*(aR-1)local aI=aS(aM,aW)local aX=as(bigint(104328),aM,A)local aY=as(aX,aI,A)write(\"+\")sleep(0.1)a8=0;if aY==bigint(104328)then a8=0;return{shared=tostring(A),public=tostring(aM)},{shared=tostring(A),private=tostring(aI)}end end end;local function aZ(a_)local b0=bigint(0)for i=1,#a_ do local b1=string.byte(a_,i)b0=b0*256+bigint(b1)end;return b0 end;local function b2(b3)local b4={}local b5=bigint(0)local b6=bigint(256)while b3>b5 do local b7=b3%b6;local b1=0;local b8=l(b7)while b8>bigint(0)do b8=b8-bigint(1)b1=b1+1 end;table.insert(b4,1,string.char(b1))b3=Z(b3-b7,256)end;return table.concat(b4)end;local function b9(ba,bb)local A=bigint(bb.shared)local aM=bigint(bb.public)local ab=aZ(ba)return tostring(as(ab,aM,A))end;local function bc(bd,be)local A=bigint(be.shared)local aI=bigint(be.private)local m=bigint(bd)local ab=as(m,aI,A)return b2(ab)end;return{generateKeyPair=aU,rsaEncrypt=b9,rsaDecrypt=bc}\
",
    ["server/network/requestQueue.lua"] = "local a=require\"lib.errors\"local b=require\"modules.dispatcher\"local c=require\"lib.rsa-keygen\"local d={}d.__index=d;function d.new(e,f)local self=setmetatable({},d)self.queue={}self.session=e or nil;b.new(self.session)self.queueSize=f.queue.queueSize or 40;self.paused=false;self.processedCount=0;self.throttle=0;self.lastProcessed=0;return self end;function d:setThrottle(g)self.throttle=(g or 0)*1000 end;function d:addRequest(h)if#self.queue+1>self.queueSize then return a.QUEUE_FULL end;local i=textutils.unserialize(h)if i.clientID and not self.session.clientManager:exists(i.clientID)then return a.UNKNOWN_CLIENT end;local j={id=i.id,message=i.message,client=i.clientID,timestamp=i.timestamp,isPlaintext=i.isPlaintext~=false}table.insert(self.queue,j)return 0 end;function d:processQueue()while true do if not self.paused then local k=os.epoch(\"utc\")local l={}if k-self.lastProcessed<(self.throttle or 0)*1000 then goto m end;self.lastProcessed=k;for n,o in ipairs(self.queue)do local p=o.client;local q=self.session.clientManager:getClient(p)if not q then if o.isPlaintext then _G.logger:debug(\"[requestQueue] Received plaintext message: \"..o.message)local r=b.dispatch(textutils.unserialize(o.message),nil,o.id)if r~=0 then _G.logger:debug(r[2])end else local s,t=pcall(function()return c.rsaDecrypt(o.message,self.session.privateKey)end)if s then _G.logger:debug(\"[requestQueue] Received RSA-encrypted message: \"..t)local r=b.dispatch(textutils.unserialize(t),nil,o.id)if r~=0 then _G.logger:debug(r[2])end else _G.logger:debug(\"[requestQueue] RSA decryption failed for unknown client! \")end end;table.insert(l,n)else if k-q.lastActivityTime>(q.throttle or 0)*1000 then local u=q.aesKey;local s,v=pcall(function()return u:decrypt(o.message)end)_G.logger:debug(\"[requestQueue] Received AES-encrypted message: \"..v)if not s or not v then _G.logger:debug(\"[requestQueue] AES decryption failed for \"..p)table.insert(l,n)goto w end;local t=textutils.unserialize(v)local r=b.dispatch(t,q,o.id)if r~=0 then _G.logger:debug(r[2])end;q.lastActivityTime=k;table.insert(l,n)end end::w::end;for x=#l,1,-1 do table.remove(self.queue,l[x])end end::m::os.sleep(0.01)end end;return d\
",
    ["server/lib/fileUtils.lua"] = "local a={}function a.read(b)if fs.exists(b)then local c=fs.open(b,\"r\")local d=c.readAll()c.close()return d end;return false end;function a.write(b,e)if fs.exists(b)then local c=fs.open(b,\"w\")c.write(e)c.close()return true end;return false end;function a.clear(b)a.write(b,\"\")end;function a.newFile(b)if not fs.exists(b)then local c=fs.open(b,\"w\")c.write(\"\")c.close()return true end;return false end;function a.delete(b)if fs.exists(b)then fs.delete(b)return true end;return false end;function a.append(b,e)if fs.exists(b)then local c=fs.open(b,\"a\")c.write(e)c.close()return true end;return false end;function a.makeDir(f)if not fs.exists(f)then fs.makeDir(f)end end;return a\
",
    ["server/modules/uiState.lua"] = "local a=require\"lib.errors\"local b={}b.__index=b;function b.new(c)local self=setmetatable({},b)self.basalt=require(\"lib.basalt\")self.uiHelper=require(\"lib.uiHelper\")self.path=c or\"/GuardLink/server/ui/\"self.x,self.y=term.getSize()self.mainframe=self.basalt.createFrame():setVisible(true):setZIndex(2)self.frames={}self.activeFrame=nil;self.titleBar=self.uiHelper.newLabel(self.mainframe,\"GLB 1.0.1\",1,1,51,1,colors.blue,colors.white,1)self.dropdown=self.mainframe:addDropdown():setForeground(colors.white):setBackground(colors.blue):setPosition(1,1):setSelectionColor(colors.blue,colors.orange)self.exitButton=self.uiHelper.newButton(self.mainframe,\"X\",51,1,1,1,colors.blue,colors.red)self.exitButton:onClick(function(d,e,f,g,h)os.shutdown()end)for d,i in ipairs(fs.list(self.path))do local j=i:gsub(\"%.lua$\",\"\")local k=require(self.path..j)k.setContext(self)self.frames[j]=k;self.dropdown:addItem(k.displayName,colors.blue,colors.white,j)end;self.dropdown:onChange(function(d,e,l)local m=self:setFrame(l.args[1])if m~=0 then self.uiHelper.newPopup(self.mainframe,25,5,\"Error\",\"error\",\"UI not found! :(\",true)end end)local m=self:setFrame(\"shell\")if m~=0 then self.uiHelper.newPopup(self.mainframe,25,5,\"Error\",\"error\",\"UI not found! :(\",true)end;return self end;function b:run()_G.utils.tryCatch(function()self.basalt.autoUpdate()end,function(n,o)_G.logger:fatal(\"[uiState] Basalt died.\")_G.logger:error(\"[uiState] Error:\"..n)error(n)end)end;function b:setFrame(j)if not self.frames[j]then return a.UNKNOWN_UI end;if self.activeFrame then self.activeFrame.remove()end;self.activeFrame=self.frames[j]self.frames[j].add(self)return 0 end;return b\
",
    ["server/config/themes.json"] = "{\
  \"default\": [\
    [\"primary\", \"0x3366CC\"],\
    [\"secondary\", \"0x99B2F2\"],\
    [\"tertiary\", \"0xF0F0F0\"],\
    [\"highlight\", \"0xF2B233\"],\
    [\"subtle\", \"0xD0D0D0\"],\
    [\"accent\", \"0x2A4D99\"]\
  ],\
  \"cyberpunk\": [\
    [\"primary\", \"0x1D1D2C\"],\
    [\"secondary\", \"0xA64DFF\"],\
    [\"tertiary\", \"0x4A90E2\"],\
    [\"highlight\", \"0xFF4081\"],\
    [\"subtle\", \"0x3C7BB1\"],\
    [\"accent\", \"0x0F0F18\"]\
  ],\
  \"darkmode\": [\
    [\"primary\", \"0x121212\"],\
    [\"secondary\", \"0xB0BEC5\"],\
    [\"tertiary\", \"0x333333\"],\
    [\"highlight\", \"0xBB86FC\"],\
    [\"subtle\", \"0x222222\"],\
    [\"accent\", \"0x0D0D0D\"]\
  ],\
  \"sunset\": [\
    [\"primary\", \"0x3D1C5D\"],\
    [\"secondary\", \"0xFF6F61\"],\
    [\"tertiary\", \"0xFFD54F\"],\
    [\"highlight\", \"0xFF8A80\"],\
    [\"subtle\", \"0xFFC107\"],\
    [\"accent\", \"0x2F1746\"]\
  ],\
  \"monochrome\": [\
    [\"primary\", \"0x121212\"],\
    [\"secondary\", \"0x424242\"],\
    [\"tertiary\", \"0xBDBDBD\"],\
    [\"highlight\", \"0xFFFFFF\"],\
    [\"subtle\", \"0x9E9E9E\"],\
    [\"accent\", \"0x0D0D0D\"]\
  ],\
  \"royal\": [\
    [\"primary\", \"0x1976D2\"],\
    [\"secondary\", \"0xFBC02D\"],\
    [\"tertiary\", \"0xFFFFFF\"],\
    [\"highlight\", \"0x7BB5FF\"],\
    [\"subtle\", \"0xE0E0E0\"],\
    [\"accent\", \"0x125F91\"]\
  ],\
  \"autumn\": [\
    [\"primary\", \"0x6E4B3A\"],\
    [\"secondary\", \"0xC75B35\"],\
    [\"tertiary\", \"0xA89F91\"],\
    [\"highlight\", \"0xFFB74D\"],\
    [\"subtle\", \"0x8D7A65\"],\
    [\"accent\", \"0x4B3929\"]\
  ],\
  \"emerald\": [\
    [\"primary\", \"0x2E7D32\"],\
    [\"secondary\", \"0x388E3C\"],\
    [\"tertiary\", \"0xC5E1A5\"],\
    [\"highlight\", \"0xFFD700\"],\
    [\"subtle\", \"0xA5D6A7\"],\
    [\"accent\", \"0x1D5A26\"]\
  ]\
}\
",
    ["server/modules/virtualFilesystem.lua"] = "local a=require\"lib.fileUtils\"local b={}b.__index=b;local c={\"Failed to write to file: Path could not be found!\",\"Failed to write to file: file size too big!\",\"Cannot delete partition folder: \"}function b.new(d)local self=setmetatable({},b)self.diskManager=d;self.config=self.diskManager:getConfig()return self end;function b:parsePath(e)local f={}e=e:gsub(\"//+\",\"/\"):gsub(\"/$\",\"\")for g in string.gmatch(e,\"[^/]+\")do table.insert(f,g)end;local h=f[1]local i=self.config[h]if not i then error(\"Failed to read path, partition not found: \"..h)end;return f,h,i end;function b:makeDir(e)local j,j,i=self:parsePath(e)for j,k in ipairs(i)do local l=self.diskManager:getDisks()[k.disk].path;a.makeDir(l..\"/\"..e)end;return true end;function b:existsFile(e)local f,j,i=self:parsePath(e)for j,k in ipairs(i)do local m=self.diskManager:getDisk(k.disk)local n=m.path..\"/\"..table.concat(f,\"/\")if fs.exists(n)then return m end end;return false end;function b:existsDir(e)local f,j,i=self:parsePath(e)for j,k in ipairs(i)do local m=self.diskManager:getDisk(k.disk)local n=m.path..\"/\"..table.concat(f,\"/\")if fs.exists(n)and fs.isDir(n)then return true end end;return false end;function b:getCapacity(h,k)for j,g in ipairs(self.config[h])do if g.disk==k then return g.bytes end end end;function b:writeFile(e,o)local j,h,j=self:parsePath(e)local k=self:existsFile(e)if not k then return{1,c[1]}end;local p=fs.getSize(k.path..\"/\"..h)local q=self:getCapacity(h,k.label)if p+#o>q then return{2,c[2]}end;a.write(k.path..\"/\"..e,o)return{0}end;function b:newFile(e)if not self:existsFile(e)then local j,r,i=self:parsePath(e)local s=nil;local t=0;for j,k in ipairs(i)do local m=self.diskManager:getDisk(k.disk)local p=fs.getSize(m.path..\"/\"..r)local u=self:getCapacity(r,k.disk)-p;if u>t then t=u;s=m end end;if not s or t<=0 then return false end;return a.newFile(s.path..\"/\"..e)end;return false end;function b:deleteFile(e)local k=self:existsFile(e)if k then return a.delete(k.path..\"/\"..e)end end;function b:deleteDir(e)local f,h,i=self:parsePath(e)if#f==1 then error(c[3]..h..\"!\")end;local v=true;for j,k in ipairs(i)do local m=self.diskManager:getDisk(k.disk)local n=m.path..\"/\"..e;if fs.exists(n)then local w=a.delete(n)if not w then v=false end end end;return v end;function b:readFile(e)local k=self:existsFile(e)if not k then return nil end;return a.read(k.path..\"/\"..e)end;function b:appendFile(e,o)local k=self:existsFile(e)if not k then return{1,c[1]}end;local p=fs.getSize(k.path..\"/\"..e)local j,h,j=self:parsePath(e)local q=self:getCapacity(h,k.label)if p+#o>q then return{2,c[2]}end;a.append(k.path..\"/\"..e,o)return{0}end;function b:listDir(e)local f,h,i=self:parsePath(e)local x={}for j,k in ipairs(i)do local m=self.diskManager:getDisk(k.disk)local n=m.path..\"/\"..e;if fs.exists(n)then for j,r in ipairs(fs.list(n))do table.insert(x,r)end end end;return#x>0 and x or nil end;return b\
",
    ["server/lib/uiHelper.lua"] = "local a={}function a.newLabel(b,c,d,e,f,g,h,i,j)return b:addLabel():setText(c):setPosition(d,e):setSize(f or#c,g):setBackground(h):setForeground(i):setFontSize(j or 1)end;function a.newPane(b,d,e,f,g,h)return b:addPane():setPosition(d,e):setSize(f,g):setBackground(h)end;function a.newTextfield(b,d,e,f,g,h,i)return b:addTextfield():addLine(\"\"):setPosition(d,e):setSize(f,g):setBackground(h):setForeground(i)end;function a.newButton(b,c,d,e,f,g,h,i,k)return b:addButton():setText(c):setBackground(h):setForeground(i):setPosition(d,e):setSize(f,g):onClick(k)end;function a.newCheckbox(b,d,e,f,g,h,i)return b:addCheckbox():setBackground(h):setForeground(i):setPosition(d,e):setSize(f,g)end;function a.newInputfield(b,d,e,f,g,h,i)return b:addInput():setInputType(\"text\"):setBackground(h):setForeground(i):setPosition(d,e):setSize(f,g)end;function a.newPopup(b,f,g,l,m,n,o,p)local q=b:addMovableFrame():setSize(f,g):setBackground(colors.white,\"#\",colors.lightGray):setPosition(2,8):setVisible(true)local l=q:addLabel():setText(l):setBackground(colors.blue):setForeground(colors.white):setPosition(1,1):setSize(f,1)local r=q:addLabel():setText(n):setBackground(colors.white):setPosition(3,3):setSize(#n,1)if m==\"error\"then r:setForeground(colors.red)elseif m==\"success\"then r:setForeground(colors.green)elseif m==\"info\"then r:setForeground(colors.black)elseif m==\"action\"then r:setForeground(colors.black)for s,t in ipairs(p)do a.newButton(q,t.name,t.posX,t.posY,t.sizeX,t.sizeY,t.bg,t.fg,t.callback)end end;if o then local u=a.newButton(q,\"X\",f,1,1,1,colors.blue,colors.red)u:onClick(function(self,v,w,x,y)if v==\"mouse_click\"and w==1 then q:remove()q:disable()end end)end end;return a\
",
    ["server/network/message.lua"] = "local a=require\"lib.rsa-keygen\"local b={}function b.create(c,d,e,f)if not c then return nil end;local g={message={action=c,payload=d},timestamp=os.epoch(\"utc\"),id=_G.utils.randomString(16,\"generic\"),isPlaintext=false}if e then if f then g.message=a.rsaEncrypt(textutils.serialize(g.message),e)end;g.message=e:encrypt(textutils.serialize(g.message))else g.isPlaintext=true end;return textutils.serialize(g),g.id end;return b\
",
    ["server/lib/themes.lua"] = "local a=require\"lib.fileUtils\"local b={}local c=\"/GuardLink/server/config/themes.json\"local d={primary=colors.orange,secondary=colors.magenta,tertiary=colors.lightBlue,highlight=colors.yellow,subtle=colors.lime,accent=colors.pink,info=colors.cyan,alert=colors.purple,emphasis=colors.blue,muted=colors.brown}local function e(f)if not fs.exists(f or c)then a.write(f or c,\"\")end;b=textutils.unserializeJSON(a.read(f or c))term.setPaletteColour(colors.red,0xf42929)term.setPaletteColour(colors.white,0xffffff)term.setPaletteColour(colors.black,0x000000)term.setPaletteColour(colors.green,0x2ec120)term.setPaletteColour(colors.lightGray,0x999999)term.setPaletteColour(colors.gray,0x4C4C4C)term.setPaletteColour(colors.orange,0xffffff)term.setPaletteColour(colors.magenta,0xffffff)term.setPaletteColour(colors.lightBlue,0xffffff)term.setPaletteColour(colors.yellow,0xffffff)term.setPaletteColour(colors.lime,0xffffff)term.setPaletteColour(colors.pink,0xffffff)term.setPaletteColour(colors.cyan,0xffffff)term.setPaletteColour(colors.purple,0xffffff)term.setPaletteColour(colors.blue,0xffffff)term.setPaletteColour(colors.brown,0xffffff)return 0 end;local function g(h)if not b[h]then _G.Logger:info(\"[themes] Theme not found! Using default theme\")return 1 end;for i,j in ipairs(b[h])do term.setPaletteColour(d[j[1]],tonumber(j[2],16))end;term.clear()return 0 end;local function k()return b end;return{init=e,setTheme=g,getThemes=k,colors=d}\
",
    ["server/modules/shutdown.lua"] = "local a={}local b={}function a.register(c)assert(type(c)==\"function\",\"register only expects functions\")table.insert(b,c)end;local function d()for e=1,#b do local f,g=pcall(b[e])if not f then _G.logger:error((\"[shutdown] Failed to execute callback %d: %s\"):format(e,tostring(g)))end end end;local h=os.shutdown;local i=os.reboot;os.shutdown=function(...)_G.logger:debug(\"[shutdown] Server shutting down! Executing callbacks...\")d()return h(...)end;os.reboot=function(...)_G.logger:debug(\"[shutdown] Server rebooting! Executing callbacks...\")d()return i(...)end;return a\
",
    ["server/lib/basalt.lua"] = "local aa={}local ba=true;local ca=require\
local da=function(ab)\
for bb,cb in pairs(aa)do\
if(type(cb)==\"table\")then for db,_c in pairs(cb)do if(db==ab)then\
return _c()end end else if(bb==ab)then return cb()end end end;return ca(ab)end\
local _b=function(ab)if(ab~=nil)then return aa[ab]end;return aa end\
aa[\"plugin\"]=function(...)local ab={...}local bb={}local cb={}\
local db=fs.getDir(ab[2]or\"Basalt\")local _c=fs.combine(db,\"plugins\")\
if(ba)then\
for bc,cc in pairs(_b(\"plugins\"))do\
table.insert(cb,bc)local dc=cc()\
if(type(dc)==\"table\")then for _d,ad in pairs(dc)do\
if(type(_d)==\"string\")then if(bb[_d]==nil)then\
bb[_d]={}end;table.insert(bb[_d],ad)end end end end else\
if(fs.exists(_c))then\
for bc,cc in pairs(fs.list(_c))do local dc\
if\
(fs.isDir(fs.combine(_c,cc)))then table.insert(cb,fs.combine(_c,cc))\
dc=da(cc..\"/init\")else table.insert(cb,cc)dc=da(cc:gsub(\".lua\",\"\"))end\
if(type(dc)==\"table\")then for _d,ad in pairs(dc)do\
if(type(_d)==\"string\")then\
if(bb[_d]==nil)then bb[_d]={}end;table.insert(bb[_d],ad)end end end end end end;local function ac(bc)return bb[bc]end\
return\
{get=ac,getAvailablePlugins=function()return cb end,addPlugin=function(bc)\
if(fs.exists(bc))then\
if(fs.isDir(bc))then\
for cc,dc in\
pairs(fs.list(bc))do table.insert(cb,dc)\
if\
not(fs.isDir(fs.combine(bc,dc)))then local _d=dc:gsub(\".lua\",\"\")local ad=da(fs.combine(bc,_d))\
if(\
type(ad)==\"table\")then for bd,cd in pairs(ad)do\
if(type(bd)==\"string\")then\
if(bb[bd]==nil)then bb[bd]={}end;table.insert(bb[bd],cd)end end end end end else local cc=da(bc:gsub(\".lua\",\"\"))\
table.insert(cb,bc:match(\"[\\\\/]?([^\\\\/]-([^%.]+))$\"))\
if(type(cc)==\"table\")then for dc,_d in pairs(cc)do\
if(type(dc)==\"string\")then\
if(bb[dc]==nil)then bb[dc]={}end;table.insert(bb[dc],_d)end end end end end end,loadPlugins=function(bc,cc)\
for dc,_d in\
pairs(bc)do local ad=bb[dc]\
if(ad~=nil)then\
bc[dc]=function(...)local bd=_d(...)\
for cd,dd in pairs(ad)do local __a=dd(bd,cc,...)\
__a.__index=__a;bd=setmetatable(__a,bd)end;return bd end end end;return bc end}end\
aa[\"main\"]=function(...)local ab=da(\"basaltEvent\")()\
local bb=da(\"loadObjects\")local cb;local db=da(\"plugin\")local _c=da(\"utils\")local ac=da(\"basaltLogs\")\
local bc=_c.uuid;local cc=_c.wrapText;local dc=_c.tableCount;local _d=300;local ad=0;local bd=0;local cd={}\
local dd=term.current()local __a=\"1.7.0\"\
local a_a=fs.getDir(table.pack(...)[2]or\"\")local b_a,c_a,d_a,_aa,aaa={},{},{},{},{}local baa,caa,daa,_ba;local aba={}if not term.isColor or\
not term.isColor()then\
error('Basalt requires an advanced (golden) computer to run.',0)end;local bba={}\
for adb,bdb in\
pairs(colors)do if(type(bdb)==\"number\")then\
bba[adb]={dd.getPaletteColor(bdb)}end end\
local function cba()_ba=false;dd.clear()dd.setCursorPos(1,1)\
for adb,bdb in pairs(colors)do if(type(bdb)==\
\"number\")then\
dd.setPaletteColor(bdb,colors.packRGB(table.unpack(bba[adb])))end end end\
local function dba(adb)\
assert(adb~=\"function\",\"Schedule needs a function in order to work!\")\
return function(...)local bdb=coroutine.create(adb)\
local cdb,ddb=coroutine.resume(bdb,...)\
if(cdb)then table.insert(aaa,bdb)else aba.basaltError(ddb)end end end;aba.log=function(...)ac(...)end\
local _ca=function(adb,bdb)_aa[adb]=bdb end;local aca=function(adb)return _aa[adb]end\
local bca=function()return cb end;local cca=function(adb)return bca()[adb]end;local dca=function(adb,bdb,cdb)return\
cca(bdb)(cdb,adb)end\
local _da={getDynamicValueEventSetting=function()return\
aba.dynamicValueEvents end,getMainFrame=function()return baa end,setVariable=_ca,getVariable=aca,setMainFrame=function(adb)baa=adb end,getActiveFrame=function()return\
caa end,setActiveFrame=function(adb)caa=adb end,getFocusedObject=function()return daa end,setFocusedObject=function(adb)daa=adb end,getMonitorFrame=function(adb)return\
d_a[adb]or monGroups[adb][1]end,setMonitorFrame=function(adb,bdb,cdb)if(\
baa==bdb)then baa=nil end;if(cdb)then monGroups[adb]={bdb,sides}else\
d_a[adb]=bdb end\
if(bdb==nil)then monGroups[adb]=nil end end,getTerm=function()return\
dd end,schedule=dba,stop=cba,debug=aba.debug,log=aba.log,getObjects=bca,getObject=cca,createObject=dca,getDirectory=function()return a_a end}\
local function ada(adb)dd.clear()dd.setBackgroundColor(colors.black)\
dd.setTextColor(colors.red)local bdb,cdb=dd.getSize()if(aba.logging)then ac(adb,\"Error\")end;local ddb=cc(\
\"Basalt error: \"..adb,bdb)local __c=1;for a_c,b_c in pairs(ddb)do\
dd.setCursorPos(1,__c)dd.write(b_c)__c=__c+1 end;dd.setCursorPos(1,\
__c+1)_ba=false end\
local function bda(adb,bdb,cdb,ddb,__c)\
if(#aaa>0)then local a_c={}\
for n=1,#aaa do\
if(aaa[n]~=nil)then\
if\
(coroutine.status(aaa[n])==\"suspended\")then\
local b_c,c_c=coroutine.resume(aaa[n],adb,bdb,cdb,ddb,__c)if not(b_c)then aba.basaltError(c_c)end else\
table.insert(a_c,n)end end end\
for n=1,#a_c do table.remove(aaa,a_c[n]- (n-1))end end end\
local function cda()if(_ba==false)then return end;if(baa~=nil)then baa:render()\
baa:updateTerm()end;for adb,bdb in pairs(d_a)do bdb:render()\
bdb:updateTerm()end end;local dda,__b,a_b=nil,nil,nil;local b_b=nil\
local function c_b(adb,bdb,cdb,ddb)dda,__b,a_b=bdb,cdb,ddb;if(b_b==nil)then\
b_b=os.startTimer(_d/1000)end end\
local function d_b()b_b=nil;baa:hoverHandler(__b,a_b,dda)caa=baa end;local _ab,aab,bab=nil,nil,nil;local cab=nil;local function dab()cab=nil;baa:dragHandler(_ab,aab,bab)\
caa=baa end;local function _bb(adb,bdb,cdb,ddb)_ab,aab,bab=bdb,cdb,ddb\
if(ad<50)then dab()else if(cab==nil)then cab=os.startTimer(\
ad/1000)end end end\
local abb=nil;local function bbb()abb=nil;cda()end\
local function cbb(adb)if(bd<50)then cda()else if(abb==nil)then\
abb=os.startTimer(bd/1000)end end end\
local function dbb(adb,...)local bdb={...}if\
(ab:sendEvent(\"basaltEventCycle\",adb,...)==false)then return end\
if(adb==\"terminate\")then aba.stop()end\
if(baa~=nil)then\
local cdb={mouse_click=baa.mouseHandler,mouse_up=baa.mouseUpHandler,mouse_scroll=baa.scrollHandler,mouse_drag=_bb,mouse_move=c_b}local ddb=cdb[adb]\
if(ddb~=nil)then ddb(baa,...)bda(adb,...)cbb()return end end\
if(adb==\"monitor_touch\")then\
for cdb,ddb in pairs(d_a)do if\
(ddb:mouseHandler(1,bdb[2],bdb[3],true,bdb[1]))then caa=ddb end end;bda(adb,...)cbb()return end\
if(caa~=nil)then\
local cdb={char=caa.charHandler,key=caa.keyHandler,key_up=caa.keyUpHandler}local ddb=cdb[adb]if(ddb~=nil)then if(adb==\"key\")then b_a[bdb[1]]=true elseif(adb==\"key_up\")then\
b_a[bdb[1]]=false end;ddb(caa,...)bda(adb,...)\
cbb()return end end\
if(adb==\"timer\")and(bdb[1]==b_b)then d_b()elseif\
(adb==\"timer\")and(bdb[1]==cab)then dab()elseif(adb==\"timer\")and(bdb[1]==abb)then bbb()else for cdb,ddb in pairs(c_a)do\
ddb:eventHandler(adb,...)end\
for cdb,ddb in pairs(d_a)do ddb:eventHandler(adb,...)end;bda(adb,...)cbb()end end;local _cb=false;local acb=false\
local function bcb()\
if not(_cb)then\
for adb,bdb in pairs(cd)do\
if(fs.exists(bdb))then\
if(fs.isDir(bdb))then\
local cdb=fs.list(bdb)\
for ddb,__c in pairs(cdb)do\
if not(fs.isDir(bdb..\"/\"..__c))then\
local a_c=__c:gsub(\".lua\",\"\")\
if\
(a_c~=\"example.lua\")and not(a_c:find(\".disabled\"))then\
if(bb[a_c]==nil)then\
bb[a_c]=da(bdb..\".\"..__c:gsub(\".lua\",\"\"))else error(\"Duplicate object name: \"..a_c)end end end end else local cdb=bdb:gsub(\".lua\",\"\")\
if(bb[cdb]==nil)then bb[cdb]=da(cdb)else error(\
\"Duplicate object name: \"..cdb)end end end end;_cb=true end\
if not(acb)then cb=db.loadPlugins(bb,_da)local adb=db.get(\"basalt\")\
if\
(adb~=nil)then for cdb,ddb in pairs(adb)do\
for __c,a_c in pairs(ddb(aba))do aba[__c]=a_c;_da[__c]=a_c end end end;local bdb=db.get(\"basaltInternal\")\
if(bdb~=nil)then for cdb,ddb in pairs(bdb)do for __c,a_c in pairs(ddb(aba))do\
_da[__c]=a_c end end end;acb=true end end\
local function ccb(adb)bcb()\
for cdb,ddb in pairs(c_a)do if(ddb:getName()==adb)then return nil end end;local bdb=cb[\"BaseFrame\"](adb,_da)bdb:init()\
bdb:load()bdb:draw()table.insert(c_a,bdb)\
if(baa==nil)and(bdb:getName()~=\
\"basaltDebuggingFrame\")then bdb:show()end;return bdb end\
aba={basaltError=ada,logging=false,dynamicValueEvents=false,drawFrames=cda,log=ac,getVersion=function()return __a end,memory=function()return\
math.floor(collectgarbage(\"count\")+0.5)..\"KB\"end,addObject=function(adb)if\
(fs.exists(adb))then table.insert(cd,adb)end end,addPlugin=function(adb)\
db.addPlugin(adb)end,getAvailablePlugins=function()return db.getAvailablePlugins()end,getAvailableObjects=function()\
local adb={}for bdb,cdb in pairs(bb)do table.insert(adb,bdb)end;return adb end,setVariable=_ca,getVariable=aca,getObjects=bca,getObject=cca,createObject=dca,setBaseTerm=function(adb)\
dd=adb end,resetPalette=function()\
for adb,bdb in pairs(colors)do if(type(bdb)==\"number\")then end end end,setMouseMoveThrottle=function(adb)\
if(_HOST:find(\"CraftOS%-PC\"))then if(\
config.get(\"mouse_move_throttle\")~=10)then\
config.set(\"mouse_move_throttle\",10)end\
if(adb<100)then _d=100 else _d=adb end;return true end;return false end,setRenderingThrottle=function(adb)if(\
adb<=0)then bd=0 else abb=nil;bd=adb end end,setMouseDragThrottle=function(adb)if\
(adb<=0)then ad=0 else cab=nil;ad=adb end end,autoUpdate=function(adb)_ba=adb;if(\
adb==nil)then _ba=true end;local function bdb()cda()while _ba do\
dbb(os.pullEventRaw())end end\
while _ba do\
local cdb,ddb=xpcall(bdb,debug.traceback)if not(cdb)then aba.basaltError(ddb)end end end,update=function(adb,...)\
if(\
adb~=nil)then local bdb={...}\
local cdb,ddb=xpcall(function()dbb(adb,table.unpack(bdb))end,debug.traceback)if not(cdb)then aba.basaltError(ddb)return end end end,stop=cba,stopUpdate=cba,isKeyDown=function(adb)if(\
b_a[adb]==nil)then return false end;return b_a[adb]end,getFrame=function(adb)for bdb,cdb in\
pairs(c_a)do if(cdb.name==adb)then return cdb end end end,getActiveFrame=function()return\
caa end,setActiveFrame=function(adb)\
if(adb:getType()==\"Container\")then caa=adb;return true end;return false end,getMainFrame=function()return baa end,onEvent=function(...)\
for adb,bdb in\
pairs(table.pack(...))do if(type(bdb)==\"function\")then\
ab:registerEvent(\"basaltEventCycle\",bdb)end end end,schedule=dba,addFrame=ccb,createFrame=ccb,addMonitor=function(adb)\
bcb()\
for cdb,ddb in pairs(c_a)do if(ddb:getName()==adb)then return nil end end;local bdb=cb[\"MonitorFrame\"](adb,_da)bdb:init()\
bdb:load()bdb:draw()table.insert(d_a,bdb)return bdb end,removeFrame=function(adb)c_a[adb]=\
nil end,setProjectDir=function(adb)a_a=adb end}local dcb=db.get(\"basalt\")if(dcb~=nil)then\
for adb,bdb in pairs(dcb)do for cdb,ddb in pairs(bdb(aba))do\
aba[cdb]=ddb;_da[cdb]=ddb end end end\
local _db=db.get(\"basaltInternal\")if(_db~=nil)then\
for adb,bdb in pairs(_db)do for cdb,ddb in pairs(bdb(aba))do _da[cdb]=ddb end end end;return aba end;aa[\"plugins\"]={}\
aa[\"plugins\"][\"advancedBackground\"]=function(...)\
local ab=da(\"xmlParser\")\
return\
{VisualObject=function(bb)local cb=false;local db=colors.black\
local _c={setBackground=function(ac,bc,cc,dc)bb.setBackground(ac,bc)\
cb=cc or cb;db=dc or db;return ac end,setBackgroundSymbol=function(ac,bc,cc)cb=bc\
db=cc or db;ac:updateDraw()return ac end,getBackgroundSymbol=function(ac)return cb end,getBackgroundSymbolColor=function(ac)return\
db end,draw=function(ac)bb.draw(ac)\
ac:addDraw(\"advanced-bg\",function()local bc,cc=ac:getSize()\
if\
(cb~=false)then ac:addTextBox(1,1,bc,cc,cb:sub(1,1))if(cb~=\" \")then\
ac:addForegroundBox(1,1,bc,cc,db)end end end,2)end}return _c end}end\
aa[\"plugins\"][\"bigfonts\"]=function(...)local ab=da(\"tHex\")\
local bb={{\"\\32\\32\\32\\137\\156\\148\\158\\159\\148\\135\\135\\144\\159\\139\\32\\136\\157\\32\\159\\139\\32\\32\\143\\32\\32\\143\\32\\32\\32\\32\\32\\32\\32\\32\\147\\148\\150\\131\\148\\32\\32\\32\\151\\140\\148\\151\\140\\147\",\"\\32\\32\\32\\149\\132\\149\\136\\156\\149\\144\\32\\133\\139\\159\\129\\143\\159\\133\\143\\159\\133\\138\\32\\133\\138\\32\\133\\32\\32\\32\\32\\32\\32\\150\\150\\129\\137\\156\\129\\32\\32\\32\\133\\131\\129\\133\\131\\132\",\"\\32\\32\\32\\130\\131\\32\\130\\131\\32\\32\\129\\32\\32\\32\\32\\130\\131\\32\\130\\131\\32\\32\\32\\32\\143\\143\\143\\32\\32\\32\\32\\32\\32\\130\\129\\32\\130\\135\\32\\32\\32\\32\\131\\32\\32\\131\\32\\131\",\"\\139\\144\\32\\32\\143\\148\\135\\130\\144\\149\\32\\149\\150\\151\\149\\158\\140\\129\\32\\32\\32\\135\\130\\144\\135\\130\\144\\32\\149\\32\\32\\139\\32\\159\\148\\32\\32\\32\\32\\159\\32\\144\\32\\148\\32\\147\\131\\132\",\"\\159\\135\\129\\131\\143\\149\\143\\138\\144\\138\\32\\133\\130\\149\\149\\137\\155\\149\\159\\143\\144\\147\\130\\132\\32\\149\\32\\147\\130\\132\\131\\159\\129\\139\\151\\129\\148\\32\\32\\139\\131\\135\\133\\32\\144\\130\\151\\32\",\"\\32\\32\\32\\32\\32\\32\\130\\135\\32\\130\\32\\129\\32\\129\\129\\131\\131\\32\\130\\131\\129\\140\\141\\132\\32\\129\\32\\32\\129\\32\\32\\32\\32\\32\\32\\32\\131\\131\\129\\32\\32\\32\\32\\32\\32\\32\\32\\32\",\"\\32\\32\\32\\32\\149\\32\\159\\154\\133\\133\\133\\144\\152\\141\\132\\133\\151\\129\\136\\153\\32\\32\\154\\32\\159\\134\\129\\130\\137\\144\\159\\32\\144\\32\\148\\32\\32\\32\\32\\32\\32\\32\\32\\32\\32\\32\\151\\129\",\"\\32\\32\\32\\32\\133\\32\\32\\32\\32\\145\\145\\132\\141\\140\\132\\151\\129\\144\\150\\146\\129\\32\\32\\32\\138\\144\\32\\32\\159\\133\\136\\131\\132\\131\\151\\129\\32\\144\\32\\131\\131\\129\\32\\144\\32\\151\\129\\32\",\"\\32\\32\\32\\32\\129\\32\\32\\32\\32\\130\\130\\32\\32\\129\\32\\129\\32\\129\\130\\129\\129\\32\\32\\32\\32\\130\\129\\130\\129\\32\\32\\32\\32\\32\\32\\32\\32\\133\\32\\32\\32\\32\\32\\129\\32\\129\\32\\32\",\"\\150\\156\\148\\136\\149\\32\\134\\131\\148\\134\\131\\148\\159\\134\\149\\136\\140\\129\\152\\131\\32\\135\\131\\149\\150\\131\\148\\150\\131\\148\\32\\148\\32\\32\\148\\32\\32\\152\\129\\143\\143\\144\\130\\155\\32\\134\\131\\148\",\"\\157\\129\\149\\32\\149\\32\\152\\131\\144\\144\\131\\148\\141\\140\\149\\144\\32\\149\\151\\131\\148\\32\\150\\32\\150\\131\\148\\130\\156\\133\\32\\144\\32\\32\\144\\32\\130\\155\\32\\143\\143\\144\\32\\152\\129\\32\\134\\32\",\"\\130\\131\\32\\131\\131\\129\\131\\131\\129\\130\\131\\32\\32\\32\\129\\130\\131\\32\\130\\131\\32\\32\\129\\32\\130\\131\\32\\130\\129\\32\\32\\129\\32\\32\\133\\32\\32\\32\\129\\32\\32\\32\\130\\32\\32\\32\\129\\32\",\"\\150\\140\\150\\137\\140\\148\\136\\140\\132\\150\\131\\132\\151\\131\\148\\136\\147\\129\\136\\147\\129\\150\\156\\145\\138\\143\\149\\130\\151\\32\\32\\32\\149\\138\\152\\129\\149\\32\\32\\157\\152\\149\\157\\144\\149\\150\\131\\148\",\"\\149\\143\\142\\149\\32\\149\\149\\32\\149\\149\\32\\144\\149\\32\\149\\149\\32\\32\\149\\32\\32\\149\\32\\149\\149\\32\\149\\32\\149\\32\\144\\32\\149\\149\\130\\148\\149\\32\\32\\149\\32\\149\\149\\130\\149\\149\\32\\149\",\"\\130\\131\\129\\129\\32\\129\\131\\131\\32\\130\\131\\32\\131\\131\\32\\131\\131\\129\\129\\32\\32\\130\\131\\32\\129\\32\\129\\130\\131\\32\\130\\131\\32\\129\\32\\129\\131\\131\\129\\129\\32\\129\\129\\32\\129\\130\\131\\32\",\"\\136\\140\\132\\150\\131\\148\\136\\140\\132\\153\\140\\129\\131\\151\\129\\149\\32\\149\\149\\32\\149\\149\\32\\149\\137\\152\\129\\137\\152\\129\\131\\156\\133\\149\\131\\32\\150\\32\\32\\130\\148\\32\\152\\137\\144\\32\\32\\32\",\"\\149\\32\\32\\149\\159\\133\\149\\32\\149\\144\\32\\149\\32\\149\\32\\149\\32\\149\\150\\151\\129\\138\\155\\149\\150\\130\\148\\32\\149\\32\\152\\129\\32\\149\\32\\32\\32\\150\\32\\32\\149\\32\\32\\32\\32\\32\\32\\32\",\"\\129\\32\\32\\130\\129\\129\\129\\32\\129\\130\\131\\32\\32\\129\\32\\130\\131\\32\\32\\129\\32\\129\\32\\129\\129\\32\\129\\32\\129\\32\\131\\131\\129\\130\\131\\32\\32\\32\\129\\130\\131\\32\\32\\32\\32\\140\\140\\132\",\"\\32\\154\\32\\159\\143\\32\\149\\143\\32\\159\\143\\32\\159\\144\\149\\159\\143\\32\\159\\137\\145\\159\\143\\144\\149\\143\\32\\32\\145\\32\\32\\32\\145\\149\\32\\144\\32\\149\\32\\143\\159\\32\\143\\143\\32\\159\\143\\32\",\"\\32\\32\\32\\152\\140\\149\\151\\32\\149\\149\\32\\145\\149\\130\\149\\157\\140\\133\\32\\149\\32\\154\\143\\149\\151\\32\\149\\32\\149\\32\\144\\32\\149\\149\\153\\32\\32\\149\\32\\149\\133\\149\\149\\32\\149\\149\\32\\149\",\"\\32\\32\\32\\130\\131\\129\\131\\131\\32\\130\\131\\32\\130\\131\\129\\130\\131\\129\\32\\129\\32\\140\\140\\129\\129\\32\\129\\32\\129\\32\\137\\140\\129\\130\\32\\129\\32\\130\\32\\129\\32\\129\\129\\32\\129\\130\\131\\32\",\"\\144\\143\\32\\159\\144\\144\\144\\143\\32\\159\\143\\144\\159\\138\\32\\144\\32\\144\\144\\32\\144\\144\\32\\144\\144\\32\\144\\144\\32\\144\\143\\143\\144\\32\\150\\129\\32\\149\\32\\130\\150\\32\\134\\137\\134\\134\\131\\148\",\"\\136\\143\\133\\154\\141\\149\\151\\32\\129\\137\\140\\144\\32\\149\\32\\149\\32\\149\\154\\159\\133\\149\\148\\149\\157\\153\\32\\154\\143\\149\\159\\134\\32\\130\\148\\32\\32\\149\\32\\32\\151\\129\\32\\32\\32\\32\\134\\32\",\"\\133\\32\\32\\32\\32\\133\\129\\32\\32\\131\\131\\32\\32\\130\\32\\130\\131\\129\\32\\129\\32\\130\\131\\129\\129\\32\\129\\140\\140\\129\\131\\131\\129\\32\\130\\129\\32\\129\\32\\130\\129\\32\\32\\32\\32\\32\\129\\32\",\"\\32\\32\\32\\32\\149\\32\\32\\149\\32\\32\\32\\32\\32\\32\\32\\32\\149\\32\\32\\149\\32\\32\\32\\32\\32\\32\\32\\32\\149\\32\\32\\149\\32\\32\\32\\32\\32\\32\\32\\32\\149\\32\\32\\149\\32\\32\\32\\32\",\"\\32\\32\\32\\32\\32\\32\\32\\32\\32\\32\\32\\32\\32\\149\\32\\32\\149\\32\\32\\149\\32\\32\\149\\32\\32\\149\\32\\32\\149\\32\\32\\149\\32\\32\\149\\32\\32\\32\\32\\32\\32\\32\\32\\32\\32\\32\\32\\32\",\"\\32\\32\\32\\32\\32\\32\\32\\32\\32\\32\\32\\32\\32\\32\\32\\32\\32\\32\\32\\32\\32\\32\\32\\32\\32\\32\\32\\32\\32\\32\\32\\32\\32\\32\\32\\32\\32\\32\\32\\32\\32\\32\\32\\32\\32\\32\\32\\32\",\"\\32\\32\\32\\32\\149\\32\\32\\149\\32\\32\\32\\32\\32\\32\\32\\32\\149\\32\\32\\149\\32\\32\\32\\32\\32\\32\\32\\32\\149\\32\\32\\149\\32\\32\\32\\32\\32\\32\\32\\32\\149\\32\\32\\149\\32\\32\\32\\32\",\"\\32\\32\\32\\32\\32\\32\\32\\32\\32\\32\\32\\32\\32\\149\\32\\32\\149\\32\\32\\149\\32\\32\\149\\32\\32\\149\\32\\32\\149\\32\\32\\149\\32\\32\\149\\32\\32\\32\\32\\32\\32\\32\\32\\32\\32\\32\\32\\32\",\"\\32\\149\\32\\32\\149\\32\\32\\149\\32\\32\\149\\32\\32\\149\\32\\32\\149\\32\\32\\149\\32\\32\\149\\32\\32\\149\\32\\32\\149\\32\\32\\149\\32\\32\\149\\32\\32\\149\\32\\32\\149\\32\\32\\149\\32\\32\\149\\32\",\"\\32\\32\\32\\32\\145\\32\\159\\139\\32\\151\\131\\132\\155\\143\\132\\134\\135\\145\\32\\149\\32\\158\\140\\129\\130\\130\\32\\152\\147\\155\\157\\134\\32\\32\\144\\144\\32\\32\\32\\32\\32\\32\\152\\131\\155\\131\\131\\129\",\"\\32\\32\\32\\32\\149\\32\\149\\32\\145\\148\\131\\32\\149\\32\\149\\140\\157\\132\\32\\148\\32\\137\\155\\149\\32\\32\\32\\149\\154\\149\\137\\142\\32\\153\\153\\32\\131\\131\\149\\131\\131\\129\\149\\135\\145\\32\\32\\32\",\"\\32\\32\\32\\32\\129\\32\\130\\135\\32\\131\\131\\129\\134\\131\\132\\32\\129\\32\\32\\129\\32\\131\\131\\32\\32\\32\\32\\130\\131\\129\\32\\32\\32\\32\\129\\129\\32\\32\\32\\32\\32\\32\\130\\131\\129\\32\\32\\32\",\"\\150\\150\\32\\32\\148\\32\\134\\32\\32\\132\\32\\32\\134\\32\\32\\144\\32\\144\\150\\151\\149\\32\\32\\32\\32\\32\\32\\145\\32\\32\\152\\140\\144\\144\\144\\32\\133\\151\\129\\133\\151\\129\\132\\151\\129\\32\\145\\32\",\"\\130\\129\\32\\131\\151\\129\\141\\32\\32\\142\\32\\32\\32\\32\\32\\149\\32\\149\\130\\149\\149\\32\\143\\32\\32\\32\\32\\142\\132\\32\\154\\143\\133\\157\\153\\132\\151\\150\\148\\151\\158\\132\\151\\150\\148\\144\\130\\148\",\"\\32\\32\\32\\140\\140\\132\\32\\32\\32\\32\\32\\32\\32\\32\\32\\151\\131\\32\\32\\129\\129\\32\\32\\32\\32\\134\\32\\32\\32\\32\\32\\32\\32\\129\\129\\32\\129\\32\\129\\129\\130\\129\\129\\32\\129\\130\\131\\32\",\"\\156\\143\\32\\159\\141\\129\\153\\140\\132\\153\\137\\32\\157\\141\\32\\159\\142\\32\\150\\151\\129\\150\\131\\132\\140\\143\\144\\143\\141\\145\\137\\140\\148\\141\\141\\144\\157\\142\\32\\159\\140\\32\\151\\134\\32\\157\\141\\32\",\"\\157\\140\\149\\157\\140\\149\\157\\140\\149\\157\\140\\149\\157\\140\\149\\157\\140\\149\\151\\151\\32\\154\\143\\132\\157\\140\\32\\157\\140\\32\\157\\140\\32\\157\\140\\32\\32\\149\\32\\32\\149\\32\\32\\149\\32\\32\\149\\32\",\"\\129\\32\\129\\129\\32\\129\\129\\32\\129\\129\\32\\129\\129\\32\\129\\129\\32\\129\\129\\131\\129\\32\\134\\32\\131\\131\\129\\131\\131\\129\\131\\131\\129\\131\\131\\129\\130\\131\\32\\130\\131\\32\\130\\131\\32\\130\\131\\32\",\"\\151\\131\\148\\152\\137\\145\\155\\140\\144\\152\\142\\145\\153\\140\\132\\153\\137\\32\\154\\142\\144\\155\\159\\132\\150\\156\\148\\147\\32\\144\\144\\130\\145\\136\\137\\32\\146\\130\\144\\144\\130\\145\\130\\136\\32\\151\\140\\132\",\"\\151\\32\\149\\151\\155\\149\\149\\32\\149\\149\\32\\149\\149\\32\\149\\149\\32\\149\\149\\32\\149\\152\\137\\144\\157\\129\\149\\149\\32\\149\\149\\32\\149\\149\\32\\149\\149\\32\\149\\130\\150\\32\\32\\157\\129\\149\\32\\149\",\"\\131\\131\\32\\129\\32\\129\\130\\131\\32\\130\\131\\32\\130\\131\\32\\130\\131\\32\\130\\131\\32\\32\\32\\32\\130\\131\\32\\130\\131\\32\\130\\131\\32\\130\\131\\32\\130\\131\\32\\32\\129\\32\\130\\131\\32\\133\\131\\32\",\"\\156\\143\\32\\159\\141\\129\\153\\140\\132\\153\\137\\32\\157\\141\\32\\159\\142\\32\\159\\159\\144\\152\\140\\144\\156\\143\\32\\159\\141\\129\\153\\140\\132\\157\\141\\32\\130\\145\\32\\32\\147\\32\\136\\153\\32\\130\\146\\32\",\"\\152\\140\\149\\152\\140\\149\\152\\140\\149\\152\\140\\149\\152\\140\\149\\152\\140\\149\\149\\157\\134\\154\\143\\132\\157\\140\\133\\157\\140\\133\\157\\140\\133\\157\\140\\133\\32\\149\\32\\32\\149\\32\\32\\149\\32\\32\\149\\32\",\"\\130\\131\\129\\130\\131\\129\\130\\131\\129\\130\\131\\129\\130\\131\\129\\130\\131\\129\\130\\130\\131\\32\\134\\32\\130\\131\\129\\130\\131\\129\\130\\131\\129\\130\\131\\129\\32\\129\\32\\32\\129\\32\\32\\129\\32\\32\\129\\32\",\"\\159\\134\\144\\137\\137\\32\\156\\143\\32\\159\\141\\129\\153\\140\\132\\153\\137\\32\\157\\141\\32\\32\\132\\32\\159\\143\\32\\147\\32\\144\\144\\130\\145\\136\\137\\32\\146\\130\\144\\144\\130\\145\\130\\138\\32\\146\\130\\144\",\"\\149\\32\\149\\149\\32\\149\\149\\32\\149\\149\\32\\149\\149\\32\\149\\149\\32\\149\\149\\32\\149\\131\\147\\129\\138\\134\\149\\149\\32\\149\\149\\32\\149\\149\\32\\149\\149\\32\\149\\154\\143\\149\\32\\157\\129\\154\\143\\149\",\"\\130\\131\\32\\129\\32\\129\\130\\131\\32\\130\\131\\32\\130\\131\\32\\130\\131\\32\\130\\131\\32\\32\\32\\32\\130\\131\\32\\130\\131\\129\\130\\131\\129\\130\\131\\129\\130\\131\\129\\140\\140\\129\\130\\131\\32\\140\\140\\129\"},{\"000110000110110000110010101000000010000000100101\",\"000000110110000000000010101000000010000000100101\",\"000000000000000000000000000000000000000000000000\",\"100010110100000010000110110000010100000100000110\",\"000000110000000010110110000110000000000000110000\",\"000000000000000000000000000000000000000000000000\",\"000000110110000010000000100000100000000000000010\",\"000000000110110100010000000010000000000000000100\",\"000000000000000000000000000000000000000000000000\",\"010000000000100110000000000000000000000110010000\",\"000000000000000000000000000010000000010110000000\",\"000000000000000000000000000000000000000000000000\",\"011110110000000100100010110000000100000000000000\",\"000000000000000000000000000000000000000000000000\",\"000000000000000000000000000000000000000000000000\",\"110000110110000000000000000000010100100010000000\",\"000010000000000000110110000000000100010010000000\",\"000000000000000000000000000000000000000000000000\",\"010110010110100110110110010000000100000110110110\",\"000000000000000000000110000000000110000000000000\",\"000000000000000000000000000000000000000000000000\",\"010100010110110000000000000000110000000010000000\",\"110110000000000000110000110110100000000010000000\",\"000000000000000000000000000000000000000000000000\",\"000100011111000100011111000100011111000100011111\",\"000000000000100100100100011011011011111111111111\",\"000000000000000000000000000000000000000000000000\",\"000100011111000100011111000100011111000100011111\",\"000000000000100100100100011011011011111111111111\",\"100100100100100100100100100100100100100100100100\",\"000000110100110110000010000011110000000000011000\",\"000000000100000000000010000011000110000000001000\",\"000000000000000000000000000000000000000000000000\",\"010000100100000000000000000100000000010010110000\",\"000000000000000000000000000000110110110110110000\",\"000000000000000000000000000000000000000000000000\",\"110110110110110110000000110110110110110110110110\",\"000000000000000000000110000000000000000000000000\",\"000000000000000000000000000000000000000000000000\",\"000000000000110110000110010000000000000000010010\",\"000010000000000000000000000000000000000000000000\",\"000000000000000000000000000000000000000000000000\",\"110110110110110110110000110110110110000000000000\",\"000000000000000000000110000000000000000000000000\",\"000000000000000000000000000000000000000000000000\",\"110110110110110110110000110000000000000000010000\",\"000000000000000000000000100000000000000110000110\",\"000000000000000000000000000000000000000000000000\"}}local cb={}local db={}\
do local cc=0;local dc=#bb[1]local _d=#bb[1][1]\
for i=1,dc,3 do\
for j=1,_d,3 do\
local ad=string.char(cc)local bd={}bd[1]=bb[1][i]:sub(j,j+2)\
bd[2]=bb[1][i+1]:sub(j,j+2)bd[3]=bb[1][i+2]:sub(j,j+2)local cd={}cd[1]=bb[2][i]:sub(j,\
j+2)cd[2]=bb[2][i+1]:sub(j,j+2)cd[3]=bb[2][\
i+2]:sub(j,j+2)db[ad]={bd,cd}cc=cc+1 end end;cb[1]=db end\
local function _c(cc,dc)local _d={[\"0\"]=\"1\",[\"1\"]=\"0\"}if cc<=#cb then return true end\
for f=#cb+1,cc do local ad={}local bd=cb[\
f-1]\
for char=0,255 do local cd=string.char(char)local dd={}local __a={}\
local a_a=bd[cd][1]local b_a=bd[cd][2]\
for i=1,#a_a do local c_a,d_a,_aa,aaa,baa,caa={},{},{},{},{},{}\
for j=1,#a_a[1]do\
local daa=db[a_a[i]:sub(j,j)][1]table.insert(c_a,daa[1])\
table.insert(d_a,daa[2])table.insert(_aa,daa[3])\
local _ba=db[a_a[i]:sub(j,j)][2]\
if b_a[i]:sub(j,j)==\"1\"then\
table.insert(aaa,(_ba[1]:gsub(\"[01]\",_d)))\
table.insert(baa,(_ba[2]:gsub(\"[01]\",_d)))\
table.insert(caa,(_ba[3]:gsub(\"[01]\",_d)))else table.insert(aaa,_ba[1])\
table.insert(baa,_ba[2])table.insert(caa,_ba[3])end end;table.insert(dd,table.concat(c_a))\
table.insert(dd,table.concat(d_a))table.insert(dd,table.concat(_aa))\
table.insert(__a,table.concat(aaa))table.insert(__a,table.concat(baa))\
table.insert(__a,table.concat(caa))end;ad[cd]={dd,__a}if dc then dc=\"Font\"..f..\"Yeld\"..char\
os.queueEvent(dc)os.pullEvent(dc)end end;cb[f]=ad end;return true end\
local function ac(cc,dc,_d,ad,bd)\
if not type(dc)==\"string\"then error(\"Not a String\",3)end\
local cd=type(_d)==\"string\"and _d:sub(1,1)or ab[_d]or\
error(\"Wrong Front Color\",3)\
local dd=type(ad)==\"string\"and ad:sub(1,1)or ab[ad]or\
error(\"Wrong Back Color\",3)if(cb[cc]==nil)then _c(3,false)end;local __a=cb[cc]or\
error(\"Wrong font size selected\",3)if dc==\"\"then\
return{{\"\"},{\"\"},{\"\"}}end;local a_a={}\
for caa in dc:gmatch('.')do table.insert(a_a,caa)end;local b_a={}local c_a=#__a[a_a[1]][1]\
for nLine=1,c_a do local caa={}for i=1,#a_a do\
caa[i]=\
__a[a_a[i]]and __a[a_a[i]][1][nLine]or\"\"end;b_a[nLine]=table.concat(caa)end;local d_a={}local _aa={}local aaa={[\"0\"]=cd,[\"1\"]=dd}local baa={[\"0\"]=dd,[\"1\"]=cd}\
for nLine=1,c_a do\
local caa={}local daa={}\
for i=1,#a_a do\
local _ba=__a[a_a[i]]and __a[a_a[i]][2][nLine]or\"\"\
caa[i]=_ba:gsub(\"[01]\",\
bd and{[\"0\"]=_d:sub(i,i),[\"1\"]=ad:sub(i,i)}or aaa)\
daa[i]=_ba:gsub(\"[01]\",\
bd and{[\"0\"]=ad:sub(i,i),[\"1\"]=_d:sub(i,i)}or baa)end;d_a[nLine]=table.concat(caa)\
_aa[nLine]=table.concat(daa)end;return{b_a,d_a,_aa}end;local bc=da(\"xmlParser\")\
return\
{Label=function(cc)local dc=1;local _d\
local ad={setFontSize=function(bd,cd)\
if(type(cd)==\"number\")then dc=cd\
if(dc>1)then\
bd:setDrawState(\"label\",false)\
_d=ac(dc-1,bd:getText(),bd:getForeground(),bd:getBackground()or colors.lightGray)if(bd:getAutoSize())then\
bd:getBase():setSize(#_d[1][1],#_d[1]-1)end else\
bd:setDrawState(\"label\",true)end;bd:updateDraw()end;return bd end,getFontSize=function(bd)return\
dc end,getSize=function(bd)local cd,dd=cc.getSize(bd)\
if\
(dc>1)and(bd:getAutoSize())then\
return dc==2 and bd:getText():len()*3 or math.floor(\
bd:getText():len()*8.5),\
dc==2 and dd*2 or math.floor(dd)else return cd,dd end end,getWidth=function(bd)\
local cd=cc.getWidth(bd)if(dc>1)and(bd:getAutoSize())then return dc==2 and\
bd:getText():len()*3 or\
math.floor(bd:getText():len()*8.5)else\
return cd end end,getHeight=function(bd)\
local cd=cc.getHeight(bd)if(dc>1)and(bd:getAutoSize())then return\
dc==2 and cd*2 or math.floor(cd)else return cd end end,draw=function(bd)\
cc.draw(bd)\
bd:addDraw(\"bigfonts\",function()\
if(dc>1)then local cd,dd=bd:getPosition()local __a=bd:getParent()\
local a_a,b_a=__a:getSize()local c_a,d_a=#_d[1][1],#_d[1]cd=cd or\
math.floor((a_a-c_a)/2)+1;dd=dd or\
math.floor((b_a-d_a)/2)+1\
for i=1,d_a do bd:addFG(1,i,_d[2][i])\
bd:addBG(1,i,_d[3][i])bd:addText(1,i,_d[1][i])end end end)end}return ad end}end\
aa[\"plugins\"][\"border\"]=function(...)local ab=da(\"xmlParser\")\
return\
{VisualObject=function(bb)local cb=true\
local db={top=false,bottom=false,left=false,right=false}\
local _c={setBorder=function(ac,...)local bc={...}\
if(bc~=nil)then\
for cc,dc in pairs(bc)do\
if(dc==\"left\")or(#bc==1)then db[\"left\"]=bc[1]end;if(dc==\"top\")or(#bc==1)then db[\"top\"]=bc[1]end;if\
(dc==\"right\")or(#bc==1)then db[\"right\"]=bc[1]end;if\
(dc==\"bottom\")or(#bc==1)then db[\"bottom\"]=bc[1]end end end;ac:updateDraw()return ac end,draw=function(ac)\
bb.draw(ac)\
ac:addDraw(\"border\",function()local bc,cc=ac:getPosition()local dc,_d=ac:getSize()\
local ad=ac:getBackground()\
if(cb)then\
if(db[\"left\"]~=false)then ac:addTextBox(1,1,1,_d,\"\\149\")if(ad~=false)then\
ac:addBackgroundBox(1,1,1,_d,ad)end\
ac:addForegroundBox(1,1,1,_d,db[\"left\"])end\
if(db[\"top\"]~=false)then ac:addTextBox(1,1,dc,1,\"\\131\")if(ad~=false)then\
ac:addBackgroundBox(1,1,dc,1,ad)end\
ac:addForegroundBox(1,1,dc,1,db[\"top\"])end\
if(db[\"left\"]~=false)and(db[\"top\"]~=false)then\
ac:addTextBox(1,1,1,1,\"\\151\")\
if(ad~=false)then ac:addBackgroundBox(1,1,1,1,ad)end;ac:addForegroundBox(1,1,1,1,db[\"left\"])end\
if(db[\"right\"]~=false)then ac:addTextBox(dc,1,1,_d,\"\\149\")if\
(ad~=false)then ac:addForegroundBox(dc,1,1,_d,ad)end\
ac:addBackgroundBox(dc,1,1,_d,db[\"right\"])end\
if(db[\"bottom\"]~=false)then ac:addTextBox(1,_d,dc,1,\"\\143\")if\
(ad~=false)then ac:addForegroundBox(1,_d,dc,1,ad)end\
ac:addBackgroundBox(1,_d,dc,1,db[\"bottom\"])end\
if(db[\"top\"]~=false)and(db[\"right\"]~=false)then\
ac:addTextBox(dc,1,1,1,\"\\148\")\
if(ad~=false)then ac:addForegroundBox(dc,1,1,1,ad)end;ac:addBackgroundBox(dc,1,1,1,db[\"right\"])end\
if(db[\"right\"]~=false)and(db[\"bottom\"]~=false)then\
ac:addTextBox(dc,_d,1,1,\"\\133\")\
if(ad~=false)then ac:addForegroundBox(dc,_d,1,1,ad)end;ac:addBackgroundBox(dc,_d,1,1,db[\"right\"])end\
if(db[\"bottom\"]~=false)and(db[\"left\"]~=false)then\
ac:addTextBox(1,_d,1,1,\"\\138\")\
if(ad~=false)then ac:addForegroundBox(0,_d,1,1,ad)end;ac:addBackgroundBox(1,_d,1,1,db[\"left\"])end end end)end}return _c end}end\
aa[\"plugins\"][\"debug\"]=function(...)local ab=da(\"utils\")local bb=ab.wrapText\
return\
{basalt=function(cb)\
local db=cb.getMainFrame()local _c;local ac;local bc;local cc\
local function dc()local _d=16;local ad=6;local bd=99;local cd=99;local dd,__a=db:getSize()\
_c=db:addMovableFrame(\"basaltDebuggingFrame\"):setSize(\
dd-20,__a-10):setBackground(colors.gray):setForeground(colors.white):setZIndex(100):hide()\
_c:addPane():setSize(\"parent.w\",1):setPosition(1,1):setBackground(colors.black):setForeground(colors.white)\
_c:setPosition(-dd,__a/2 -_c:getHeight()/2):setBorder(colors.black)\
local a_a=_c:addButton():setPosition(\"parent.w\",\"parent.h\"):setSize(1,1):setText(\"\\133\"):setForeground(colors.gray):setBackground(colors.black):onClick(function()\
end):onDrag(function(b_a,c_a,d_a,_aa,aaa)\
local baa,caa=_c:getSize()local daa,_ba=baa,caa;if(baa+_aa-1 >=_d)and(baa+_aa-1 <=bd)then daa=baa+\
_aa-1 end\
if(caa+aaa-1 >=ad)and(\
caa+aaa-1 <=cd)then _ba=caa+aaa-1 end;_c:setSize(daa,_ba)end)\
cc=_c:addButton():setText(\"Close\"):setPosition(\"parent.w - 6\",1):setSize(7,1):setBackground(colors.red):setForeground(colors.white):onClick(function()\
_c:animatePosition(\
-dd,__a/2 -_c:getHeight()/2,0.5)end)\
ac=_c:addList():setSize(\"parent.w - 2\",\"parent.h - 3\"):setPosition(2,3):setBackground(colors.gray):setForeground(colors.white):setSelectionColor(colors.gray,colors.white)\
if(bc==nil)then\
bc=db:addLabel():setPosition(1,\"parent.h\"):setBackground(colors.black):setForeground(colors.white):setZIndex(100):onClick(function()\
_c:show()\
_c:animatePosition(dd/2 -_c:getWidth()/2,__a/2 -_c:getHeight()/2,0.5)end)end end\
return\
{debug=function(...)local _d={...}if(db==nil)then db=cb.getMainFrame()\
if(db~=nil)then dc()else print(...)return end end\
if\
(db:getName()~=\"basaltDebuggingFrame\")then if(db~=_c)then bc:setParent(db)end end;local ad=\"\"for bd,cd in pairs(_d)do\
ad=ad..tostring(cd).. (#_d~=bd and\", \"or\"\")end\
bc:setText(\"[Debug] \"..ad)\
for bd,cd in pairs(bb(ad,ac:getWidth()))do ac:addItem(cd)end\
if(ac:getItemCount()>50)then ac:removeItem(1)end\
ac:setValue(ac:getItem(ac:getItemCount()))\
if(ac.getItemCount()>ac:getHeight())then ac:setOffset(ac:getItemCount()-\
ac:getHeight())end;bc:show()end}end}end\
aa[\"plugins\"][\"animations\"]=function(...)\
local ab,bb,cb,db,_c,ac=math.floor,math.sin,math.cos,math.pi,math.sqrt,math.pow;local function bc(aab,bab,cab)return aab+ (bab-aab)*cab end\
local function cc(aab)return aab end;local function dc(aab)return 1 -aab end\
local function _d(aab)return aab*aab*aab end;local function ad(aab)return dc(_d(dc(aab)))end;local function bd(aab)return\
bc(_d(aab),ad(aab),aab)end\
local function cd(aab)return bb((aab*db)/2)end;local function dd(aab)return dc(cb((aab*db)/2))end;local function __a(aab)return- (\
cb(db*x)-1)/2 end\
local function a_a(aab)local bab=1.70158\
local cab=bab+1;return cab*aab^3 -bab*aab^2 end;local function b_a(aab)return aab^3 end;local function c_a(aab)local bab=(2 *db)/3\
return aab==0 and 0 or(aab==1 and 1 or\
(-2 ^ (10 *\
aab-10)*bb((aab*10 -10.75)*bab)))end\
local function d_a(aab)return\
aab==0 and 0 or 2 ^ (10 *aab-10)end\
local function _aa(aab)return aab==0 and 0 or 2 ^ (10 *aab-10)end\
local function aaa(aab)local bab=1.70158;local cab=bab*1.525;return\
aab<0.5 and( (2 *aab)^2 *\
( (cab+1)*2 *aab-cab))/2 or\
(\
(2 *aab-2)^2 * ( (cab+1)* (aab*2 -2)+cab)+2)/2 end;local function baa(aab)return\
aab<0.5 and 4 *aab^3 or 1 - (-2 *aab+2)^3 /2 end\
local function caa(aab)\
local bab=(2 *db)/4.5\
return\
aab==0 and 0 or(aab==1 and 1 or\
(\
aab<0.5 and- (2 ^ (20 *aab-10)*\
bb((20 *aab-11.125)*bab))/2 or\
(2 ^ (-20 *aab+10)*bb((20 *aab-11.125)*bab))/2 +1))end\
local function daa(aab)return\
aab==0 and 0 or(aab==1 and 1 or\
(\
aab<0.5 and 2 ^ (20 *aab-10)/2 or(2 -2 ^ (-20 *aab+10))/2))end;local function _ba(aab)return\
aab<0.5 and 2 *aab^2 or 1 - (-2 *aab+2)^2 /2 end;local function aba(aab)return\
aab<0.5 and 8 *\
aab^4 or 1 - (-2 *aab+2)^4 /2 end;local function bba(aab)return\
aab<0.5 and 16 *\
aab^5 or 1 - (-2 *aab+2)^5 /2 end;local function cba(aab)\
return aab^2 end;local function dba(aab)return aab^4 end\
local function _ca(aab)return aab^5 end;local function aca(aab)local bab=1.70158;local cab=bab+1;return\
1 +cab* (aab-1)^3 +bab* (aab-1)^2 end;local function bca(aab)return 1 -\
(1 -aab)^3 end\
local function cca(aab)local bab=(2 *db)/3;return\
\
aab==0 and 0 or(aab==1 and 1 or(\
2 ^ (-10 *aab)*bb((aab*10 -0.75)*bab)+1))end\
local function dca(aab)return aab==1 and 1 or 1 -2 ^ (-10 *aab)end;local function _da(aab)return 1 - (1 -aab)* (1 -aab)end;local function ada(aab)return 1 - (\
1 -aab)^4 end;local function bda(aab)\
return 1 - (1 -aab)^5 end\
local function cda(aab)return 1 -_c(1 -ac(aab,2))end;local function dda(aab)return _c(1 -ac(aab-1,2))end\
local function __b(aab)return\
\
aab<0.5 and(1 -_c(\
1 -ac(2 *aab,2)))/2 or(_c(1 -ac(-2 *aab+2,2))+1)/2 end\
local function a_b(aab)local bab=7.5625;local cab=2.75\
if(aab<1 /cab)then return bab*aab*aab elseif(aab<2 /cab)then local dab=aab-\
1.5 /cab;return bab*dab*dab+0.75 elseif(aab<2.5 /cab)then local dab=aab-\
2.25 /cab;return bab*dab*dab+0.9375 else\
local dab=aab-2.625 /cab;return bab*dab*dab+0.984375 end end;local function b_b(aab)return 1 -a_b(1 -aab)end;local function c_b(aab)return\
x<0.5 and(1 -\
a_b(1 -2 *aab))/2 or(1 +a_b(2 *aab-1))/2 end\
local d_b={linear=cc,lerp=bc,flip=dc,easeIn=_d,easeInSine=dd,easeInBack=a_a,easeInCubic=b_a,easeInElastic=c_a,easeInExpo=_aa,easeInQuad=cba,easeInQuart=dba,easeInQuint=_ca,easeInCirc=cda,easeInBounce=b_b,easeOut=ad,easeOutSine=cd,easeOutBack=aca,easeOutCubic=bca,easeOutElastic=cca,easeOutExpo=dca,easeOutQuad=_da,easeOutQuart=ada,easeOutQuint=bda,easeOutCirc=dda,easeOutBounce=a_b,easeInOut=bd,easeInOutSine=__a,easeInOutBack=aaa,easeInOutCubic=baa,easeInOutElastic=caa,easeInOutExpo=daa,easeInOutQuad=_ba,easeInOutQuart=aba,easeInOutQuint=bba,easeInOutCirc=__b,easeInOutBounce=c_b}local _ab=da(\"xmlParser\")\
return\
{VisualObject=function(aab,bab)local cab={}local dab=\"linear\"\
local function _bb(dbb,_cb)for acb,bcb in pairs(cab)do if(bcb.timerId==_cb)then\
return bcb end end end\
local function abb(dbb,_cb,acb,bcb,ccb,dcb,_db,adb,bdb,cdb)local ddb,__c=bdb(dbb)if(cab[_db]~=nil)then\
os.cancelTimer(cab[_db].timerId)end;cab[_db]={}\
cab[_db].call=function()\
local a_c=cab[_db].progress\
local b_c=math.floor(d_b.lerp(ddb,_cb,d_b[dcb](a_c/bcb))+0.5)\
local c_c=math.floor(d_b.lerp(__c,acb,d_b[dcb](a_c/bcb))+0.5)cdb(dbb,b_c,c_c)end\
cab[_db].finished=function()cdb(dbb,_cb,acb)if(adb~=nil)then adb(dbb)end end;cab[_db].timerId=os.startTimer(0.05 +ccb)\
cab[_db].progress=0;cab[_db].duration=bcb;cab[_db].mode=dcb\
dbb:listenEvent(\"other_event\")end\
local function bbb(dbb,_cb,acb,bcb,ccb,...)local dcb={...}if(cab[bcb]~=nil)then\
os.cancelTimer(cab[bcb].timerId)end;cab[bcb]={}local _db=1;cab[bcb].call=function()\
local adb=dcb[_db]ccb(dbb,adb)end end\
local cbb={animatePosition=function(dbb,_cb,acb,bcb,ccb,dcb,_db)dcb=dcb or dab;bcb=bcb or 1;ccb=ccb or 0\
_cb=math.floor(_cb+0.5)acb=math.floor(acb+0.5)\
abb(dbb,_cb,acb,bcb,ccb,dcb,\"position\",_db,dbb.getPosition,dbb.setPosition)return dbb end,animateSize=function(dbb,_cb,acb,bcb,ccb,dcb,_db)dcb=\
dcb or dab;bcb=bcb or 1;ccb=ccb or 0\
abb(dbb,_cb,acb,bcb,ccb,dcb,\"size\",_db,dbb.getSize,dbb.setSize)return dbb end,animateOffset=function(dbb,_cb,acb,bcb,ccb,dcb,_db)dcb=\
dcb or dab;bcb=bcb or 1;ccb=ccb or 0\
abb(dbb,_cb,acb,bcb,ccb,dcb,\"offset\",_db,dbb.getOffset,dbb.setOffset)return dbb end,animateBackground=function(dbb,_cb,acb,bcb,ccb,dcb)ccb=\
ccb or dab;acb=acb or 1;bcb=bcb or 0\
bbb(dbb,_cb,nil,acb,bcb,ccb,\"background\",dcb,dbb.getBackground,dbb.setBackground)return dbb end,doneHandler=function(dbb,_cb,...)\
for acb,bcb in\
pairs(cab)do if(bcb.timerId==_cb)then cab[acb]=nil\
dbb:sendEvent(\"animation_done\",dbb,\"animation_done\",acb)end end end,onAnimationDone=function(dbb,...)\
for _cb,acb in\
pairs(table.pack(...))do if(type(acb)==\"function\")then\
dbb:registerEvent(\"animation_done\",acb)end end;return dbb end,eventHandler=function(dbb,_cb,acb,...)\
aab.eventHandler(dbb,_cb,acb,...)\
if(_cb==\"timer\")then local bcb=_bb(dbb,acb)\
if(bcb~=nil)then\
if(bcb.progress<bcb.duration)then\
bcb.call()bcb.progress=bcb.progress+0.05\
bcb.timerId=os.startTimer(0.05)else bcb.finished()dbb:doneHandler(acb)end end end end}return cbb end}end\
aa[\"plugins\"][\"basaltAdditions\"]=function(...)return\
{basalt=function()return\
{cool=function()print(\"ello\")sleep(2)end}end}end\
aa[\"plugins\"][\"dynamicValues\"]=function(...)local ab=da(\"utils\")local bb=ab.tableCount\
return\
{VisualObject=function(cb,db)\
local _c={}local ac={}local bc={x=\"getX\",y=\"getY\",w=\"getWidth\",h=\"getHeight\"}\
local function cc(bd)\
local cd,dd=pcall(load(\
\"return \"..bd,\"\",nil,{math=math}))if not(cd)then\
error(bd..\" - is not a valid dynamic value string\")end;return dd end\
local function dc(bd,cd,dd)local __a={}local a_a=bc\
for d_a,_aa in pairs(a_a)do for aaa in dd:gmatch(\"%a+%.\"..d_a)do\
local baa=aaa:gsub(\"%.\"..d_a,\"\")\
if(baa~=\"self\")and(baa~=\"parent\")then table.insert(__a,baa)end end end;local b_a=bd:getParent()local c_a={}\
for d_a,_aa in pairs(__a)do\
c_a[_aa]=b_a:getChild(_aa)if(c_a[_aa]==nil)then\
error(\"Dynamic Values - unable to find object: \".._aa)end end;c_a[\"self\"]=bd;c_a[\"parent\"]=b_a\
_c[cd]=function()local d_a=dd\
for _aa,aaa in pairs(a_a)do\
for baa in\
dd:gmatch(\"%w+%.\".._aa)do local caa=c_a[baa:gsub(\"%.\".._aa,\"\")]if(caa~=nil)then\
d_a=d_a:gsub(baa,caa[aaa](caa))else\
error(\"Dynamic Values - unable to find object: \"..baa)end end end;ac[cd]=math.floor(cc(d_a)+0.5)end;_c[cd]()end\
local function _d(bd)\
if(bb(_c)>0)then for dd,__a in pairs(_c)do __a()end\
local cd={x=\"getX\",y=\"getY\",w=\"getWidth\",h=\"getHeight\"}\
for dd,__a in pairs(cd)do\
if(_c[dd]~=nil)then\
if(ac[dd]~=bd[__a](bd))then if(dd==\"x\")or(dd==\"y\")then\
cb.setPosition(bd,\
ac[\"x\"]or bd:getX(),ac[\"y\"]or bd:getY())end;if(dd==\"w\")or(dd==\"h\")then\
cb.setSize(bd,\
ac[\"w\"]or bd:getWidth(),ac[\"h\"]or bd:getHeight())end end end end end end\
local ad={updatePositions=_d,createDynamicValue=dc,setPosition=function(bd,cd,dd,__a)ac.x=cd;ac.y=dd\
if(type(cd)==\"string\")then dc(bd,\"x\",cd)else _c[\"x\"]=nil end\
if(type(dd)==\"string\")then dc(bd,\"y\",dd)else _c[\"y\"]=nil end;cb.setPosition(bd,ac.x,ac.y,__a)return bd end,setSize=function(bd,cd,dd,__a)\
ac.w=cd;ac.h=dd\
if(type(cd)==\"string\")then dc(bd,\"w\",cd)else _c[\"w\"]=nil end\
if(type(dd)==\"string\")then dc(bd,\"h\",dd)else _c[\"h\"]=nil end;cb.setSize(bd,ac.w,ac.h,__a)return bd end,customEventHandler=function(bd,cd,...)\
cb.customEventHandler(bd,cd,...)if\
(cd==\"basalt_FrameReposition\")or(cd==\"basalt_FrameResize\")then _d(bd)end end}return ad end}end\
aa[\"plugins\"][\"shadow\"]=function(...)local ab=da(\"xmlParser\")\
return\
{VisualObject=function(bb)local cb=false\
local db={setShadow=function(_c,ac)cb=ac\
_c:updateDraw()return _c end,getShadow=function(_c)return cb end,draw=function(_c)bb.draw(_c)\
_c:addDraw(\"shadow\",function()\
if(\
cb~=false)then local ac,bc=_c:getSize()\
if(cb)then\
_c:addBackgroundBox(ac+1,2,1,bc,cb)_c:addBackgroundBox(2,bc+1,ac,1,cb)\
_c:addForegroundBox(ac+1,2,1,bc,cb)_c:addForegroundBox(2,bc+1,ac,1,cb)end end end)end}return db end}end\
aa[\"plugins\"][\"textures\"]=function(...)local ab=da(\"images\")local bb=da(\"utils\")\
local cb=da(\"xmlParser\")\
return\
{VisualObject=function(db)local _c,ac=1,true;local bc,cc,dc;local _d=\"default\"\
local ad={addTexture=function(bd,cd,dd)bc=ab.loadImageAsBimg(cd)\
cc=bc[1]\
if(dd)then if(bc.animated)then bd:listenEvent(\"other_event\")local __a=bc[_c].duration or\
bc.secondsPerFrame or 0.2\
dc=os.startTimer(__a)end end;bd:setBackground(false)bd:setForeground(false)\
bd:setDrawState(\"texture-base\",true)bd:updateDraw()return bd end,setTextureMode=function(bd,cd)_d=\
cd or _d;bd:updateDraw()return bd end,setInfinitePlay=function(bd,cd)ac=cd\
return bd end,eventHandler=function(bd,cd,dd,...)db.eventHandler(bd,cd,dd,...)\
if(cd==\"timer\")then\
if\
(dd==dc)then\
if(bc[_c+1]~=nil)then _c=_c+1;cc=bc[_c]local __a=\
bc[_c].duration or bc.secondsPerFrame or 0.2\
dc=os.startTimer(__a)bd:updateDraw()else\
if(ac)then _c=1;cc=bc[1]local __a=\
bc[_c].duration or bc.secondsPerFrame or 0.2\
dc=os.startTimer(__a)bd:updateDraw()end end end end end,draw=function(bd)\
db.draw(bd)\
bd:addDraw(\"texture-base\",function()local cd=bd:getParent()or bd\
local dd,__a=bd:getPosition()local a_a,b_a=bd:getSize()local c_a,d_a=cd:getSize()local _aa=bc.width or\
#bc[_c][1][1]local aaa=bc.height or#bc[_c]\
local baa,caa=0,0\
if(_d==\"center\")then\
baa=dd+math.floor((a_a-_aa)/2 +0.5)-1\
caa=__a+math.floor((b_a-aaa)/2 +0.5)-1 elseif(_d==\"default\")then baa,caa=dd,__a elseif(_d==\"right\")then\
baa,caa=dd+a_a-_aa,__a+b_a-aaa end;local daa=dd-baa;local _ba=__a-caa;if baa<dd then baa=dd;_aa=_aa-daa end;if\
caa<__a then caa=__a;aaa=aaa-_ba end;if baa+_aa>dd+a_a then\
_aa=(dd+a_a)-baa end\
if caa+aaa>__a+b_a then aaa=(__a+b_a)-caa end\
for k=1,aaa do if(cc[k+_ba]~=nil)then local aba,bba,cba=table.unpack(cc[k+_ba])\
bd:addBlit(1,k,aba:sub(daa,\
daa+_aa),bba:sub(daa,daa+_aa),cba:sub(daa,daa+_aa))end end end,1)bd:setDrawState(\"texture-base\",false)end}return ad end}end\
aa[\"plugins\"][\"pixelbox\"]=function(...)\
local ab,bb,cb=table.sort,table.concat,string.char;local function db(dc,_d)return dc[2]>_d[2]end\
local _c={{5,256,16,8,64,32},{4,16,16384,256,128},[4]={4,64,1024,256,128},[8]={4,512,2048,256,1},[16]={4,2,16384,256,1},[32]={4,8192,4096,256,1},[64]={4,4,1024,256,1},[128]={6,32768,256,1024,2048,4096,16384},[256]={6,1,128,2,512,4,8192},[512]={4,8,2048,256,128},[1024]={4,4,64,128,32768},[2048]={4,512,8,128,32768},[4096]={4,8192,32,128,32768},[8192]={3,32,4096,256128},[16384]={4,2,16,128,32768},[32768]={5,128,1024,2048,4096,16384}}local ac={}for i=0,15 do ac[(\"%x\"):format(i)]=2 ^i end\
local bc={}for i=0,15 do bc[2 ^i]=(\"%x\"):format(i)end\
local function cc(dc,_d)_d=_d or\"f\"local ad,bd=#\
dc[1],#dc;local cd={}local dd={}local __a=false\
local function a_a()\
for y=1,bd*3 do for x=1,ad*2 do\
if not dd[y]then dd[y]={}end;dd[y][x]=_d end end;for _aa,aaa in ipairs(dc)do\
for x=1,#aaa do local baa=aaa:sub(x,x)dd[_aa][x]=ac[baa]end end end;a_a()local function b_a(_aa,aaa)ad,bd=_aa,aaa;dd={}__a=false;a_a()end\
local function c_a(_aa,aaa,baa,caa,daa,_ba)\
local aba={_aa,aaa,baa,caa,daa,_ba}local bba={}local cba={}local dba=0\
for i=1,6 do local cca=aba[i]if not bba[cca]then dba=dba+1\
bba[cca]={0,dba}end;local dca=bba[cca]local _da=dca[1]+1;dca[1]=_da\
cba[dca[2]]={cca,_da}end;local _ca=#cba\
while _ca>2 do ab(cba,db)local cca=_c[cba[_ca][1]]\
local dca,_da=1,false;local ada=_ca-1\
for i=2,cca[1]do if _da then break end;local dda=cca[i]for j=1,ada do if cba[j][1]==dda then dca=j\
_da=true;break end end end;local bda,cda=cba[_ca][1],cba[dca][1]\
for i=1,6 do if aba[i]==bda then aba[i]=cda\
local dda=cba[dca]dda[2]=dda[2]+1 end end;cba[_ca]=nil;_ca=_ca-1 end;local aca=128;local bca=aba[6]if aba[1]~=bca then aca=aca+1 end;if aba[2]~=bca then aca=aca+\
2 end;if aba[3]~=bca then aca=aca+4 end;if\
aba[4]~=bca then aca=aca+8 end;if aba[5]~=bca then aca=aca+16 end;if\
cba[1][1]==aba[6]then return cb(aca),cba[2][1],aba[6]else\
return cb(aca),cba[1][1],aba[6]end end\
local function d_a()local _aa=ad*2;local aaa=0\
for y=1,bd*3,3 do aaa=aaa+1;local baa=dd[y]local caa=dd[y+1]local daa=dd[y+2]\
local _ba,aba,bba={},{},{}local cba=0\
for x=1,_aa,2 do local dba=x+1\
local _ca,aca,bca,cca,dca,_da=baa[x],baa[dba],caa[x],caa[dba],daa[x],daa[dba]local ada,bda,cda=\" \",1,_ca;if not(\
aca==_ca and bca==_ca and cca==_ca and dca==_ca and _da==_ca)then\
ada,bda,cda=c_a(_ca,aca,bca,cca,dca,_da)end;cba=cba+1\
_ba[cba]=ada;aba[cba]=bc[bda]bba[cba]=bc[cda]end;cd[aaa]={bb(_ba),bb(aba),bb(bba)}end;__a=true end\
return\
{convert=d_a,generateCanvas=a_a,setSize=b_a,getSize=function()return ad,bd end,set=function(_aa,aaa)dc=_aa;_d=aaa or _d;dd={}__a=false;a_a()end,get=function(_aa)if\
not __a then d_a()end\
return _aa~=nil and cd[_aa]or cd end}end\
return\
{Image=function(dc,_d)\
return\
{shrink=function(ad)local bd=ad:getImageFrame(1)local cd={}for __a,a_a in pairs(bd)do if(type(__a)==\"number\")then\
table.insert(cd,a_a[3])end end\
local dd=cc(cd,ad:getBackground()).get()ad:setImage(dd)return ad end,getShrinkedImage=function(ad)\
local bd=ad:getImageFrame(1)local cd={}for dd,__a in pairs(bd)do\
if(type(dd)==\"number\")then table.insert(cd,__a[3])end end;return\
cc(cd,ad:getBackground()).get()end}end}end\
aa[\"plugins\"][\"reactive\"]=function(...)local ab=da(\"xmlParser\")local bb={}\
bb.currentEffect=nil\
bb.observable=function(ac)local bc=ac;local cc={}\
local dc=function()if(bb.currentEffect~=nil)then\
table.insert(cc,bb.currentEffect)\
table.insert(bb.currentEffect.dependencies,cc)end;return bc end\
local _d=function(ad)bc=ad;local bd={}for cd,dd in ipairs(cc)do bd[cd]=dd end;for cd,dd in ipairs(bd)do\
dd.execute()end end;return dc,_d end\
bb.untracked=function(ac)local bc=bb.currentEffect;bb.currentEffect=nil;local cc=ac()\
bb.currentEffect=bc;return cc end\
bb.effect=function(ac)local bc={dependencies={}}\
local cc=function()bb.clearEffectDependencies(bc)\
local dc=bb.currentEffect;bb.currentEffect=bc;ac()bb.currentEffect=dc end;bc.execute=cc;bc.execute()end\
bb.derived=function(ac)local bc,cc=bb.observable()\
bb.effect(function()cc(ac())end)return bc end\
bb.clearEffectDependencies=function(ac)\
for bc,cc in ipairs(ac.dependencies)do for dc,_d in ipairs(cc)do if(_d==ac)then\
table.remove(cc,dc)end end end;ac.dependencies={}end\
local cb={fromXML=function(ac)local bc=ab.parseText(ac)local cc=nil\
for dc,_d in ipairs(bc)do if(_d.tag==\"script\")then cc=_d.value\
table.remove(bc,dc)break end end;return{nodes=bc,script=cc}end}\
local db=function(ac,bc)return load(ac,nil,\"t\",bc)()end\
local _c=function(ac,bc,cc,dc)\
bc(ac,function(...)local _d,ad=pcall(load(cc,nil,\"t\",dc))if not _d then\
error(\"XML Error: \"..ad)end end)end\
return\
{basalt=function(ac)\
local bc=function(dc,_d)local ad=_d[dc.tag]\
if(ad~=nil)then local dd={}for __a,a_a in pairs(dc.attributes)do\
dd[__a]=load(\"return \"..a_a,nil,\"t\",_d)end\
return ac.createObjectsFromLayout(ad,dd)end;local bd=dc.tag:gsub(\"^%l\",string.upper)\
local cd=ac:createObject(bd,dc.attributes[\"id\"])\
for dd,__a in pairs(dc.attributes)do\
if(dd:sub(1,2)==\"on\")then\
_c(cd,cd[dd],__a..\"()\",_d)else\
local a_a=function()local b_a=load(\"return \"..__a,nil,\"t\",_d)()\
cd:setProperty(dd,b_a)end;ac.effect(a_a)end end\
for dd,__a in ipairs(dc.children)do\
local a_a=ac.createObjectsFromXMLNode(__a,_d)for b_a,c_a in ipairs(a_a)do cd:addChild(c_a)end end;return{cd}end\
local cc={observable=bb.observable,untracked=bb.untracked,effect=bb.effect,derived=bb.derived,layout=function(dc)if(not fs.exists(dc))then\
error(\"Can't open file \"..dc)end;local _d=fs.open(dc,\"r\")\
local ad=_d.readAll()_d.close()return cb.fromXML(ad)end,createObjectsFromLayout=function(dc,_d)\
local ad=_ENV;ad.props={}local bd={}for dd,__a in pairs(_d)do\
bd[dd]=ac.derived(function()return __a()end)end\
setmetatable(ad.props,{__index=function(dd,__a)return bd[__a]()end})if(dc.script~=nil)then db(dc.script,ad)end;local cd={}for dd,__a in\
ipairs(dc.nodes)do local a_a=bc(__a,ad)\
for b_a,c_a in ipairs(a_a)do table.insert(cd,c_a)end end;return cd end}return cc end,Container=function(ac,bc)\
local cc={loadLayout=function(dc,_d,ad)\
local bd={}if(ad==nil)then ad={}end\
for __a,a_a in pairs(ad)do bd[__a]=function()return a_a end end;local cd=bc.layout(_d)\
local dd=bc.createObjectsFromLayout(cd,bd)for __a,a_a in ipairs(dd)do dc:addChild(a_a)end;return dc end}return cc end}end\
aa[\"plugins\"][\"themes\"]=function(...)\
local ab={BaseFrameBG=colors.lightGray,BaseFrameText=colors.black,FrameBG=colors.gray,FrameText=colors.black,ButtonBG=colors.gray,ButtonText=colors.black,CheckboxBG=colors.lightGray,CheckboxText=colors.black,InputBG=colors.black,InputText=colors.lightGray,TextfieldBG=colors.black,TextfieldText=colors.white,ListBG=colors.gray,ListText=colors.black,MenubarBG=colors.gray,MenubarText=colors.black,DropdownBG=colors.gray,DropdownText=colors.black,RadioBG=colors.gray,RadioText=colors.black,SelectionBG=colors.black,SelectionText=colors.lightGray,GraphicBG=colors.black,ImageBG=colors.black,PaneBG=colors.black,ProgramBG=colors.black,ProgressbarBG=colors.gray,ProgressbarText=colors.black,ProgressbarActiveBG=colors.black,ScrollbarBG=colors.lightGray,ScrollbarText=colors.gray,ScrollbarSymbolColor=colors.black,SliderBG=false,SliderText=colors.gray,SliderSymbolColor=colors.black,SwitchBG=colors.lightGray,SwitchText=colors.gray,LabelBG=false,LabelText=colors.black,GraphBG=colors.gray,GraphText=colors.black}\
local bb={Container=function(cb,db,_c)local ac={}\
local bc={getTheme=function(cc,dc)local _d=cc:getParent()return ac[dc]or(_d~=nil and _d:getTheme(dc)or\
ab[dc])end,setTheme=function(cc,dc,_d)\
if(\
type(dc)==\"table\")then ac=dc elseif(type(dc)==\"string\")then ac[dc]=_d end;cc:updateDraw()return cc end}return bc end,basalt=function()\
return\
{getTheme=function(cb)return\
ab[cb]end,setTheme=function(cb,db)if(type(cb)==\"table\")then ab=cb elseif(type(cb)==\"string\")then\
ab[cb]=db end end}end}\
for cb,db in\
pairs({\"BaseFrame\",\"Frame\",\"ScrollableFrame\",\"MovableFrame\",\"Button\",\"Checkbox\",\"Dropdown\",\"Graph\",\"Graphic\",\"Input\",\"Label\",\"List\",\"Menubar\",\"Pane\",\"Program\",\"Progressbar\",\"Radio\",\"Scrollbar\",\"Slider\",\"Switch\",\"Textfield\"})do\
bb[db]=function(_c,ac,bc)\
local cc={init=function(dc)if(_c.init(dc))then local _d=dc:getParent()or dc\
dc:setBackground(_d:getTheme(db..\"BG\"))\
dc:setForeground(_d:getTheme(db..\"Text\"))end end}return cc end end;return bb end;aa[\"libraries\"]={}\
aa[\"libraries\"][\"basaltDraw\"]=function(...)\
local ab=da(\"tHex\")local bb=da(\"utils\")local cb=bb.splitString;local db,_c=string.sub,string.rep\
return\
function(ac)local bc=ac or\
term.current()local cc;local dc,_d=bc.getSize()local ad={}local bd={}local cd={}\
local dd;local __a={}local function a_a()dd=_c(\" \",dc)\
for n=0,15 do local caa=2 ^n;local daa=ab[caa]__a[caa]=_c(daa,dc)end end;a_a()\
local function b_a()a_a()local caa=dd\
local daa=__a[colors.white]local _ba=__a[colors.black]\
for currentY=1,_d do\
ad[currentY]=db(\
ad[currentY]==nil and caa or\
ad[currentY]..caa:sub(1,dc-ad[currentY]:len()),1,dc)\
cd[currentY]=db(cd[currentY]==nil and daa or cd[currentY]..daa:sub(1,dc-\
cd[currentY]:len()),1,dc)\
bd[currentY]=db(bd[currentY]==nil and _ba or bd[currentY].._ba:sub(1,dc-\
bd[currentY]:len()),1,dc)end end;b_a()\
local function c_a(caa,daa,_ba,aba,bba)\
if#_ba==#aba and#_ba==#bba then\
if daa>=1 and daa<=_d then\
if\
caa+#_ba>0 and caa<=dc then local cba,dba,_ca;local aca,bca,cca=ad[daa],cd[daa],bd[daa]\
local dca,_da=1,#_ba\
if caa<1 then dca=1 -caa+1;_da=dc-caa+1 elseif caa+#_ba>dc then _da=dc-caa+1 end;cba=db(aca,1,caa-1)..db(_ba,dca,_da)dba=\
db(bca,1,caa-1)..db(aba,dca,_da)_ca=db(cca,1,caa-1)..\
db(bba,dca,_da)\
if caa+#_ba<=dc then cba=cba..\
db(aca,caa+#_ba,dc)\
dba=dba..db(bca,caa+#_ba,dc)_ca=_ca..db(cca,caa+#_ba,dc)end;ad[daa],cd[daa],bd[daa]=cba,dba,_ca end end end end\
local function d_a(caa,daa,_ba)\
if daa>=1 and daa<=_d then\
if caa+#_ba>0 and caa<=dc then local aba;local bba=ad[daa]\
local cba,dba=1,#_ba\
if caa<1 then cba=1 -caa+1;dba=dc-caa+1 elseif caa+#_ba>dc then dba=dc-caa+1 end;aba=db(bba,1,caa-1)..db(_ba,cba,dba)\
if\
caa+#_ba<=dc then aba=aba..db(bba,caa+#_ba,dc)end;ad[daa]=aba end end end\
local function _aa(caa,daa,_ba)\
if daa>=1 and daa<=_d then\
if caa+#_ba>0 and caa<=dc then local aba;local bba=bd[daa]\
local cba,dba=1,#_ba\
if caa<1 then cba=1 -caa+1;dba=dc-caa+1 elseif caa+#_ba>dc then dba=dc-caa+1 end;aba=db(bba,1,caa-1)..db(_ba,cba,dba)\
if\
caa+#_ba<=dc then aba=aba..db(bba,caa+#_ba,dc)end;bd[daa]=aba end end end\
local function aaa(caa,daa,_ba)\
if daa>=1 and daa<=_d then\
if caa+#_ba>0 and caa<=dc then local aba;local bba=cd[daa]\
local cba,dba=1,#_ba\
if caa<1 then cba=1 -caa+1;dba=dc-caa+1 elseif caa+#_ba>dc then dba=dc-caa+1 end;aba=db(bba,1,caa-1)..db(_ba,cba,dba)\
if\
caa+#_ba<=dc then aba=aba..db(bba,caa+#_ba,dc)end;cd[daa]=aba end end end\
local baa={setSize=function(caa,daa)dc,_d=caa,daa;b_a()end,setMirror=function(caa)cc=caa end,setBG=function(caa,daa,_ba)\
_aa(caa,daa,_ba)end,setText=function(caa,daa,_ba)d_a(caa,daa,_ba)end,setFG=function(caa,daa,_ba)\
aaa(caa,daa,_ba)end,blit=function(caa,daa,_ba,aba,bba)c_a(caa,daa,_ba,aba,bba)end,drawBackgroundBox=function(caa,daa,_ba,aba,bba)\
local cba=_c(ab[bba],_ba)for n=1,aba do _aa(caa,daa+ (n-1),cba)end end,drawForegroundBox=function(caa,daa,_ba,aba,bba)\
local cba=_c(ab[bba],_ba)for n=1,aba do aaa(caa,daa+ (n-1),cba)end end,drawTextBox=function(caa,daa,_ba,aba,bba)\
local cba=_c(bba,_ba)for n=1,aba do d_a(caa,daa+ (n-1),cba)end end,update=function()\
local caa,daa=bc.getCursorPos()local _ba=false\
if(bc.getCursorBlink~=nil)then _ba=bc.getCursorBlink()end;bc.setCursorBlink(false)if(cc~=nil)then\
cc.setCursorBlink(false)end\
for n=1,_d do bc.setCursorPos(1,n)\
bc.blit(ad[n],cd[n],bd[n])if(cc~=nil)then cc.setCursorPos(1,n)\
cc.blit(ad[n],cd[n],bd[n])end end;bc.setBackgroundColor(colors.black)\
bc.setCursorBlink(_ba)bc.setCursorPos(caa,daa)\
if(cc~=nil)then\
cc.setBackgroundColor(colors.black)cc.setCursorBlink(_ba)cc.setCursorPos(caa,daa)end end,setTerm=function(caa)\
bc=caa end}return baa end end\
aa[\"libraries\"][\"basaltEvent\"]=function(...)\
return\
function()local ab={}\
local bb={registerEvent=function(cb,db,_c)\
if(ab[db]==nil)then ab[db]={}end;table.insert(ab[db],_c)end,removeEvent=function(cb,db,_c)ab[db][_c[db]]=\
nil end,hasEvent=function(cb,db)return ab[db]~=nil end,getEventCount=function(cb,db)return\
ab[db]~=nil and#ab[db]or 0 end,getEvents=function(cb)\
local db={}for _c,ac in pairs(ab)do table.insert(db,_c)end;return db end,clearEvent=function(cb,db)ab[db]=\
nil end,clear=function(cb,db)ab={}end,sendEvent=function(cb,db,...)local _c\
if(ab[db]~=nil)then for ac,bc in pairs(ab[db])do\
local cc=bc(...)if(cc==false)then _c=cc end end end;return _c end}bb.__index=bb;return bb end end\
aa[\"libraries\"][\"bimg\"]=function(...)local ab,bb=string.sub,string.rep\
local function cb(db,_c)local ac,bc=0,0\
local cc,dc,_d={},{},{}local ad,bd=1,1;local cd={}\
local function dd()\
for y=1,bc do if(cc[y]==nil)then cc[y]=bb(\" \",ac)else cc[y]=cc[y]..\
bb(\" \",ac-#cc[y])end;if\
(dc[y]==nil)then dc[y]=bb(\"0\",ac)else\
dc[y]=dc[y]..bb(\"0\",ac-#dc[y])end\
if(_d[y]==nil)then _d[y]=bb(\"f\",ac)else _d[y]=\
_d[y]..bb(\"f\",ac-#_d[y])end end end\
local __a=function(d_a,_aa,aaa)ad=_aa or ad;bd=aaa or bd\
if(cc[bd]==nil)then cc[bd]=bb(\" \",ad-1)..d_a..\
bb(\" \",ac- (#d_a+ad))else cc[bd]=\
ab(cc[bd],1,ad-1)..\
bb(\" \",ad-#cc[bd])..d_a..ab(cc[bd],ad+#d_a,ac)end;if(#cc[bd]>ac)then ac=#cc[bd]end;if(bd>bc)then bc=bd end\
_c.updateSize(ac,bc)end\
local a_a=function(d_a,_aa,aaa)ad=_aa or ad;bd=aaa or bd\
if(_d[bd]==nil)then _d[bd]=bb(\"f\",ad-1)..d_a..\
bb(\"f\",ac- (#d_a+ad))else _d[bd]=\
ab(_d[bd],1,ad-1)..\
bb(\"f\",ad-#_d[bd])..d_a..ab(_d[bd],ad+#d_a,ac)end;if(#_d[bd]>ac)then ac=#_d[bd]end;if(bd>bc)then bc=bd end\
_c.updateSize(ac,bc)end\
local b_a=function(d_a,_aa,aaa)ad=_aa or ad;bd=aaa or bd\
if(dc[bd]==nil)then dc[bd]=bb(\"0\",ad-1)..d_a..\
bb(\"0\",ac- (#d_a+ad))else dc[bd]=\
ab(dc[bd],1,ad-1)..\
bb(\"0\",ad-#dc[bd])..d_a..ab(dc[bd],ad+#d_a,ac)end;if(#dc[bd]>ac)then ac=#dc[bd]end;if(bd>bc)then bc=bd end\
_c.updateSize(ac,bc)end\
local function c_a(d_a)cd={}cc,dc,_d={},{},{}\
for _aa,aaa in pairs(db)do if(type(_aa)==\"string\")then cd[_aa]=aaa else\
cc[_aa],dc[_aa],_d[_aa]=aaa[1],aaa[2],aaa[3]end end;_c.updateSize(ac,bc)end\
if(db~=nil)then if(#db>0)then ac=#db[1][1]bc=#db;c_a(db)end end\
return\
{recalculateSize=dd,setFrame=c_a,getFrame=function()local d_a={}for _aa,aaa in pairs(cc)do\
table.insert(d_a,{aaa,dc[_aa],_d[_aa]})end\
for _aa,aaa in pairs(cd)do d_a[_aa]=aaa end;return d_a,ac,bc end,getImage=function()\
local d_a={}for _aa,aaa in pairs(cc)do\
table.insert(d_a,{aaa,dc[_aa],_d[_aa]})end;return d_a end,setFrameData=function(d_a,_aa)\
if(\
_aa~=nil)then cd[d_a]=_aa else if(type(d_a)==\"table\")then cd=d_a end end end,setFrameImage=function(d_a)\
for _aa,aaa in pairs(d_a.t)do\
cc[_aa]=d_a.t[_aa]dc[_aa]=d_a.fg[_aa]_d[_aa]=d_a.bg[_aa]end end,getFrameImage=function()\
return{t=cc,fg=dc,bg=_d}end,getFrameData=function(d_a)if(d_a~=nil)then return cd[d_a]else return cd end end,blit=function(d_a,_aa,aaa,baa,caa)\
__a(d_a,baa,caa)b_a(_aa,baa,caa)a_a(aaa,baa,caa)end,text=__a,fg=b_a,bg=a_a,getSize=function()return\
ac,bc end,setSize=function(d_a,_aa)local aaa,baa,caa={},{},{}\
for _y=1,_aa do\
if(cc[_y]~=nil)then aaa[_y]=ab(cc[_y],1,d_a)..bb(\" \",\
d_a-ac)else aaa[_y]=bb(\" \",d_a)end;if(dc[_y]~=nil)then\
baa[_y]=ab(dc[_y],1,d_a)..bb(\"0\",d_a-ac)else baa[_y]=bb(\"0\",d_a)end;if\
(_d[_y]~=nil)then caa[_y]=ab(_d[_y],1,d_a)..bb(\"f\",d_a-ac)else\
caa[_y]=bb(\"f\",d_a)end end;cc,dc,_d=aaa,baa,caa;ac,bc=d_a,_aa end}end\
return\
function(db)local _c={}\
local ac={creator=\"Bimg Library by NyoriE\",date=os.date(\"!%Y-%m-%dT%TZ\")}local bc,cc=0,0;if(db~=nil)then\
if(db[1][1][1]~=nil)then bc,cc=ac.width or#db[1][1][1],\
ac.height or#db[1]end end;local dc={}\
local function _d(cd,dd)cd=cd or#_c+1\
local __a=cb(dd,dc)table.insert(_c,cd,__a)if(dd==nil)then\
_c[cd].setSize(bc,cc)end;return __a end;local function ad(cd)table.remove(_c,cd or#_c)end\
local function bd(cd,dd)\
local __a=_c[cd]\
if(__a~=nil)then local a_a=cd+dd;if(a_a>=1)and(a_a<=#_c)then table.remove(_c,cd)\
table.insert(_c,a_a,__a)end end end\
dc={updateSize=function(cd,dd,__a)local a_a=__a==true and true or false\
if(cd>bc)then a_a=true;bc=cd end;if(dd>cc)then a_a=true;cc=dd end\
if(a_a)then for b_a,c_a in pairs(_c)do c_a.setSize(bc,cc)\
c_a.recalculateSize()end end end,text=function(cd,dd,__a,a_a)\
local b_a=_c[cd]if(b_a==nil)then b_a=_d(cd)end;b_a.text(dd,__a,a_a)end,fg=function(cd,dd,__a,a_a)\
local b_a=_c[cd]if(b_a==nil)then b_a=_d(cd)end;b_a.fg(dd,__a,a_a)end,bg=function(cd,dd,__a,a_a)\
local b_a=_c[cd]if(b_a==nil)then b_a=_d(cd)end;b_a.bg(dd,__a,a_a)end,blit=function(cd,dd,__a,a_a,b_a,c_a)\
local d_a=_c[cd]if(d_a==nil)then d_a=_d(cd)end;d_a.blit(dd,__a,a_a,b_a,c_a)end,setSize=function(cd,dd)\
bc=cd;cc=dd;for __a,a_a in pairs(_c)do a_a.setSize(cd,dd)end end,getFrame=function(cd)if(\
_c[cd]~=nil)then return _c[cd].getFrame()end end,getFrameObjects=function()return\
_c end,getFrames=function()local cd={}for dd,__a in pairs(_c)do local a_a=__a.getFrame()\
table.insert(cd,a_a)end;return cd end,getFrameObject=function(cd)return\
_c[cd]end,addFrame=function(cd)if(#_c<=1)then\
if(ac.animated==nil)then ac.animated=true end\
if(ac.secondsPerFrame==nil)then ac.secondsPerFrame=0.2 end end;return _d(cd)end,removeFrame=ad,moveFrame=bd,setFrameData=function(cd,dd,__a)\
if(\
_c[cd]~=nil)then _c[cd].setFrameData(dd,__a)end end,getFrameData=function(cd,dd)if(_c[cd]~=nil)then return\
_c[cd].getFrameData(dd)end end,getSize=function()return\
bc,cc end,setAnimation=function(cd)ac.animation=cd end,setMetadata=function(cd,dd)if(dd~=nil)then ac[cd]=dd else if(\
type(cd)==\"table\")then ac=cd end end end,getMetadata=function(cd)if(\
cd~=nil)then return ac[cd]else return ac end end,createBimg=function()\
local cd={}\
for dd,__a in pairs(_c)do local a_a=__a.getFrame()table.insert(cd,a_a)end;for dd,__a in pairs(ac)do cd[dd]=__a end;cd.width=bc;cd.height=cc;return cd end}\
if(db~=nil)then\
for cd,dd in pairs(db)do if(type(cd)==\"string\")then ac[cd]=dd end end\
if(ac.width==nil)or(ac.height==nil)then\
bc=ac.width or#db[1][1][1]cc=ac.height or#db[1]dc.updateSize(bc,cc,true)end\
for cd,dd in pairs(db)do if(type(cd)==\"number\")then _d(cd,dd)end end else _d(1)end;return dc end end\
aa[\"libraries\"][\"basaltMon\"]=function(...)\
local ab={[colors.white]=\"0\",[colors.orange]=\"1\",[colors.magenta]=\"2\",[colors.lightBlue]=\"3\",[colors.yellow]=\"4\",[colors.lime]=\"5\",[colors.pink]=\"6\",[colors.gray]=\"7\",[colors.lightGray]=\"8\",[colors.cyan]=\"9\",[colors.purple]=\"a\",[colors.blue]=\"b\",[colors.brown]=\"c\",[colors.green]=\"d\",[colors.red]=\"e\",[colors.black]=\"f\"}local bb,cb,db,_c=type,string.len,string.rep,string.sub\
return\
function(ac)local bc={}\
for _ba,aba in pairs(ac)do\
bc[_ba]={}\
for bba,cba in pairs(aba)do local dba=peripheral.wrap(cba)if(dba==nil)then\
error(\"Unable to find monitor \"..cba)end;bc[_ba][bba]=dba\
bc[_ba][bba].name=cba end end;local cc,dc,_d,ad,bd,cd,dd,__a=1,1,1,1,0,0,0,0;local a_a,b_a=false,1\
local c_a,d_a=colors.white,colors.black\
local function _aa()local _ba,aba=0,0\
for bba,cba in pairs(bc)do local dba,_ca=0,0\
for aca,bca in pairs(cba)do local cca,dca=bca.getSize()\
dba=dba+cca;_ca=dca>_ca and dca or _ca end;_ba=_ba>dba and _ba or dba;aba=aba+_ca end;dd,__a=_ba,aba end;_aa()\
local function aaa()local _ba=0;local aba,bba=0,0\
for cba,dba in pairs(bc)do local _ca=0;local aca=0\
for bca,cca in pairs(dba)do\
local dca,_da=cca.getSize()if(cc-_ca>=1)and(cc-_ca<=dca)then aba=bca end;cca.setCursorPos(\
cc-_ca,dc-_ba)_ca=_ca+dca\
if(aca<_da)then aca=_da end end;if(dc-_ba>=1)and(dc-_ba<=aca)then bba=cba end\
_ba=_ba+aca end;_d,ad=aba,bba end;aaa()\
local function baa(_ba,...)local aba={...}return\
function()for bba,cba in pairs(bc)do for dba,_ca in pairs(cba)do\
_ca[_ba](table.unpack(aba))end end end end\
local function caa()baa(\"setCursorBlink\",false)()\
if not(a_a)then return end;if(bc[ad]==nil)then return end;local _ba=bc[ad][_d]\
if(_ba==nil)then return end;_ba.setCursorBlink(a_a)end\
local function daa(_ba,aba,bba)if(bc[ad]==nil)then return end;local cba=bc[ad][_d]\
if(cba==nil)then return end;cba.blit(_ba,aba,bba)local dba,_ca=cba.getSize()\
if\
(cb(_ba)+cc>dba)then local aca=bc[ad][_d+1]if(aca~=nil)then aca.blit(_ba,aba,bba)_d=_d+1;cc=cc+\
cb(_ba)end end;aaa()end\
return\
{clear=baa(\"clear\"),setCursorBlink=function(_ba)a_a=_ba;caa()end,getCursorBlink=function()return a_a end,getCursorPos=function()return cc,dc end,setCursorPos=function(_ba,aba)\
cc,dc=_ba,aba;aaa()caa()end,setTextScale=function(_ba)\
baa(\"setTextScale\",_ba)()_aa()aaa()b_a=_ba end,getTextScale=function()return b_a end,blit=function(_ba,aba,bba)\
daa(_ba,aba,bba)end,write=function(_ba)_ba=tostring(_ba)local aba=cb(_ba)\
daa(_ba,db(ab[c_a],aba),db(ab[d_a],aba))end,getSize=function()return dd,__a end,setBackgroundColor=function(_ba)\
baa(\"setBackgroundColor\",_ba)()d_a=_ba end,setTextColor=function(_ba)\
baa(\"setTextColor\",_ba)()c_a=_ba end,calculateClick=function(_ba,aba,bba)local cba=0\
for dba,_ca in pairs(bc)do local aca=0;local bca=0\
for cca,dca in pairs(_ca)do\
local _da,ada=dca.getSize()if(dca.name==_ba)then return aba+aca,bba+cba end\
aca=aca+_da;if(ada>bca)then bca=ada end end;cba=cba+bca end;return aba,bba end}end end\
aa[\"libraries\"][\"basaltLogs\"]=function(...)local ab=\"\"local bb=\"basaltLog.txt\"local cb=\"Debug\"\
fs.delete(\
ab~=\"\"and ab..\"/\"..bb or bb)\
local db={__call=function(_c,ac,bc)if(ac==nil)then return end\
local cc=ab~=\"\"and ab..\"/\"..bb or bb\
local dc=fs.open(cc,fs.exists(cc)and\"a\"or\"w\")\
dc.writeLine(\"[Basalt][\"..\
os.date(\"%Y-%m-%d %H:%M:%S\")..\"][\".. (bc and bc or cb)..\
\"]: \"..tostring(ac))dc.close()end}return setmetatable({},db)end\
aa[\"libraries\"][\"xmlParser\"]=function(...)\
local ab={new=function(db)\
return\
{tag=db,value=nil,attributes={},children={},addChild=function(_c,ac)\
table.insert(_c.children,ac)end,addAttribute=function(_c,ac,bc)_c.attributes[ac]=bc end}end}\
local bb=function(db,_c)\
local ac,bc=string.gsub(_c,\"(%w+)=([\\\"'])(.-)%2\",function(_d,ad,bd)\
db:addAttribute(_d,\"\\\"\"..bd..\"\\\"\")end)\
local cc,dc=string.gsub(_c,\"(%w+)={(.-)}\",function(_d,ad)db:addAttribute(_d,ad)end)end\
local cb={parseText=function(db)local _c={}local ac=ab.new()table.insert(_c,ac)local bc,cc,dc,_d,ad;local bd,cd=1,1\
while true do\
bc,cd,cc,dc,_d,ad=string.find(db,\"<(%/?)([%w_:]+)(.-)(%/?)>\",bd)if not bc then break end;local __a=string.sub(db,bd,bc-1)if not\
string.find(__a,\"^%s*$\")then local a_a=(ac.value or\"\")..__a\
_c[#_c].value=a_a end\
if ad==\"/\"then local a_a=ab.new(dc)\
bb(a_a,_d)ac:addChild(a_a)elseif cc==\"\"then local a_a=ab.new(dc)bb(a_a,_d)\
table.insert(_c,a_a)ac=a_a else local a_a=table.remove(_c)ac=_c[#_c]\
if#_c<1 then error(\"XMLParser: nothing to close with \"..\
dc)end;if a_a.tag~=dc then\
error(\"XMLParser: trying to close \"..a_a.tag..\" with \"..dc)end;ac:addChild(a_a)end;bd=cd+1 end;local dd=string.sub(db,bd)if#_c>1 then\
error(\"XMLParser: unclosed \".._c[#_c].tag)end;return ac.children end}return cb end\
aa[\"libraries\"][\"images\"]=function(...)local ab,bb=string.sub,math.floor;local function cb(ad)return\
{[1]={{},{},paintutils.loadImage(ad)}},\"bimg\"end;local function db(ad)return\
paintutils.loadImage(ad),\"nfp\"end\
local function _c(ad,bd)\
local cd=fs.open(ad,bd and\"rb\"or\"r\")if(cd==nil)then\
error(\"Path - \"..ad..\" doesn't exist!\")end\
local dd=textutils.unserialize(cd.readAll())cd.close()if(dd~=nil)then return dd,\"bimg\"end end;local function ac(ad)end;local function bc(ad)end;local function cc(ad,bd,cd)\
if(ab(ad,-4)==\".bimg\")then return _c(ad,cd)elseif\
(ab(ad,-3)==\".bbf\")then return ac(ad,cd)else return db(ad,cd)end end;local function dc(ad)\
if\
(ad:find(\".bimg\"))then return _c(ad)elseif(ad:find(\".bbf\"))then return bc(ad)else return cb(ad)end end\
local function _d(ad,bd,cd)local dd,__a=ad.width or#\
ad[1][1][1],ad.height or#ad[1]local a_a={}\
for b_a,c_a in\
pairs(ad)do\
if(type(b_a)==\"number\")then local d_a={}\
for y=1,cd do local _aa,aaa,baa=\"\",\"\",\"\"\
local caa=bb(y/cd*__a+0.5)\
if(c_a[caa]~=nil)then\
for x=1,bd do local daa=bb(x/bd*dd+0.5)_aa=_aa..\
ab(c_a[caa][1],daa,daa)\
aaa=aaa..ab(c_a[caa][2],daa,daa)baa=baa..ab(c_a[caa][3],daa,daa)end;table.insert(d_a,{_aa,aaa,baa})end end;table.insert(a_a,b_a,d_a)else a_a[b_a]=c_a end end;a_a.width=bd;a_a.height=cd;return a_a end\
return{loadNFP=db,loadBIMG=_c,loadImage=cc,resizeBIMG=_d,loadImageAsBimg=dc}end\
aa[\"libraries\"][\"utils\"]=function(...)local ab=da(\"tHex\")\
local bb,cb,db,_c,ac,bc=string.sub,string.find,string.reverse,string.rep,table.insert,string.len\
local function cc(cd,dd)local __a={}if cd==\"\"or dd==\"\"then return __a end;local a_a=1\
local b_a,c_a=cb(cd,dd,a_a)while b_a do ac(__a,bb(cd,a_a,b_a-1))a_a=c_a+1\
b_a,c_a=cb(cd,dd,a_a)end;ac(__a,bb(cd,a_a))return __a end;local function dc(cd)return cd:gsub(\"{[^}]+}\",\"\")end\
local function _d(cd,dd)cd=dc(cd)if\
(cd==\"\")or(dd==0)then return{\"\"}end;local __a=cc(cd,\"\\n\")local a_a={}\
for b_a,c_a in\
pairs(__a)do\
if#c_a==0 then table.insert(a_a,\"\")else\
while#c_a>dd do local d_a=dd;for i=dd,1,-1 do if bb(c_a,i,i)==\" \"then\
d_a=i;break end end\
if d_a==dd then\
local _aa=bb(c_a,1,d_a-1)..\"-\"table.insert(a_a,_aa)c_a=bb(c_a,d_a)else\
local _aa=bb(c_a,1,d_a-1)table.insert(a_a,_aa)c_a=bb(c_a,d_a+1)end;if#c_a<=dd then break end end;if#c_a>0 then table.insert(a_a,c_a)end end end;return a_a end\
local function ad(cd)local dd={}local __a=1;local a_a=1\
while __a<=#cd do local b_a,c_a;local d_a,_aa;local aaa,baa\
for _ba,aba in pairs(colors)do\
local bba=\"{fg:\".._ba..\"}\"local cba=\"{bg:\".._ba..\"}\"local dba,_ca=cd:find(bba,__a)\
local aca,bca=cd:find(cba,__a)\
if dba and(not b_a or dba<b_a)then b_a=dba;d_a=_ba;aaa=_ca end\
if aca and(not c_a or aca<c_a)then c_a=aca;_aa=_ba;baa=bca end end;local caa\
if b_a and(not c_a or b_a<c_a)then caa=b_a elseif c_a then caa=c_a else caa=#cd+1 end;local daa=cd:sub(__a,caa-1)\
if#daa>0 then\
table.insert(dd,{color=nil,bgColor=nil,text=daa,position=a_a})a_a=a_a+#daa;__a=__a+#daa end\
if b_a and(not c_a or b_a<c_a)then\
table.insert(dd,{color=d_a,bgColor=nil,text=\"\",position=a_a})__a=aaa+1 elseif c_a then\
table.insert(dd,{color=nil,bgColor=_aa,text=\"\",position=a_a})__a=baa+1 else break end end;return dd end\
local function bd(cd,dd)local __a=ad(cd)local a_a={}local b_a,c_a=1,1;local d_a,_aa;local function aaa(baa)\
table.insert(a_a,{x=b_a,y=c_a,text=baa.text,color=baa.color or d_a,bgColor=\
baa.bgColor or _aa})end\
for baa,caa in ipairs(__a)do\
if\
caa.color then d_a=caa.color elseif caa.bgColor then _aa=caa.bgColor else local daa=cc(caa.text,\" \")\
for _ba,aba in\
ipairs(daa)do local bba=#aba\
if _ba>1 then if b_a+1 +bba<=dd then aaa({text=\" \"})b_a=b_a+1 else b_a=1;c_a=c_a+\
1 end end;while bba>0 do local cba=aba:sub(1,dd-b_a+1)\
aba=aba:sub(dd-b_a+2)bba=#aba;aaa({text=cba})\
if bba>0 then b_a=1;c_a=c_a+1 else b_a=b_a+#cba end end end end;if b_a>dd then b_a=1;c_a=c_a+1 end end;return a_a end\
return\
{getTextHorizontalAlign=function(cd,dd,__a,a_a)cd=bb(cd,1,dd)local b_a=dd-bc(cd)\
if(__a==\"right\")then\
cd=_c(a_a or\" \",b_a)..cd elseif(__a==\"center\")then\
cd=_c(a_a or\" \",math.floor(b_a/2))..cd.._c(a_a or\" \",math.floor(\
b_a/2))\
cd=cd.. (bc(cd)<dd and(a_a or\" \")or\"\")else cd=cd.._c(a_a or\" \",b_a)end;return cd end,getTextVerticalAlign=function(cd,dd)\
local __a=0\
if(dd==\"center\")then __a=math.ceil(cd/2)if(__a<1)then __a=1 end end;if(dd==\"bottom\")then __a=cd end;if(__a<1)then __a=1 end;return __a end,orderedTable=function(cd)\
local dd={}for __a,a_a in pairs(cd)do dd[#dd+1]=a_a end;return dd end,rpairs=function(cd)return\
function(dd,__a)__a=\
__a-1;if __a~=0 then return __a,dd[__a]end end,cd,#cd+1 end,tableCount=function(cd)\
local dd=0;if(cd~=nil)then for __a,a_a in pairs(cd)do dd=dd+1 end end\
return dd end,splitString=cc,removeTags=dc,wrapText=_d,convertRichText=ad,writeRichText=function(cd,dd,__a,a_a)local b_a=ad(a_a)if(#b_a==0)then\
cd:addText(dd,__a,a_a)return end\
local c_a,d_a=cd:getForeground(),cd:getBackground()\
for _aa,aaa in pairs(b_a)do\
cd:addText(dd+aaa.position-1,__a,aaa.text)\
if(aaa.color~=nil)then\
cd:addFG(dd+aaa.position-1,__a,ab[colors[aaa.color]]:rep(\
#aaa.text))c_a=colors[aaa.color]else cd:addFG(dd+aaa.position-1,__a,ab[c_a]:rep(#\
aaa.text))end\
if(aaa.bgColor~=nil)then\
cd:addBG(dd+aaa.position-1,__a,ab[colors[aaa.bgColor]]:rep(\
#aaa.text))d_a=colors[aaa.bgColor]else if(d_a~=false)then\
cd:addBG(dd+aaa.position-1,__a,ab[d_a]:rep(\
#aaa.text))end end end end,wrapRichText=bd,writeWrappedText=function(cd,dd,__a,a_a,b_a,c_a)\
local d_a=bd(a_a,b_a)\
for _aa,aaa in pairs(d_a)do if(aaa.y>c_a)then break end\
if(aaa.text~=nil)then cd:addText(dd+aaa.x-1,__a+\
aaa.y-1,aaa.text)end;if(aaa.color~=nil)then\
cd:addFG(dd+aaa.x-1,__a+aaa.y-1,ab[colors[aaa.color]]:rep(\
#aaa.text))end;if(aaa.bgColor~=nil)then\
cd:addBG(dd+\
aaa.x-1,__a+aaa.y-1,ab[colors[aaa.bgColor]]:rep(#\
aaa.text))end end end,uuid=function()\
return\
string.gsub(string.format('%x-%x-%x-%x-%x',math.random(0,0xffff),math.random(0,0xffff),math.random(0,0xffff),\
math.random(0,0x0fff)+0x4000,math.random(0,0x3fff)+0x8000),' ','0')end}end\
aa[\"libraries\"][\"process\"]=function(...)local ab={}local bb={}local cb=0\
local db=dofile(\"rom/modules/main/cc/require.lua\").make\
function bb:new(_c,ac,bc,...)local cc={...}\
local dc=setmetatable({path=_c},{__index=self})dc.window=ac;ac.current=term.current;ac.redirect=term.redirect\
dc.processId=cb\
if(type(_c)==\"string\")then\
dc.coroutine=coroutine.create(function()\
local _d=shell.resolveProgram(_c)local ad=setmetatable(bc,{__index=_ENV})ad.shell=shell\
ad.basaltProgram=true;ad.arg={[0]=_c,table.unpack(cc)}\
if(_d==nil)then error(\"The path \".._c..\
\" does not exist!\")end;ad.require,ad.package=db(ad,fs.getDir(_d))\
if(fs.exists(_d))then\
local bd=fs.open(_d,\"r\")local cd=bd.readAll()bd.close()local dd=load(cd,_c,\"bt\",ad)if(dd~=nil)then return\
dd()end end end)elseif(type(_c)==\"function\")then\
dc.coroutine=coroutine.create(function()\
_c(table.unpack(cc))end)else return end;ab[cb]=dc;cb=cb+1;return dc end\
function bb:resume(_c,...)local ac=term.current()term.redirect(self.window)\
if(\
self.filter~=nil)then if(_c~=self.filter)then return end;self.filter=nil end;local bc,cc=coroutine.resume(self.coroutine,_c,...)if bc then\
self.filter=cc else printError(cc)end;term.redirect(ac)\
return bc,cc end\
function bb:isDead()\
if(self.coroutine~=nil)then\
if\
(coroutine.status(self.coroutine)==\"dead\")then table.remove(ab,self.processId)return true end else return true end;return false end\
function bb:getStatus()if(self.coroutine~=nil)then\
return coroutine.status(self.coroutine)end;return nil end\
function bb:start()coroutine.resume(self.coroutine)end;return bb end\
aa[\"libraries\"][\"tHex\"]=function(...)local ab={}\
for i=0,15 do ab[2 ^i]=(\"%x\"):format(i)end;return ab end\
aa[\"libraries\"][\"reactivePrimitives\"]=function(...)\
local ab={CURRENT=0,STALE=1,MAYBE_STALE=2}local bb={}\
bb.new=function()\
return\
{fn=nil,value=nil,status=ab.STALE,parents={},children={},cleanup=function(_c)\
for ac,bc in ipairs(_c.parents)do for cc,dc in ipairs(bc.children)do if(dc==_c)then\
table.remove(bc.children,cc)break end end end;_c.parents={}end}end\
local cb={listeningNode=nil,sourceNodes={},effectNodes={},transaction=false}local db={}\
db.pushUpdates=function()for _c,ac in ipairs(cb.sourceNodes)do\
db.pushSourceNodeUpdate(ac)end;db.pullUpdates()end\
db.pushSourceNodeUpdate=function(_c)if(_c.status==ab.CURRENT)then return end\
db.pushNodeUpdate(_c)for ac,bc in ipairs(_c.children)do bc.status=ab.STALE end\
_c.status=ab.CURRENT end\
db.pushNodeUpdate=function(_c)if(_c==nil)then return end;_c.status=ab.MAYBE_STALE;for ac,bc in\
ipairs(_c.children)do db.pushNodeUpdate(bc)end end\
db.pullUpdates=function()\
for _c,ac in ipairs(cb.effectNodes)do db.pullNodeUpdates(ac)end end\
db.pullNodeUpdates=function(_c)if(_c.status==ab.CURRENT)then return end;if\
(_c.status==ab.MAYBE_STALE)then\
for ac,bc in ipairs(_c.parents)do db.pullNodeUpdates(bc)end end\
if(_c.status==ab.STALE)then\
_c:cleanup()local ac=cb.listeningNode;cb.listeningNode=_c;local bc=_c.value;_c.value=_c.fn()\
cb.listeningNode=ac;for cc,dc in ipairs(_c.children)do\
if(bc==_c.value)then dc.status=ab.CURRENT else dc.status=ab.STALE end end end;_c.status=ab.CURRENT end\
db.subscribe=function(_c)local ac=cb.listeningNode\
if(ac~=nil)then\
table.insert(_c.children,ac)table.insert(ac.parents,_c)end end\
db.observable=function(_c)local ac=bb.new()ac.value=_c;ac.status=ab.CURRENT;local bc=function()\
db.subscribe(ac)return ac.value end\
local cc=function(dc)if\
(ac.value==dc)then return end;ac.value=dc;ac.status=cb.STALE;if(not cb.transaction)then\
db.pushUpdates()end end;table.insert(cb.sourceNodes,ac)return bc,cc end\
db.derived=function(_c)local ac=bb.new()ac.fn=_c;return\
function()if(ac.status~=ab.CURRENT)then\
db.pullNodeUpdates(ac)end;db.subscribe(ac)return ac.value end end\
db.effect=function(_c)local ac=bb.new()ac.fn=_c\
table.insert(cb.effectNodes,ac)db.pushUpdates()end\
db.transaction=function(_c)cb.transaction=true;_c()cb.transaction=false\
db.pushUpdates()end\
db.untracked=function(_c)local ac=cb.listeningNode;cb.listeningNode=nil;local bc=_c()\
cb.listeningNode=ac;return bc end;return db end\
aa[\"loadObjects\"]=function(...)local ab={}if(ba)then\
for db,_c in pairs(_b(\"objects\"))do ab[db]=_c()end;return ab end;local bb=table.pack(...)local cb=fs.getDir(\
bb[2]or\"Basalt\")if(cb==nil)then\
error(\"Unable to find directory \"..bb[2]..\
\" please report this bug to our discord.\")end\
for db,_c in\
pairs(fs.list(fs.combine(cb,\"objects\")))do if(_c~=\"example.lua\")and not(_c:find(\".disabled\"))then\
local ac=_c:gsub(\".lua\",\"\")ab[ac]=da(ac)end end;return ab end;aa[\"objects\"]={}\
aa[\"objects\"][\"Graph\"]=function(...)\
return\
function(ab,bb)\
local cb=bb.getObject(\"ChangeableObject\")(ab,bb)local db=\"Graph\"cb:setZIndex(5)cb:setSize(30,10)local _c={}\
local ac=colors.gray;local bc=\"\\7\"local cc=colors.black;local dc=100;local _d=0;local ad=\"line\"local bd=10\
local cd={getType=function(dd)return db end,setGraphColor=function(dd,__a)ac=\
__a or ac;dd:updateDraw()return dd end,setGraphSymbol=function(dd,__a,a_a)\
bc=__a or bc;cc=a_a or cc;dd:updateDraw()return dd end,setGraphSymbolColor=function(dd,__a)return dd:setGraphSymbolColor(\
nil,__a)end,getGraphSymbol=function(dd)\
return bc,cc end,getGraphSymbolColor=function(dd)return cc end,addDataPoint=function(dd,__a)if __a>=_d and __a<=dc then\
table.insert(_c,__a)dd:updateDraw()end;if(#_c>100)then\
table.remove(_c,1)end;return dd end,setMaxValue=function(dd,__a)\
dc=__a;dd:updateDraw()return dd end,getMaxValue=function(dd)return dc end,setMinValue=function(dd,__a)\
_d=__a;dd:updateDraw()return dd end,getMinValue=function(dd)return _d end,setGraphType=function(dd,__a)if __a==\
\"scatter\"or __a==\"line\"or __a==\"bar\"then ad=__a\
dd:updateDraw()end;return dd end,getGraphType=function(dd)return\
ad end,setMaxEntries=function(dd,__a)bd=__a;dd:updateDraw()return dd end,getMaxEntries=function(dd)return\
bd end,clear=function(dd)_c={}dd:updateDraw()return dd end,draw=function(dd)\
cb.draw(dd)\
dd:addDraw(\"graph\",function()local __a,a_a=dd:getPosition()local b_a,c_a=dd:getSize()\
local d_a,_aa=dd:getBackground(),dd:getForeground()local aaa=dc-_d;local baa,caa;local daa=#_c-bd+1;if daa<1 then daa=1 end\
for i=daa,#_c do local _ba=_c[i]\
local aba=math.floor(( (\
b_a-1)/ (bd-1))* (i-daa)+1.5)\
local bba=math.floor((c_a-1)- ( (c_a-1)/aaa)* (_ba-_d)+1.5)\
if ad==\"scatter\"then dd:addBackgroundBox(aba,bba,1,1,ac)\
dd:addForegroundBox(aba,bba,1,1,cc)dd:addTextBox(aba,bba,1,1,bc)elseif ad==\"line\"then\
if baa and caa then\
local cba=math.abs(aba-baa)local dba=math.abs(bba-caa)local _ca=baa<aba and 1 or-1;local aca=caa<\
bba and 1 or-1;local bca=cba-dba\
while true do\
dd:addBackgroundBox(baa,caa,1,1,ac)dd:addForegroundBox(baa,caa,1,1,cc)\
dd:addTextBox(baa,caa,1,1,bc)if baa==aba and caa==bba then break end;local cca=2 *bca;if cca>-dba then\
bca=bca-dba;baa=baa+_ca end\
if cca<cba then bca=bca+cba;caa=caa+aca end end end;baa,caa=aba,bba elseif ad==\"bar\"then\
dd:addBackgroundBox(aba-1,bba,1,c_a-bba,ac)end end end)end}cd.__index=cd;return setmetatable(cd,cb)end end\
aa[\"objects\"][\"Image\"]=function(...)local ab=da(\"images\")local bb=da(\"bimg\")\
local cb,db,_c,ac=table.unpack,string.sub,math.max,math.min\
return\
function(bc,cc)local dc=cc.getObject(\"VisualObject\")(bc,cc)\
local _d=\"Image\"local ad=bb()local bd=ad.getFrameObject(1)local cd;local dd;local __a=1;local a_a=false;local b_a\
local c_a=false;local d_a=true;local _aa,aaa=0,0;dc:setSize(24,8)dc:setZIndex(2)\
local function baa(_ba)local aba={}\
for dba,_ca in\
pairs(colors)do if(type(_ca)==\"number\")then\
aba[dba]={term.nativePaletteColor(_ca)}end end;local bba=ad.getMetadata(\"palette\")if(bba~=nil)then for dba,_ca in pairs(bba)do\
aba[dba]=tonumber(_ca)end end\
local cba=ad.getFrameData(\"palette\")cc.log(cba)if(cba~=nil)then\
for dba,_ca in pairs(cba)do aba[dba]=tonumber(_ca)end end;return aba end;local function caa()\
if(d_a)then if(ad~=nil)then dc:setSize(ad.getSize())end end end\
local daa={getType=function(_ba)return _d end,isType=function(_ba,aba)return\
_d==aba or\
dc.isType~=nil and dc.isType(aba)or false end,setOffset=function(_ba,aba,bba,cba)\
if(cba)then _aa=_aa+\
aba or 0;aaa=aaa+bba or 0 else _aa=aba or _aa;aaa=bba or aaa end;_ba:updateDraw()return _ba end,setXOffset=function(_ba,aba)return _ba:setOffset(_ba,aba,\
nil)end,setYOffset=function(_ba,aba)return\
_ba:setOffset(_ba,nil,aba)end,setSize=function(_ba,aba,bba)dc:setSize(aba,bba)\
d_a=false;return _ba end,getOffset=function(_ba)return _aa,aaa end,getXOffset=function(_ba)return _aa end,getYOffset=function(_ba)return\
aaa end,selectFrame=function(_ba,aba)if(ad.getFrameObject(aba)==nil)then\
ad.addFrame(aba)end;bd=ad.getFrameObject(aba)\
dd=bd.getImage(aba)__a=aba;_ba:updateDraw()end,addFrame=function(_ba,aba)\
ad.addFrame(aba)return _ba end,getFrame=function(_ba,aba)return ad.getFrame(aba)end,getFrameObject=function(_ba,aba)return\
ad.getFrameObject(aba)end,removeFrame=function(_ba,aba)ad.removeFrame(aba)return _ba end,moveFrame=function(_ba,aba,bba)\
ad.moveFrame(aba,bba)return _ba end,getFrames=function(_ba)return ad.getFrames()end,getFrameCount=function(_ba)return\
#ad.getFrames()end,getActiveFrame=function(_ba)return __a end,loadImage=function(_ba,aba)if\
(fs.exists(aba))then local bba=ab.loadBIMG(aba)ad=bb(bba)__a=1\
bd=ad.getFrameObject(1)cd=ad.createBimg()dd=bd.getImage()caa()\
_ba:updateDraw()end;return\
_ba end,setPath=function(_ba,aba)return\
_ba:loadImage(aba)end,setImage=function(_ba,aba)if(type(aba)==\"table\")then ad=bb(aba)__a=1\
bd=ad.getFrameObject(1)cd=ad.createBimg()dd=bd.getImage()caa()\
_ba:updateDraw()end;return _ba end,clear=function(_ba)\
ad=bb()bd=ad.getFrameObject(1)dd=nil;_ba:updateDraw()return _ba end,getImage=function(_ba)return\
ad.createBimg()end,getImageFrame=function(_ba,aba)return bd.getImage(aba)end,usePalette=function(_ba,aba)c_a=\
aba~=nil and aba or true;return _ba end,getUsePalette=function(_ba)return\
c_a end,setUsePalette=function(_ba,aba)return _ba:usePalette(aba)end,play=function(_ba,aba)\
if\
(ad.getMetadata(\"animated\"))then\
local bba=\
ad.getMetadata(\"duration\")or ad.getMetadata(\"secondsPerFrame\")or 0.2;_ba:listenEvent(\"other_event\")\
b_a=os.startTimer(bba)a_a=aba or false end;return _ba end,setPlay=function(_ba,aba)return\
_ba:play(aba)end,stop=function(_ba)os.cancelTimer(b_a)b_a=nil;a_a=false\
return _ba end,eventHandler=function(_ba,aba,bba,...)\
dc.eventHandler(_ba,aba,bba,...)\
if(aba==\"timer\")then\
if(bba==b_a)then\
if(ad.getFrame(__a+1)~=nil)then __a=__a+1\
_ba:selectFrame(__a)\
local cba=\
ad.getFrameData(__a,\"duration\")or ad.getMetadata(\"secondsPerFrame\")or 0.2;b_a=os.startTimer(cba)else\
if(a_a)then __a=1;_ba:selectFrame(__a)\
local cba=\
ad.getFrameData(__a,\"duration\")or ad.getMetadata(\"secondsPerFrame\")or 0.2;b_a=os.startTimer(cba)end end;_ba:updateDraw()end end end,setMetadata=function(_ba,aba,bba)\
ad.setMetadata(aba,bba)return _ba end,getMetadata=function(_ba,aba)return ad.getMetadata(aba)end,getFrameMetadata=function(_ba,aba,bba)return\
ad.getFrameData(aba,bba)end,setFrameMetadata=function(_ba,aba,bba,cba)\
ad.setFrameData(aba,bba,cba)return _ba end,blit=function(_ba,aba,bba,cba,dba,_ca)x=dba or x;y=_ca or y\
bd.blit(aba,bba,cba,x,y)dd=bd.getImage()_ba:updateDraw()return _ba end,setText=function(_ba,aba,bba,cba)x=\
bba or x;y=cba or y;bd.text(aba,x,y)dd=bd.getImage()\
_ba:updateDraw()return _ba end,setBg=function(_ba,aba,bba,cba)x=bba or x;y=\
cba or y;bd.bg(aba,x,y)dd=bd.getImage()\
_ba:updateDraw()return _ba end,setFg=function(_ba,aba,bba,cba)x=bba or x\
y=cba or y;bd.fg(aba,x,y)dd=bd.getImage()_ba:updateDraw()return _ba end,getImageSize=function(_ba)return\
ad.getSize()end,setImageSize=function(_ba,aba,bba)ad.setSize(aba,bba)\
dd=bd.getImage()_ba:updateDraw()return _ba end,resizeImage=function(_ba,aba,bba)\
local cba=ab.resizeBIMG(cd,aba,bba)ad=bb(cba)__a=1;bd=ad.getFrameObject(1)dd=bd.getImage()\
_ba:updateDraw()return _ba end,draw=function(_ba)\
dc.draw(_ba)\
_ba:addDraw(\"image\",function()local aba,bba=_ba:getSize()local cba,dba=_ba:getPosition()\
local _ca,aca=_ba:getParent():getSize()local bca,cca=_ba:getParent():getOffset()\
if\
(cba-bca>_ca)or(dba-cca>aca)or(cba-bca+aba<1)or(dba-\
cca+bba<1)then return end\
if(c_a)then _ba:getParent():setPalette(baa(__a))end\
if(dd~=nil)then\
for dca,_da in pairs(dd)do\
if(dca+aaa<=bba)and(dca+aaa>=1)then\
local ada,bda,cda=_da[1],_da[2],_da[3]local dda=_c(1 -_aa,1)local __b=ac(aba-_aa,#ada)\
ada=db(ada,dda,__b)bda=db(bda,dda,__b)cda=db(cda,dda,__b)\
_ba:addBlit(_c(1 +_aa,1),dca+aaa,ada,bda,cda)end end end end)end}daa.__index=daa;return setmetatable(daa,dc)end end\
aa[\"objects\"][\"List\"]=function(...)local ab=da(\"utils\")local bb=da(\"tHex\")\
return\
function(cb,db)\
local _c=db.getObject(\"ChangeableObject\")(cb,db)local ac=\"List\"local bc={}local cc=colors.black;local dc=colors.lightGray;local _d=true\
local ad=\"left\"local bd=0;local cd=true;_c:setSize(16,8)_c:setZIndex(5)\
local dd={init=function(__a)\
local a_a=__a:getParent()__a:listenEvent(\"mouse_click\")\
__a:listenEvent(\"mouse_drag\")__a:listenEvent(\"mouse_scroll\")return _c.init(__a)end,getBase=function(__a)return\
_c end,setTextAlign=function(__a,a_a)ad=a_a;return __a end,getTextAlign=function(__a)return ad end,getBase=function(__a)return _c end,getType=function(__a)return\
ac end,isType=function(__a,a_a)return\
ac==a_a or _c.isType~=nil and _c.isType(a_a)or false end,addItem=function(__a,a_a,b_a,c_a,...)\
table.insert(bc,{text=a_a,bgCol=\
b_a or __a:getBackground(),fgCol=c_a or __a:getForeground(),args={...}})if(#bc<=1)then __a:setValue(bc[1],false)end\
__a:updateDraw()return __a end,setOptions=function(__a,...)\
bc={}\
for a_a,b_a in pairs(...)do\
if(type(b_a)==\"string\")then\
table.insert(bc,{text=b_a,bgCol=__a:getBackground(),fgCol=__a:getForeground(),args={}})else\
table.insert(bc,{text=b_a[1],bgCol=b_a[2]or __a:getBackground(),fgCol=b_a[3]or\
__a:getForeground(),args=b_a[4]or{}})end end;__a:setValue(bc[1],false)__a:updateDraw()return __a end,setOffset=function(__a,a_a)\
bd=a_a;__a:updateDraw()return __a end,getOffset=function(__a)return bd end,removeItem=function(__a,a_a)\
if(\
type(a_a)==\"number\")then table.remove(bc,a_a)elseif(type(a_a)==\"table\")then\
for b_a,c_a in\
pairs(bc)do if(c_a==a_a)then table.remove(bc,b_a)break end end end;__a:updateDraw()return __a end,getItem=function(__a,a_a)return\
bc[a_a]end,getAll=function(__a)return bc end,getOptions=function(__a)return bc end,getItemIndex=function(__a)\
local a_a=__a:getValue()for b_a,c_a in pairs(bc)do if(c_a==a_a)then return b_a end end end,clear=function(__a)\
bc={}__a:setValue({},false)__a:updateDraw()return __a end,getItemCount=function(__a)return\
#bc end,editItem=function(__a,a_a,b_a,c_a,d_a,...)table.remove(bc,a_a)\
table.insert(bc,a_a,{text=b_a,bgCol=c_a or\
__a:getBackground(),fgCol=d_a or __a:getForeground(),args={...}})__a:updateDraw()return __a end,selectItem=function(__a,a_a)__a:setValue(\
bc[a_a]or{},false)__a:updateDraw()return __a end,setSelectionColor=function(__a,a_a,b_a,c_a)cc=\
a_a or __a:getBackground()\
dc=b_a or __a:getForeground()_d=c_a~=nil and c_a or true;__a:updateDraw()\
return __a end,setSelectionBG=function(__a,a_a)return __a:setSelectionColor(a_a,\
nil,_d)end,setSelectionFG=function(__a,a_a)return __a:setSelectionColor(\
nil,a_a,_d)end,getSelectionColor=function(__a)\
return cc,dc end,getSelectionBG=function(__a)return cc end,getSelectionFG=function(__a)return dc end,isSelectionColorActive=function(__a)return _d end,setScrollable=function(__a,a_a)\
cd=a_a;if(a_a==nil)then cd=true end;__a:updateDraw()return __a end,getScrollable=function(__a)return\
cd end,scrollHandler=function(__a,a_a,b_a,c_a)\
if(_c.scrollHandler(__a,a_a,b_a,c_a))then\
if(cd)then\
local d_a,_aa=__a:getSize()bd=bd+a_a;if(bd<0)then bd=0 end;if(a_a>=1)then\
if(#bc>_aa)then\
if(bd>#bc-_aa)then bd=#bc-_aa end;if(bd>=#bc)then bd=#bc-1 end else bd=bd-1 end end\
__a:updateDraw()end;return true end;return false end,mouseHandler=function(__a,a_a,b_a,c_a)\
if\
(_c.mouseHandler(__a,a_a,b_a,c_a))then local d_a,_aa=__a:getAbsolutePosition()local aaa,baa=__a:getSize()\
if\
(#bc>0)then\
for n=1,baa do\
if(bc[n+bd]~=nil)then if\
(d_a<=b_a)and(d_a+aaa>b_a)and(_aa+n-1 ==c_a)then __a:setValue(bc[n+bd])__a:selectHandler()\
__a:updateDraw()end end end end;return true end;return false end,dragHandler=function(__a,a_a,b_a,c_a)return\
__a:mouseHandler(a_a,b_a,c_a)end,touchHandler=function(__a,a_a,b_a)return\
__a:mouseHandler(1,a_a,b_a)end,onSelect=function(__a,...)\
for a_a,b_a in\
pairs(table.pack(...))do if(type(b_a)==\"function\")then\
__a:registerEvent(\"select_item\",b_a)end end;return __a end,selectHandler=function(__a)\
__a:sendEvent(\"select_item\",__a:getValue())end,draw=function(__a)_c.draw(__a)\
__a:addDraw(\"list\",function()\
local a_a,b_a=__a:getSize()\
for n=1,b_a do\
if bc[n+bd]then local c_a=bc[n+bd].text\
local d_a,_aa=bc[n+bd].fgCol,bc[n+bd].bgCol\
if bc[n+bd]==__a:getValue()and _d then d_a,_aa=dc,cc end;__a:addText(1,n,c_a:sub(1,a_a))\
__a:addBG(1,n,bb[_aa]:rep(a_a))__a:addFG(1,n,bb[d_a]:rep(a_a))end end end)end}dd.__index=dd;return setmetatable(dd,_c)end end\
aa[\"objects\"][\"ChangeableObject\"]=function(...)\
return\
function(ab,bb)\
local cb=bb.getObject(\"VisualObject\")(ab,bb)local db=\"ChangeableObject\"local _c\
local ac={setValue=function(bc,cc,dc)if(_c~=cc)then _c=cc;bc:updateDraw()if(dc~=false)then\
bc:valueChangedHandler()end end;return bc end,getValue=function(bc)return\
_c end,onChange=function(bc,...)\
for cc,dc in pairs(table.pack(...))do if(type(dc)==\"function\")then\
bc:registerEvent(\"value_changed\",dc)end end;return bc end,valueChangedHandler=function(bc)\
bc:sendEvent(\"value_changed\",_c)end}ac.__index=ac;return setmetatable(ac,cb)end end\
aa[\"objects\"][\"Frame\"]=function(...)local ab=da(\"utils\")\
local bb,cb,db,_c,ac=math.max,math.min,string.sub,string.rep,string.len\
return\
function(bc,cc)local dc=cc.getObject(\"Container\")(bc,cc)local _d=\"Frame\"\
local ad;local bd=true;local cd,dd=0,0;dc:setSize(30,10)dc:setZIndex(10)\
local __a={getType=function()return _d end,isType=function(a_a,b_a)return\
\
_d==b_a or dc.isType~=nil and dc.isType(b_a)or false end,getBase=function(a_a)\
return dc end,getOffset=function(a_a)return cd,dd end,setOffset=function(a_a,b_a,c_a)cd=b_a or cd;dd=c_a or dd\
a_a:updateDraw()return a_a end,getXOffset=function(a_a)return cd end,setXOffset=function(a_a,b_a)return\
a_a:setOffset(b_a,nil)end,getYOffset=function(a_a)return dd end,setYOffset=function(a_a,b_a)return\
a_a:setOffset(nil,b_a)end,setParent=function(a_a,b_a,...)\
dc.setParent(a_a,b_a,...)ad=b_a;return a_a end,render=function(a_a)\
if(dc.render~=nil)then\
if\
(a_a:isVisible())then dc.render(a_a)local b_a=a_a:getChildren()for c_a,d_a in ipairs(b_a)do\
if(\
d_a.element.render~=nil)then d_a.element:render()end end end end end,updateDraw=function(a_a)if(\
ad~=nil)then ad:updateDraw()end;return a_a end,blit=function(a_a,b_a,c_a,d_a,_aa,aaa)\
local baa,caa=a_a:getPosition()local daa,_ba=ad:getOffset()baa=baa-daa;caa=caa-_ba\
local aba,bba=a_a:getSize()\
if c_a>=1 and c_a<=bba then\
local cba=db(d_a,bb(1 -b_a+1,1),bb(aba-b_a+1,1))\
local dba=db(_aa,bb(1 -b_a+1,1),bb(aba-b_a+1,1))\
local _ca=db(aaa,bb(1 -b_a+1,1),bb(aba-b_a+1,1))\
ad:blit(bb(b_a+ (baa-1),baa),caa+c_a-1,cba,dba,_ca)end end,setCursor=function(a_a,b_a,c_a,d_a,_aa)\
local aaa,baa=a_a:getPosition()local caa,daa=a_a:getOffset()\
ad:setCursor(b_a or false,(c_a or 0)+aaa-1 -caa,(\
d_a or 0)+baa-1 -daa,_aa or colors.white)return a_a end}\
for a_a,b_a in\
pairs({\"drawBackgroundBox\",\"drawForegroundBox\",\"drawTextBox\"})do\
__a[b_a]=function(c_a,d_a,_aa,aaa,baa,caa)local daa,_ba=c_a:getPosition()local aba,bba=ad:getOffset()\
daa=daa-aba;_ba=_ba-bba\
baa=(_aa<1 and(\
baa+_aa>c_a:getHeight()and c_a:getHeight()or baa+_aa-1)or(\
baa+\
_aa>c_a:getHeight()and c_a:getHeight()-_aa+1 or baa))\
aaa=(d_a<1 and(aaa+d_a>c_a:getWidth()and c_a:getWidth()or aaa+\
d_a-1)or(\
\
aaa+d_a>c_a:getWidth()and c_a:getWidth()-d_a+1 or aaa))\
ad[b_a](ad,bb(d_a+ (daa-1),daa),bb(_aa+ (_ba-1),_ba),aaa,baa,caa)end end\
for a_a,b_a in pairs({\"setBG\",\"setFG\",\"setText\"})do\
__a[b_a]=function(c_a,d_a,_aa,aaa)\
local baa,caa=c_a:getPosition()local daa,_ba=ad:getOffset()baa=baa-daa;caa=caa-_ba\
local aba,bba=c_a:getSize()if(_aa>=1)and(_aa<=bba)then\
ad[b_a](ad,bb(d_a+ (baa-1),baa),caa+_aa-1,db(aaa,bb(\
1 -d_a+1,1),bb(aba-d_a+1,1)))end end end;__a.__index=__a;return setmetatable(__a,dc)end end\
aa[\"objects\"][\"BaseFrame\"]=function(...)local ab=da(\"basaltDraw\")\
local bb=da(\"utils\")local cb,db,_c,ac=math.max,math.min,string.sub,string.rep\
return\
function(bc,cc)\
local dc=cc.getObject(\"Container\")(bc,cc)local _d=\"BaseFrame\"local ad,bd=0,0;local cd={}local dd=true;local __a=cc.getTerm()\
local a_a=ab(__a)local b_a,c_a,d_a,_aa=1,1,false,colors.white\
local aaa={getType=function()return _d end,isType=function(baa,caa)\
return _d==caa or dc.isType~=nil and\
dc.isType(caa)or false end,getBase=function(baa)return dc end,getOffset=function(baa)return ad,bd end,setOffset=function(baa,caa,daa)ad=\
caa or ad;bd=daa or bd;baa:updateDraw()return baa end,getXOffset=function(baa)return\
ad end,setXOffset=function(baa,caa)return baa:setOffset(caa,nil)end,getYOffset=function(baa)return\
bd end,setYOffset=function(baa,caa)return baa:setOffset(nil,caa)end,setPalette=function(baa,caa,...)\
if(\
baa==cc.getActiveFrame())then\
if(type(caa)==\"string\")then cd[caa]=...\
__a.setPaletteColor(\
type(caa)==\"number\"and caa or colors[caa],...)elseif(type(caa)==\"table\")then\
for daa,_ba in pairs(caa)do cd[daa]=_ba\
if(type(_ba)==\"number\")then\
__a.setPaletteColor(\
type(daa)==\"number\"and daa or colors[daa],_ba)else local aba,bba,cba=table.unpack(_ba)\
__a.setPaletteColor(\
type(daa)==\"number\"and daa or colors[daa],aba,bba,cba)end end end end;return baa end,setSize=function(baa,...)\
dc.setSize(baa,...)a_a=ab(__a)return baa end,getSize=function()return __a.getSize()end,getWidth=function(baa)return\
({__a.getSize()})[1]end,getHeight=function(baa)\
return({__a.getSize()})[2]end,show=function(baa)dc.show(baa)cc.setActiveFrame(baa)\
for caa,daa in\
pairs(colors)do if(type(daa)==\"number\")then\
__a.setPaletteColor(daa,colors.packRGB(term.nativePaletteColor((daa))))end end\
for caa,daa in pairs(cd)do\
if(type(daa)==\"number\")then\
__a.setPaletteColor(\
type(caa)==\"number\"and caa or colors[caa],daa)else local _ba,aba,bba=table.unpack(daa)\
__a.setPaletteColor(\
type(caa)==\"number\"and caa or colors[caa],_ba,aba,bba)end end;cc.setMainFrame(baa)return baa end,render=function(baa)\
if(\
dc.render~=nil)then\
if(baa:isVisible())then\
if(dd)then dc.render(baa)\
local caa=baa:getChildren()for daa,_ba in ipairs(caa)do if(_ba.element.render~=nil)then\
_ba.element:render()end end\
dd=false end end end end,updateDraw=function(baa)\
dd=true;return baa end,eventHandler=function(baa,caa,...)dc.eventHandler(baa,caa,...)if\
(caa==\"term_resize\")then baa:setSize(__a.getSize())end end,updateTerm=function(baa)if(\
a_a~=nil)then a_a.update()end end,setTerm=function(baa,caa)__a=caa;if(caa==\
nil)then a_a=nil else a_a=ab(__a)end;return baa end,getTerm=function()return\
__a end,blit=function(baa,caa,daa,_ba,aba,bba)local cba,dba=baa:getPosition()\
local _ca,aca=baa:getSize()\
if daa>=1 and daa<=aca then\
local bca=_c(_ba,cb(1 -caa+1,1),cb(_ca-caa+1,1))\
local cca=_c(aba,cb(1 -caa+1,1),cb(_ca-caa+1,1))\
local dca=_c(bba,cb(1 -caa+1,1),cb(_ca-caa+1,1))\
a_a.blit(cb(caa+ (cba-1),cba),dba+daa-1,bca,cca,dca)end end,setCursor=function(baa,caa,daa,_ba,aba)\
local bba,cba=baa:getAbsolutePosition()local dba,_ca=baa:getOffset()d_a=caa or false;if(daa~=nil)then\
b_a=bba+daa-1 -dba end\
if(_ba~=nil)then c_a=cba+_ba-1 -_ca end;_aa=aba or _aa\
if(d_a)then __a.setTextColor(_aa)\
__a.setCursorPos(b_a,c_a)__a.setCursorBlink(d_a)else __a.setCursorBlink(false)end;return baa end}\
for baa,caa in\
pairs({mouse_click={\"mouseHandler\",true},mouse_up={\"mouseUpHandler\",false},mouse_drag={\"dragHandler\",false},mouse_scroll={\"scrollHandler\",true},mouse_hover={\"hoverHandler\",false}})do\
aaa[caa[1]]=function(daa,_ba,aba,bba,...)if(dc[caa[1]](daa,_ba,aba,bba,...))then\
cc.setActiveFrame(daa)end end end\
for baa,caa in\
pairs({\"drawBackgroundBox\",\"drawForegroundBox\",\"drawTextBox\"})do\
aaa[caa]=function(daa,_ba,aba,bba,cba,dba)local _ca,aca=daa:getPosition()local bca,cca=daa:getSize()\
cba=(aba<1 and(cba+\
aba>daa:getHeight()and daa:getHeight()or cba+aba-\
1)or(cba+aba>\
daa:getHeight()and daa:getHeight()-aba+1 or\
cba))\
bba=(_ba<1 and(bba+_ba>daa:getWidth()and daa:getWidth()or bba+\
_ba-1)or(\
\
bba+_ba>daa:getWidth()and daa:getWidth()-_ba+1 or bba))\
a_a[caa](cb(_ba+ (_ca-1),_ca),cb(aba+ (aca-1),aca),bba,cba,dba)end end\
for baa,caa in pairs({\"setBG\",\"setFG\",\"setText\"})do\
aaa[caa]=function(daa,_ba,aba,bba)\
local cba,dba=daa:getPosition()local _ca,aca=daa:getSize()if(aba>=1)and(aba<=aca)then\
a_a[caa](cb(_ba+ (cba-1),cba),\
dba+aba-1,_c(bba,cb(1 -_ba+1,1),cb(_ca-_ba+1,1)))end end end;aaa.__index=aaa;return setmetatable(aaa,dc)end end\
aa[\"objects\"][\"Container\"]=function(...)local ab=da(\"utils\")local bb=ab.tableCount\
return\
function(cb,db)\
local _c=db.getObject(\"VisualObject\")(cb,db)local ac=\"Container\"local bc={}local cc={}local dc={}local _d;local ad=true;local bd,cd=0,0\
local dd=function(cba,dba)\
if\
cba.zIndex==dba.zIndex then return cba.objId<dba.objId else return cba.zIndex<dba.zIndex end end\
local __a=function(cba,dba)if cba.zIndex==dba.zIndex then return cba.evId>dba.evId else return\
cba.zIndex>dba.zIndex end end;local function a_a(cba)cba:sortChildren()return bc end\
local function b_a(cba,dba)if\
(type(dba)==\"table\")then dba=dba:getName()end\
for _ca,aca in ipairs(bc)do if\
aca.element:getName()==dba then return aca.element end end end\
local function c_a(cba,dba)local _ca=b_a(dba)if(_ca~=nil)then return _ca end;for aca,bca in ipairs(bc)do\
if\
(bca:getType()==\"Container\")then local cca=bca:getDeepChild(dba)if(cca~=nil)then return cca end end end end\
local function d_a(cba,dba)if(b_a(dba:getName())~=nil)then return end;bd=bd+1\
local _ca=dba:getZIndex()\
table.insert(bc,{element=dba,zIndex=_ca,objId=bd})ad=false;dba:setParent(cba,true)for aca,bca in\
pairs(dba:getRegisteredEvents())do cba:addEvent(aca,dba)end;if(dba.init~=\
nil)then dba:init()end\
if(dba.load~=nil)then dba:load()end;if(dba.draw~=nil)then dba:draw()end;return dba end\
local function _aa(cba,dba)\
if(type(dba)==\"string\")then dba=b_a(dba:getName())end;if(dba==nil)then return end\
for _ca,aca in ipairs(bc)do if aca.element==dba then\
table.remove(bc,_ca)return true end end;cba:removeEvents(dba)ad=false end;local function aaa(cba)local dba=cba:getParent()bc={}cc={}ad=false;bd=0;cd=0;_d=nil\
dba:removeEvents(cba)end\
local function baa(cba,dba,_ca)bd=bd+1;cd=cd+1;for aca,bca in\
pairs(bc)do\
if(bca.element==dba)then bca.zIndex=_ca;bca.objId=bd;break end end;for aca,bca in pairs(cc)do\
for cca,dca in pairs(bca)do if\
(dca.element==dba)then dca.zIndex=_ca;dca.evId=cd end end end;ad=false\
cba:updateDraw()end\
local function caa(cba,dba)local _ca=cba:getParent()\
for aca,bca in pairs(cc)do for cca,dca in pairs(bca)do if(dca.element==dba)then\
table.remove(cc[aca],cca)end end\
if(\
bb(cc[aca])<=0)then if(_ca~=nil)then _ca:removeEvent(aca,cba)end end end;ad=false end\
local function daa(cba,dba,_ca)if(type(_ca)==\"table\")then _ca=_ca:getName()end\
if(cc[dba]~=\
nil)then for aca,bca in pairs(cc[dba])do\
if(bca.element:getName()==_ca)then return bca end end end end\
local function _ba(cba,dba,_ca)\
if(daa(cba,dba,_ca:getName())~=nil)then return end;local aca=_ca:getZIndex()cd=cd+1\
if(cc[dba]==nil)then cc[dba]={}end\
table.insert(cc[dba],{element=_ca,zIndex=aca,evId=cd})ad=false;cba:listenEvent(dba)return _ca end\
local function aba(cba,dba,_ca)\
if(cc[dba]~=nil)then for aca,bca in pairs(cc[dba])do if(bca.element==_ca)then\
table.remove(cc[dba],aca)end end;if(\
bb(cc[dba])<=0)then cba:listenEvent(dba,false)end end;ad=false end\
local function bba(cba,dba)return dba~=nil and cc[dba]or cc end\
dc={getType=function()return ac end,getBase=function(cba)return _c end,isType=function(cba,dba)\
return ac==dba or\
_c.isType~=nil and _c.isType(dba)or false end,setSize=function(cba,...)_c.setSize(cba,...)\
cba:customEventHandler(\"basalt_FrameResize\")return cba end,setPosition=function(cba,...)\
_c.setPosition(cba,...)cba:customEventHandler(\"basalt_FrameReposition\")\
return cba end,searchChildren=function(cba,dba)local _ca={}\
for aca,bca in pairs(bc)do if\
(string.find(bca.element:getName(),dba))then table.insert(_ca,bca)end end;return _ca end,getChildrenByType=function(cba,dba)\
local _ca={}for aca,bca in pairs(bc)do\
if(bca.element:isType(dba))then table.insert(_ca,bca)end end;return _ca end,setImportant=function(cba,dba)bd=\
bd+1;cd=cd+1\
for _ca,aca in pairs(cc)do for bca,cca in pairs(aca)do\
if(cca.element==dba)then cca.evId=cd\
table.remove(cc[_ca],bca)table.insert(cc[_ca],cca)break end end end\
for _ca,aca in ipairs(bc)do if aca.element==dba then aca.objId=bd;table.remove(bc,_ca)\
table.insert(bc,aca)break end end;if(cba.updateDraw~=nil)then cba:updateDraw()end\
ad=false end,sortChildren=function(cba)if\
(ad)then return end;table.sort(bc,dd)for dba,_ca in pairs(cc)do\
table.sort(cc[dba],__a)end;ad=true end,clearFocusedChild=function(cba)if(\
_d~=nil)then\
if(b_a(cba,_d)~=nil)then _d:loseFocusHandler()end end;_d=nil;return cba end,setFocusedChild=function(cba,dba)\
if(\
_d~=dba)then if(_d~=nil)then\
if(b_a(cba,_d)~=nil)then _d:loseFocusHandler()end end;if(dba~=nil)then if(b_a(cba,dba)~=nil)then\
dba:getFocusHandler()end end;_d=dba;return true end;return false end,getFocused=function(cba)return\
_d end,getChild=b_a,getChildren=a_a,getDeepChildren=c_a,addChild=d_a,removeChild=_aa,removeChildren=aaa,getEvents=bba,getEvent=daa,addEvent=_ba,removeEvent=aba,removeEvents=caa,updateZIndex=baa,listenEvent=function(cba,dba,_ca)_c.listenEvent(cba,dba,_ca)if(\
cc[dba]==nil)then cc[dba]={}end;return cba end,customEventHandler=function(cba,...)\
_c.customEventHandler(cba,...)\
for dba,_ca in pairs(bc)do if(_ca.element.customEventHandler~=nil)then\
_ca.element:customEventHandler(...)end end end,loseFocusHandler=function(cba)\
_c.loseFocusHandler(cba)if(_d~=nil)then _d:loseFocusHandler()_d=nil end end,getBasalt=function(cba)return\
db end,setPalette=function(cba,dba,...)local _ca=cba:getParent()\
_ca:setPalette(dba,...)return cba end,eventHandler=function(cba,...)\
if(_c.eventHandler~=nil)then\
_c.eventHandler(cba,...)\
if(cc[\"other_event\"]~=nil)then cba:sortChildren()\
for dba,_ca in\
ipairs(cc[\"other_event\"])do if(_ca.element.eventHandler~=nil)then\
_ca.element.eventHandler(_ca.element,...)end end end end end}\
for cba,dba in\
pairs({mouse_click={\"mouseHandler\",true},mouse_up={\"mouseUpHandler\",false},mouse_drag={\"dragHandler\",false},mouse_scroll={\"scrollHandler\",true},mouse_hover={\"hoverHandler\",false}})do\
dc[dba[1]]=function(_ca,aca,bca,cca,...)\
if(_c[dba[1]]~=nil)then\
if(_c[dba[1]](_ca,aca,bca,cca,...))then\
if\
(cc[cba]~=nil)then _ca:sortChildren()\
for dca,_da in ipairs(cc[cba])do\
if\
(_da.element[dba[1]]~=nil)then local ada,bda=0,0\
if(_ca.getOffset~=nil)then ada,bda=_ca:getOffset()end\
if(_da.element.getIgnoreOffset~=nil)then if(_da.element.getIgnoreOffset())then\
ada,bda=0,0 end end;if(_da.element[dba[1]](_da.element,aca,bca+ada,cca+bda,...))then return\
true end end end;if(dba[2])then _ca:clearFocusedChild()end end;return true end end end end\
for cba,dba in\
pairs({key=\"keyHandler\",key_up=\"keyUpHandler\",char=\"charHandler\"})do\
dc[dba]=function(_ca,...)\
if(_c[dba]~=nil)then\
if(_c[dba](_ca,...))then\
if(cc[cba]~=nil)then\
_ca:sortChildren()for aca,bca in ipairs(cc[cba])do\
if(bca.element[dba]~=nil)then if\
(bca.element[dba](bca.element,...))then return true end end end end end end end end;for cba,dba in pairs(db.getObjects())do\
dc[\"add\"..cba]=function(_ca,aca)return\
_ca:addChild(db:createObject(cba,aca))end end\
dc.__index=dc;return setmetatable(dc,_c)end end\
aa[\"objects\"][\"Checkbox\"]=function(...)local ab=da(\"utils\")local bb=da(\"tHex\")\
return\
function(cb,db)\
local _c=db.getObject(\"ChangeableObject\")(cb,db)local ac=\"Checkbox\"_c:setZIndex(5)_c:setValue(false)\
_c:setSize(1,1)local bc,cc,dc,_d=\"\\42\",\" \",\"\",\"right\"\
local ad={load=function(bd)bd:listenEvent(\"mouse_click\",bd)\
bd:listenEvent(\"mouse_up\",bd)end,getType=function(bd)return ac end,isType=function(bd,cd)return\
ac==cd or\
_c.isType~=nil and _c.isType(cd)or false end,setSymbol=function(bd,cd,dd)\
bc=cd or bc;cc=dd or cc;bd:updateDraw()return bd end,setActiveSymbol=function(bd,cd)return bd:setSymbol(cd,\
nil)end,setInactiveSymbol=function(bd,cd)\
return bd:setSymbol(nil,cd)end,getSymbol=function(bd)return bc,cc end,getActiveSymbol=function(bd)return bc end,getInactiveSymbol=function(bd)return cc end,setText=function(bd,cd)\
dc=cd;return bd end,getText=function(bd)return dc end,setTextPosition=function(bd,cd)_d=cd or _d;return bd end,getTextPosition=function(bd)return\
_d end,setChecked=_c.setValue,getChecked=_c.getValue,mouseHandler=function(bd,cd,dd,__a)\
if(_c.mouseHandler(bd,cd,dd,__a))then\
if(cd==1)then\
if(\
bd:getValue()~=true)and(bd:getValue()~=false)then\
bd:setValue(false)else bd:setValue(not bd:getValue())end;bd:updateDraw()return true end end;return false end,draw=function(bd)\
_c.draw(bd)\
bd:addDraw(\"checkbox\",function()local cd,dd=bd:getPosition()local __a,a_a=bd:getSize()\
local b_a=ab.getTextVerticalAlign(a_a,\"center\")local c_a,d_a=bd:getBackground(),bd:getForeground()\
if\
(bd:getValue())then\
bd:addBlit(1,b_a,ab.getTextHorizontalAlign(bc,__a,\"center\"),bb[d_a],bb[c_a])else\
bd:addBlit(1,b_a,ab.getTextHorizontalAlign(cc,__a,\"center\"),bb[d_a],bb[c_a])end;if(dc~=\"\")then local _aa=_d==\"left\"and-dc:len()or 3\
bd:addText(_aa,b_a,dc)end end)end}ad.__index=ad;return setmetatable(ad,_c)end end\
aa[\"objects\"][\"Button\"]=function(...)local ab=da(\"utils\")local bb=da(\"tHex\")\
return\
function(cb,db)\
local _c=db.getObject(\"VisualObject\")(cb,db)local ac=\"Button\"local bc=\"center\"local cc=\"center\"local dc=\"Button\"_c:setSize(12,3)\
_c:setZIndex(5)\
local _d={getType=function(ad)return ac end,isType=function(ad,bd)return\
ac==bd or _c.isType~=nil and _c.isType(bd)or false end,getBase=function(ad)return\
_c end,getHorizontalAlign=function(ad)return bc end,setHorizontalAlign=function(ad,bd)bc=bd;ad:updateDraw()return ad end,getVerticalAlign=function(ad)return\
cc end,setVerticalAlign=function(ad,bd)cc=bd;ad:updateDraw()return ad end,getText=function(ad)\
return dc end,setText=function(ad,bd)dc=bd;ad:updateDraw()return ad end,draw=function(ad)\
_c.draw(ad)\
ad:addDraw(\"button\",function()local bd,cd=ad:getSize()\
local dd=ab.getTextVerticalAlign(cd,cc)local __a\
if(bc==\"center\")then\
__a=math.floor((bd-dc:len())/2)elseif(bc==\"right\")then __a=bd-dc:len()end;ad:addText(__a+1,dd,dc)\
ad:addFG(__a+1,dd,bb[ad:getForeground()or colors.white]:rep(dc:len()))end)end}_d.__index=_d;return setmetatable(_d,_c)end end\
aa[\"objects\"][\"Dropdown\"]=function(...)local ab=da(\"utils\")local bb=da(\"tHex\")\
return\
function(cb,db)\
local _c=db.getObject(\"List\")(cb,db)local ac=\"Dropdown\"_c:setSize(12,1)_c:setZIndex(6)local bc=true\
local cc=\"left\"local dc=0;local _d=0;local ad=0;local bd=true;local cd=\"\\16\"local dd=\"\\31\"local __a=false\
local a_a={getType=function(b_a)return ac end,isType=function(b_a,c_a)return\
\
ac==c_a or _c.isType~=nil and _c.isType(c_a)or false end,load=function(b_a)\
b_a:listenEvent(\"mouse_click\",b_a)b_a:listenEvent(\"mouse_up\",b_a)\
b_a:listenEvent(\"mouse_scroll\",b_a)b_a:listenEvent(\"mouse_drag\",b_a)end,setOffset=function(b_a,c_a)\
dc=c_a;b_a:updateDraw()return b_a end,getOffset=function(b_a)return dc end,addItem=function(b_a,c_a,...)\
_c.addItem(b_a,c_a,...)if(bd)then _d=math.max(_d,#c_a)ad=ad+1 end;return b_a end,removeItem=function(b_a,c_a)\
_c.removeItem(b_a,c_a)if(bd)then _d=0;ad=0\
for n=1,#list do _d=math.max(_d,#list[n].text)end;ad=#list end end,isOpened=function(b_a)return\
__a end,setOpened=function(b_a,c_a)__a=c_a;b_a:updateDraw()return b_a end,setDropdownSize=function(b_a,c_a,d_a)\
_d,ad=c_a,d_a;bd=false;b_a:updateDraw()return b_a end,setDropdownWidth=function(b_a,c_a)return\
b_a:setDropdownSize(c_a,ad)end,setDropdownHeight=function(b_a,c_a)\
return b_a:setDropdownSize(_d,c_a)end,getDropdownSize=function(b_a)return _d,ad end,getDropdownWidth=function(b_a)return _d end,getDropdownHeight=function(b_a)return ad end,mouseHandler=function(b_a,c_a,d_a,_aa,aaa)\
if\
(__a)then local caa,daa=b_a:getAbsolutePosition()\
if(c_a==1)then local _ba=b_a:getAll()\
if(#\
_ba>0)then\
for n=1,ad do\
if(_ba[n+dc]~=nil)then\
if\
(caa<=d_a)and(caa+_d>d_a)and(daa+n==_aa)then b_a:setValue(_ba[n+dc])b_a:updateDraw()\
local aba=b_a:sendEvent(\"mouse_click\",b_a,\"mouse_click\",c_a,d_a,_aa)if(aba==false)then return aba end;if(aaa)then\
db.schedule(function()sleep(0.1)\
b_a:mouseUpHandler(c_a,d_a,_aa)end)()end;return true end end end end end end;local baa=_c:getBase()\
if(baa.mouseHandler(b_a,c_a,d_a,_aa))then __a=not __a\
b_a:getParent():setImportant(b_a)b_a:updateDraw()return true else\
if(__a)then b_a:updateDraw()__a=false end;return false end end,mouseUpHandler=function(b_a,c_a,d_a,_aa)\
if\
(__a)then local aaa,baa=b_a:getAbsolutePosition()\
if(c_a==1)then local caa=b_a:getAll()\
if(#\
caa>0)then\
for n=1,ad do\
if(caa[n+dc]~=nil)then\
if\
(aaa<=d_a)and(aaa+_d>d_a)and(baa+n==_aa)then __a=false;b_a:updateDraw()\
local daa=b_a:sendEvent(\"mouse_up\",b_a,\"mouse_up\",c_a,d_a,_aa)if(daa==false)then return daa end;return true end end end end end end end,dragHandler=function(b_a,c_a,d_a,_aa)if\
(_c.dragHandler(b_a,c_a,d_a,_aa))then __a=true end end,scrollHandler=function(b_a,c_a,d_a,_aa)\
if\
(__a)then local aaa,baa=b_a:getAbsolutePosition()if\
(d_a>=aaa)and(d_a<=aaa+_d)and(_aa>=baa)and(_aa<=baa+ad)then\
b_a:setFocus()end end\
if(__a)and(b_a:isFocused())then\
local aaa,baa=b_a:getAbsolutePosition()if\
(d_a<aaa)or(d_a>aaa+_d)or(_aa<baa)or(_aa>baa+ad)then return false end;if(#b_a:getAll()<=ad)then return\
false end;local caa=b_a:getAll()dc=dc+c_a\
if(dc<0)then dc=0 end\
if(c_a==1)then if(#caa>ad)then if(dc>#caa-ad)then dc=#caa-ad end else\
dc=math.min(#caa-1,0)end end\
local daa=b_a:sendEvent(\"mouse_scroll\",b_a,\"mouse_scroll\",c_a,d_a,_aa)if(daa==false)then return daa end;b_a:updateDraw()return true end end,draw=function(b_a)\
_c.draw(b_a)b_a:setDrawState(\"list\",false)\
b_a:addDraw(\"dropdown\",function()\
local c_a,d_a=b_a:getPosition()local _aa,aaa=b_a:getSize()local baa=b_a:getValue()\
local caa=b_a:getAll()local daa,_ba=b_a:getBackground(),b_a:getForeground()\
local aba=ab.getTextHorizontalAlign((\
baa~=nil and baa.text or\"\"),_aa,cc):sub(1,\
_aa-1).. (__a and dd or cd)\
b_a:addBlit(1,1,aba,bb[_ba]:rep(#aba),bb[daa]:rep(#aba))\
if(__a)then b_a:addTextBox(1,2,_d,ad,\" \")\
b_a:addBackgroundBox(1,2,_d,ad,daa)b_a:addForegroundBox(1,2,_d,ad,_ba)\
for n=1,ad do\
if(caa[n+dc]~=nil)then local bba=ab.getTextHorizontalAlign(caa[\
n+dc].text,_d,cc)\
if(\
caa[n+dc]==baa)then\
if(bc)then local cba,dba=b_a:getSelectionColor()\
b_a:addBlit(1,n+1,bba,bb[dba]:rep(\
#bba),bb[cba]:rep(#bba))else\
b_a:addBlit(1,n+1,bba,bb[caa[n+dc].fgCol]:rep(#bba),bb[caa[n+dc].bgCol]:rep(\
#bba))end else\
b_a:addBlit(1,n+1,bba,bb[caa[n+dc].fgCol]:rep(#bba),bb[caa[n+dc].bgCol]:rep(\
#bba))end end end end end)end}a_a.__index=a_a;return setmetatable(a_a,_c)end end\
aa[\"objects\"][\"Flexbox\"]=function(...)\
local function ab(bb,cb)local db=0;local _c=0;local ac=0;local bc,cc=bb:getSize()\
local dc={getFlexGrow=function(_d)return db end,setFlexGrow=function(_d,ad)\
db=ad;return _d end,getFlexShrink=function(_d)return _c end,setFlexShrink=function(_d,ad)_c=ad;return _d end,getFlexBasis=function(_d)return ac end,setFlexBasis=function(_d,ad)\
ac=ad;return _d end,getSize=function(_d)return bc,cc end,getWidth=function(_d)return bc end,getHeight=function(_d)return cc end,setSize=function(_d,ad,bd,cd,dd)\
bb.setSize(_d,ad,bd,cd)if not dd then bc,cc=bb:getSize()end;return _d end}dc.__index=dc;return setmetatable(dc,bb)end\
return\
function(bb,cb)\
local db=cb.getObject(\"ScrollableFrame\")(bb,cb)local _c=\"Flexbox\"local ac=\"row\"local bc=1;local cc=\"flex-start\"local dc=\"nowrap\"local _d={}local ad={}\
local bd=false\
local cd=ab({getHeight=function(d_a)return 0 end,getWidth=function(d_a)return 0 end,getPosition=function(d_a)return 0,0 end,getSize=function(d_a)return 0,0 end,isType=function(d_a)return\
false end,getType=function(d_a)return\"lineBreakFakeObject\"end,setPosition=function(d_a)end,setSize=function(d_a)end})\
cd:setFlexBasis(0):setFlexGrow(0):setFlexShrink(0)\
local function dd(d_a)\
if(dc==\"nowrap\")then ad={}local _aa=1;local aaa=1;local baa=1\
for caa,daa in pairs(_d)do if(ad[_aa]==nil)then\
ad[_aa]={offset=1}end\
local _ba=ac==\"row\"and daa:getHeight()or daa:getWidth()if _ba>aaa then aaa=_ba end\
if(daa==cd)then baa=baa+aaa+bc;aaa=1;_aa=_aa+1\
ad[_aa]={offset=baa}else table.insert(ad[_aa],daa)end end elseif(dc==\"wrap\")then ad={}local _aa=1;local aaa=1;local baa=ac==\"row\"and d_a:getWidth()or\
d_a:getHeight()local caa=0;local daa=1\
for _ba,aba in pairs(_d)do if(\
ad[daa]==nil)then ad[daa]={offset=1}end\
if aba==cd then\
aaa=aaa+_aa+bc;caa=0;_aa=1;daa=daa+1;ad[daa]={offset=aaa}else local bba=\
ac==\"row\"and aba:getWidth()or aba:getHeight()\
if\
(bba+caa<=baa)then table.insert(ad[daa],aba)caa=caa+bba+bc else\
aaa=aaa+_aa+bc\
_aa=ac==\"row\"and aba:getHeight()or aba:getWidth()daa=daa+1;caa=bba+bc;ad[daa]={offset=aaa,aba}end\
local cba=ac==\"row\"and aba:getHeight()or aba:getWidth()if cba>_aa then _aa=cba end end end end end\
local function __a(d_a,_aa)local aaa,baa=d_a:getSize()local caa=0;local daa=0;local _ba=0\
for cba,dba in ipairs(_aa)do caa=caa+\
dba:getFlexGrow()daa=daa+dba:getFlexShrink()_ba=_ba+\
dba:getFlexBasis()end;local aba=aaa-_ba- (bc* (#_aa-1))local bba=1\
for cba,dba in ipairs(_aa)do\
if(dba~=cd)then\
local _ca;local aca=dba:getFlexGrow()local bca=dba:getFlexShrink()\
local cca=\
dba:getFlexBasis()~=0 and dba:getFlexBasis()or dba:getWidth()if caa>0 then _ca=cca+aca/caa*aba else _ca=cca end;if aba<0 and\
daa>0 then _ca=cca+bca/daa*aba end;dba:setPosition(bba,\
_aa.offset or 1)\
dba:setSize(_ca,dba:getHeight(),false,true)bba=bba+_ca+bc end end\
if cc==\"flex-end\"then local cba=bba-bc;local dba=aaa-cba+1\
for _ca,aca in ipairs(_aa)do\
local bca,cca=aca:getPosition()aca:setPosition(bca+dba,cca)end elseif cc==\"center\"then local cba=bba-bc;local dba=(aaa-cba)/2 +1\
for _ca,aca in ipairs(_aa)do\
local bca,cca=aca:getPosition()aca:setPosition(bca+dba,cca)end elseif cc==\"space-between\"then local cba=bba-bc\
local dba=(aaa-cba)/ (#_aa-1)+1\
for _ca,aca in ipairs(_aa)do if _ca>1 then local bca,cca=aca:getPosition()\
aca:setPosition(bca+dba* (_ca-1),cca)end end elseif cc==\"space-around\"then local cba=bba-bc;local dba=(aaa-cba)/#_aa\
for _ca,aca in ipairs(_aa)do\
local bca,cca=aca:getPosition()aca:setPosition(bca+dba*_ca-dba/2,cca)end elseif cc==\"space-evenly\"then local cba=#_aa+1;local dba=0;for cca,dca in ipairs(_aa)do\
dba=dba+dca:getWidth()end;local _ca=aaa-dba\
local aca=math.floor(_ca/cba)local bca=_ca-aca*cba;bba=aca+ (bca>0 and 1 or 0)bca=bca>\
0 and bca-1 or 0\
for cca,dca in ipairs(_aa)do\
dca:setPosition(bba,1)\
bba=bba+dca:getWidth()+aca+ (bca>0 and 1 or 0)bca=bca>0 and bca-1 or 0 end end end\
local function a_a(d_a,_aa)local aaa,baa=d_a:getSize()local caa=0;local daa=0;local _ba=0\
for cba,dba in ipairs(_aa)do caa=caa+\
dba:getFlexGrow()daa=daa+dba:getFlexShrink()_ba=_ba+\
dba:getFlexBasis()end;local aba=baa-_ba- (bc* (#_aa-1))local bba=1\
for cba,dba in ipairs(_aa)do\
if(dba~=cd)then\
local _ca;local aca=dba:getFlexGrow()local bca=dba:getFlexShrink()\
local cca=\
dba:getFlexBasis()~=0 and dba:getFlexBasis()or dba:getHeight()if caa>0 then _ca=cca+aca/caa*aba else _ca=cca end;if aba<0 and\
daa>0 then _ca=cca+bca/daa*aba end\
dba:setPosition(_aa.offset,bba)dba:setSize(dba:getWidth(),_ca,false,true)bba=\
bba+_ca+bc end end\
if cc==\"flex-end\"then local cba=bba-bc;local dba=baa-cba+1\
for _ca,aca in ipairs(_aa)do\
local bca,cca=aca:getPosition()aca:setPosition(bca,cca+dba)end elseif cc==\"center\"then local cba=bba-bc;local dba=(baa-cba)/2\
for _ca,aca in ipairs(_aa)do\
local bca,cca=aca:getPosition()aca:setPosition(bca,cca+dba)end elseif cc==\"space-between\"then local cba=bba-bc\
local dba=(baa-cba)/ (#_aa-1)+1\
for _ca,aca in ipairs(_aa)do if _ca>1 then local bca,cca=aca:getPosition()\
aca:setPosition(bca,cca+dba* (_ca-1))end end elseif cc==\"space-around\"then local cba=bba-bc;local dba=(baa-cba)/#_aa\
for _ca,aca in ipairs(_aa)do\
local bca,cca=aca:getPosition()aca:setPosition(bca,cca+dba*_ca-dba/2)end elseif cc==\"space-evenly\"then local cba=#_aa+1;local dba=0;for cca,dca in ipairs(_aa)do\
dba=dba+dca:getHeight()end;local _ca=baa-dba\
local aca=math.floor(_ca/cba)local bca=_ca-aca*cba;bba=aca+ (bca>0 and 1 or 0)bca=bca>\
0 and bca-1 or 0\
for cca,dca in ipairs(_aa)do\
local _da,ada=dca:getPosition()dca:setPosition(_da,bba)bba=\
bba+dca:getHeight()+aca+ (bca>0 and 1 or 0)bca=bca>0 and\
bca-1 or 0 end end end\
local function b_a(d_a)dd(d_a)\
if ac==\"row\"then for _aa,aaa in pairs(ad)do __a(d_a,aaa)end else for _aa,aaa in pairs(ad)do\
a_a(d_a,aaa)end end;bd=false end\
local c_a={getType=function()return _c end,isType=function(d_a,_aa)return\
_c==_aa or db.isType~=nil and db.isType(_aa)or false end,setJustifyContent=function(d_a,_aa)\
cc=_aa;bd=true;d_a:updateDraw()return d_a end,getJustifyContent=function(d_a)return cc end,setDirection=function(d_a,_aa)\
ac=_aa;bd=true;d_a:updateDraw()return d_a end,getDirection=function(d_a)return ac end,setSpacing=function(d_a,_aa)\
bc=_aa;bd=true;d_a:updateDraw()return d_a end,getSpacing=function(d_a)return bc end,setWrap=function(d_a,_aa)\
dc=_aa;bd=true;d_a:updateDraw()return d_a end,getWrap=function(d_a)return dc end,updateLayout=function(d_a)\
bd=true;d_a:updateDraw()end,addBreak=function(d_a)table.insert(_d,cd)\
bd=true;d_a:updateDraw()return d_a end,customEventHandler=function(d_a,_aa,...)\
db.customEventHandler(d_a,_aa,...)if _aa==\"basalt_FrameResize\"then bd=true end end,draw=function(d_a)\
db.draw(d_a)\
d_a:addDraw(\"flexboxDraw\",function()if bd then b_a(d_a)end end,1)end}\
for d_a,_aa in pairs(cb.getObjects())do\
c_a[\"add\"..d_a]=function(aaa,baa)\
local caa=db[\"add\"..d_a](aaa,baa)local daa=ab(caa,cb)table.insert(_d,daa)bd=true;return daa end end;c_a.__index=c_a;return setmetatable(c_a,db)end end\
aa[\"objects\"][\"Label\"]=function(...)local ab=da(\"utils\")local bb=ab.wrapText\
local cb=ab.writeWrappedText;local db=da(\"tHex\")\
return\
function(_c,ac)\
local bc=ac.getObject(\"VisualObject\")(_c,ac)local cc=\"Label\"bc:setZIndex(3)bc:setSize(5,1)\
bc:setBackground(false)local dc=true;local _d,ad=\"Label\",\"left\"\
local bd={getType=function(cd)return cc end,getBase=function(cd)return bc end,setText=function(cd,dd)\
_d=tostring(dd)\
if(dc)then local __a=bb(_d,#_d)local a_a,b_a=1,1;for c_a,d_a in pairs(__a)do b_a=b_a+1\
a_a=math.max(a_a,d_a:len())end;cd:setSize(a_a,b_a)dc=true end;cd:updateDraw()return cd end,getAutoSize=function(cd)return\
dc end,setAutoSize=function(cd,dd)dc=dd;return cd end,getText=function(cd)return _d end,setSize=function(cd,dd,__a)\
bc.setSize(cd,dd,__a)dc=false;return cd end,getTextAlign=function(cd)return ad end,setTextAlign=function(cd,dd)ad=dd or ad;return\
cd end,draw=function(cd)bc.draw(cd)\
cd:addDraw(\"label\",function()local dd,__a=cd:getSize()\
local a_a=\
\
\
ad==\"center\"and math.floor(dd/2 -_d:len()/2 +0.5)or ad==\"right\"and dd- (_d:len()-1)or 1;cb(cd,a_a,1,_d,dd+1,__a)end)end,init=function(cd)\
bc.init(cd)local dd=cd:getParent()\
cd:setForeground(dd:getForeground())end}bd.__index=bd;return setmetatable(bd,bc)end end\
aa[\"objects\"][\"Input\"]=function(...)local ab=da(\"utils\")local bb=da(\"tHex\")\
return\
function(cb,db)\
local _c=db.getObject(\"ChangeableObject\")(cb,db)local ac=\"Input\"local bc=\"text\"local cc=0;_c:setZIndex(5)_c:setValue(\"\")\
_c:setSize(12,1)local dc=1;local _d=1;local ad=\"\"local bd=colors.black;local cd=colors.lightGray;local dd=ad\
local __a=false\
local a_a={load=function(b_a)b_a:listenEvent(\"mouse_click\")\
b_a:listenEvent(\"key\")b_a:listenEvent(\"char\")\
b_a:listenEvent(\"other_event\")b_a:listenEvent(\"mouse_drag\")end,getType=function(b_a)return\
ac end,isType=function(b_a,c_a)return\
ac==c_a or _c.isType~=nil and _c.isType(c_a)or false end,setDefaultFG=function(b_a,c_a)return b_a:setDefaultText(b_a,ad,c_a,\
nil)end,setDefaultBG=function(b_a,c_a)return b_a:setDefaultText(b_a,ad,\
nil,c_a)end,setDefaultText=function(b_a,c_a,d_a,_aa)\
ad=c_a;cd=d_a or cd;bd=_aa or bd;if(b_a:isFocused())then dd=\"\"else dd=ad end\
b_a:updateDraw()return b_a end,getDefaultText=function(b_a)return ad,cd,\
bd end,setOffset=function(b_a,c_a)_d=c_a;b_a:updateDraw()return b_a end,getOffset=function(b_a)return\
_d end,setTextOffset=function(b_a,c_a)dc=c_a;b_a:updateDraw()return b_a end,getTextOffset=function(b_a)return\
dc end,setInputType=function(b_a,c_a)bc=c_a;b_a:updateDraw()return b_a end,getInputType=function(b_a)return\
bc end,setValue=function(b_a,c_a)_c.setValue(b_a,tostring(c_a))\
if not(__a)then dc=\
tostring(c_a):len()+1\
_d=math.max(1,dc-b_a:getWidth()+1)\
if(b_a:isFocused())then local d_a=b_a:getParent()\
local _aa,aaa=b_a:getPosition()\
d_a:setCursor(true,_aa+dc-_d,aaa+math.floor(b_a:getHeight()/2),b_a:getForeground())end end;b_a:updateDraw()return b_a end,getValue=function(b_a)\
local c_a=_c.getValue(b_a)\
return bc==\"number\"and tonumber(c_a)or c_a end,setInputLimit=function(b_a,c_a)\
cc=tonumber(c_a)or cc;b_a:updateDraw()return b_a end,getInputLimit=function(b_a)return cc end,getFocusHandler=function(b_a)\
_c.getFocusHandler(b_a)local c_a=b_a:getParent()\
if(c_a~=nil)then local d_a,_aa=b_a:getPosition()dd=\"\"if(ad~=\
\"\")then b_a:updateDraw()end\
c_a:setCursor(true,d_a+dc-_d,_aa+math.max(math.ceil(\
b_a:getHeight()/2 -1,1)),b_a:getForeground())end end,loseFocusHandler=function(b_a)\
_c.loseFocusHandler(b_a)local c_a=b_a:getParent()dd=ad\
if(ad~=\"\")then b_a:updateDraw()end;c_a:setCursor(false)end,keyHandler=function(b_a,c_a)\
if\
(_c.keyHandler(b_a,c_a))then local d_a,_aa=b_a:getSize()local aaa=b_a:getParent()__a=true\
if\
(c_a==keys.backspace)then local _ba=tostring(_c.getValue())\
if(dc>1)then b_a:setValue(_ba:sub(1,dc-2)..\
_ba:sub(dc,_ba:len()))dc=math.max(\
dc-1,1)if(dc<_d)then _d=math.max(_d-1,1)end end end\
if(c_a==keys.enter)then aaa:clearFocusedChild(b_a)end\
if(c_a==keys.right)then\
local _ba=tostring(_c.getValue()):len()dc=dc+1;if(dc>_ba)then dc=_ba+1 end;dc=math.max(dc,1)if(dc<_d)or\
(dc>=d_a+_d)then _d=dc-d_a+1 end;_d=math.max(_d,1)end;if(c_a==keys.left)then dc=dc-1;if(dc>=1)then\
if(dc<_d)or(dc>=d_a+_d)then _d=dc end end;dc=math.max(dc,1)\
_d=math.max(_d,1)end\
local baa,caa=b_a:getPosition()local daa=tostring(_c.getValue())b_a:updateDraw()\
__a=false;return true end end,charHandler=function(b_a,c_a)\
if\
(_c.charHandler(b_a,c_a))then __a=true;local d_a,_aa=b_a:getSize()local aaa=_c.getValue()\
if(\
aaa:len()<cc or cc<=0)then\
if(bc==\"number\")then local _ba=aaa\
if\
(dc==1 and c_a==\"-\")or(c_a==\".\")or(tonumber(c_a)~=nil)then\
b_a:setValue(aaa:sub(1,dc-1)..\
c_a..aaa:sub(dc,aaa:len()))dc=dc+1;if(c_a==\".\")or(c_a==\"-\")and(#aaa>0)then\
if(\
tonumber(_c.getValue())==nil)then b_a:setValue(_ba)dc=dc-1 end end end else\
b_a:setValue(aaa:sub(1,dc-1)..c_a..aaa:sub(dc,aaa:len()))dc=dc+1 end;if(dc>=d_a+_d)then _d=_d+1 end end;local baa,caa=b_a:getPosition()\
local daa=tostring(_c.getValue())__a=false;b_a:updateDraw()return true end end,mouseHandler=function(b_a,c_a,d_a,_aa)\
if\
(_c.mouseHandler(b_a,c_a,d_a,_aa))then local aaa=b_a:getParent()local baa,caa=b_a:getPosition()\
local daa,_ba=b_a:getAbsolutePosition(baa,caa)local aba,bba=b_a:getSize()dc=d_a-daa+_d;local cba=_c.getValue()if(dc>\
cba:len())then dc=cba:len()+1 end;if(dc<_d)then _d=dc-1\
if(_d<1)then _d=1 end end\
aaa:setCursor(true,baa+dc-_d,caa+\
math.max(math.ceil(bba/2 -1,1)),b_a:getForeground())return true end end,dragHandler=function(b_a,c_a,d_a,_aa,aaa,baa)\
if\
(b_a:isFocused())then if(b_a:isCoordsInObject(d_a,_aa))then\
if(_c.dragHandler(b_a,c_a,d_a,_aa,aaa,baa))then return true end end\
local caa=b_a:getParent()caa:clearFocusedChild()end end,draw=function(b_a)\
_c.draw(b_a)\
b_a:addDraw(\"input\",function()local c_a=b_a:getParent()local d_a,_aa=b_a:getPosition()\
local aaa,baa=b_a:getSize()local caa=ab.getTextVerticalAlign(baa,textVerticalAlign)\
local daa=tostring(_c.getValue())local _ba=b_a:getBackground()local aba=b_a:getForeground()local bba;if(\
daa:len()<=0)then bba=dd;_ba=bd or _ba;aba=cd or aba end\
bba=dd;if(daa~=\"\")then bba=daa end;bba=bba:sub(_d,aaa+_d-1)local cba=aaa-\
bba:len()if(cba<0)then cba=0 end\
if\
(bc==\"password\")and(daa~=\"\")then bba=string.rep(\"*\",bba:len())end;bba=bba..string.rep(\" \",cba)\
b_a:addBlit(1,caa,bba,bb[aba]:rep(bba:len()),bb[_ba]:rep(bba:len()))if(b_a:isFocused())then\
c_a:setCursor(true,d_a+dc-_d,_aa+\
math.floor(b_a:getHeight()/2),b_a:getForeground())end end)end}a_a.__index=a_a;return setmetatable(a_a,_c)end end\
aa[\"objects\"][\"Menubar\"]=function(...)local ab=da(\"utils\")local bb=da(\"tHex\")\
return\
function(cb,db)\
local _c=db.getObject(\"List\")(cb,db)local ac=\"Menubar\"local bc={}_c:setSize(30,1)_c:setZIndex(5)local cc=0\
local dc,_d=1,1;local ad=true\
local function bd()local cd=0;local dd=_c:getWidth()local __a=_c:getAll()for n=1,#__a do cd=cd+\
__a[n].text:len()+dc*2 end;return\
math.max(cd-dd,0)end\
bc={init=function(cd)local dd=cd:getParent()cd:listenEvent(\"mouse_click\")\
cd:listenEvent(\"mouse_drag\")cd:listenEvent(\"mouse_scroll\")return _c.init(cd)end,getType=function(cd)return\
ac end,getBase=function(cd)return _c end,setSpace=function(cd,dd)dc=dd or dc;cd:updateDraw()\
return cd end,getSpace=function(cd)return dc end,setScrollable=function(cd,dd)ad=dd\
if(dd==nil)then ad=true end;return cd end,getScrollable=function(cd)return ad end,mouseHandler=function(cd,dd,__a,a_a)\
if\
(_c:getBase().mouseHandler(cd,dd,__a,a_a))then local b_a,c_a=cd:getAbsolutePosition()local d_a,_aa=cd:getSize()local aaa=0\
local baa=cd:getAll()\
for n=1,#baa do\
if(baa[n]~=nil)then\
if\
(b_a+aaa<=__a+cc)and(\
b_a+aaa+baa[n].text:len()+ (dc*2)>__a+cc)and(c_a==a_a)then\
cd:setValue(baa[n])cd:sendEvent(event,cd,event,0,__a,a_a,baa[n])end;aaa=aaa+baa[n].text:len()+dc*2 end end;cd:updateDraw()return true end end,scrollHandler=function(cd,dd,__a,a_a)\
if\
(_c:getBase().scrollHandler(cd,dd,__a,a_a))then if(ad)then cc=cc+dd;if(cc<0)then cc=0 end;local b_a=bd()if(cc>b_a)then cc=b_a end\
cd:updateDraw()end;return true end;return false end,draw=function(cd)\
_c.draw(cd)\
cd:addDraw(\"list\",function()local dd=cd:getParent()local __a,a_a=cd:getSize()local b_a=\"\"local c_a=\"\"\
local d_a=\"\"local _aa,aaa=cd:getSelectionColor()\
for baa,caa in pairs(cd:getAll())do\
local daa=\
(\" \"):rep(dc)..caa.text.. (\" \"):rep(dc)b_a=b_a..daa\
if(caa==cd:getValue())then c_a=c_a..\
bb[_aa or caa.bgCol or\
cd:getBackground()]:rep(daa:len())d_a=d_a..\
bb[aaa or\
caa.FgCol or cd:getForeground()]:rep(daa:len())else c_a=c_a..\
bb[caa.bgCol or\
cd:getBackground()]:rep(daa:len())d_a=d_a..\
bb[caa.FgCol or\
cd:getForeground()]:rep(daa:len())end end\
cd:addBlit(1,1,b_a:sub(cc+1,__a+cc),d_a:sub(cc+1,__a+cc),c_a:sub(cc+1,__a+cc))end)end}bc.__index=bc;return setmetatable(bc,_c)end end\
aa[\"objects\"][\"Pane\"]=function(...)\
return\
function(ab,bb)\
local cb=bb.getObject(\"VisualObject\")(ab,bb)local db=\"Pane\"cb:setSize(25,10)\
local _c={getType=function(ac)return db end}_c.__index=_c;return setmetatable(_c,cb)end end\
aa[\"objects\"][\"Slider\"]=function(...)local ab=da(\"tHex\")\
return\
function(bb,cb)\
local db=cb.getObject(\"ChangeableObject\")(bb,cb)local _c=\"Slider\"db:setSize(12,1)db:setValue(1)\
db:setBackground(false,\"\\140\",colors.black)local ac=\"horizontal\"local bc=\" \"local cc=colors.black;local dc=colors.gray;local _d=12;local ad=1\
local bd=1\
local function cd(__a,a_a,b_a,c_a)local d_a,_aa=__a:getPosition()local aaa,baa=__a:getSize()local caa=\
ac==\"vertical\"and baa or aaa\
for i=0,caa do\
if\
\
(\
(ac==\"vertical\"and _aa+i==c_a)or(ac==\"horizontal\"and d_a+i==b_a))and(d_a<=b_a)and(d_a+aaa>b_a)and(_aa<=c_a)and\
(_aa+baa>c_a)then ad=math.min(i+1,caa- (#\
bc+bd-2))\
__a:setValue(_d/caa*ad)__a:updateDraw()end end end\
local dd={getType=function(__a)return _c end,load=function(__a)__a:listenEvent(\"mouse_click\")\
__a:listenEvent(\"mouse_drag\")__a:listenEvent(\"mouse_scroll\")end,setSymbol=function(__a,a_a)\
bc=a_a:sub(1,1)__a:updateDraw()return __a end,getSymbol=function(__a)return bc end,setIndex=function(__a,a_a)\
ad=a_a;if(ad<1)then ad=1 end;local b_a,c_a=__a:getSize()\
ad=math.min(ad,(\
ac==\"vertical\"and c_a or b_a)- (bd-1))\
__a:setValue(_d/ (ac==\"vertical\"and c_a or b_a)*ad)__a:updateDraw()return __a end,getIndex=function(__a)return\
ad end,setMaxValue=function(__a,a_a)_d=a_a;return __a end,getMaxValue=function(__a)return _d end,setSymbolColor=function(__a,a_a)\
symbolColor=a_a;__a:updateDraw()return __a end,getSymbolColor=function(__a)\
return symbolColor end,setBarType=function(__a,a_a)ac=a_a:lower()__a:updateDraw()return __a end,getBarType=function(__a)return\
ac end,mouseHandler=function(__a,a_a,b_a,c_a)if(db.mouseHandler(__a,a_a,b_a,c_a))then cd(__a,a_a,b_a,c_a)return\
true end;return false end,dragHandler=function(__a,a_a,b_a,c_a)if\
(db.dragHandler(__a,a_a,b_a,c_a))then cd(__a,a_a,b_a,c_a)return true end\
return false end,scrollHandler=function(__a,a_a,b_a,c_a)\
if\
(db.scrollHandler(__a,a_a,b_a,c_a))then local d_a,_aa=__a:getSize()ad=ad+a_a;if(ad<1)then ad=1 end\
ad=math.min(ad,(\
ac==\"vertical\"and _aa or d_a)- (bd-1))\
__a:setValue(_d/ (ac==\"vertical\"and _aa or d_a)*ad)__a:updateDraw()return true end;return false end,draw=function(__a)\
db.draw(__a)\
__a:addDraw(\"slider\",function()local a_a,b_a=__a:getSize()\
local c_a,d_a=__a:getBackground(),__a:getForeground()\
if(ac==\"horizontal\")then __a:addText(ad,oby,bc:rep(bd))\
if(dc~=false)then __a:addBG(ad,1,ab[dc]:rep(\
#bc*bd))end;if(cc~=false)then\
__a:addFG(ad,1,ab[cc]:rep(#bc*bd))end end\
if(ac==\"vertical\")then\
for n=0,b_a-1 do\
if(ad==n+1)then for curIndexOffset=0,math.min(bd-1,b_a)do\
__a:addBlit(1,1 +n+curIndexOffset,bc,ab[symbolColor],ab[symbolColor])end else if(n+1 <ad)or(n+1 >\
ad-1 +bd)then\
__a:addBlit(1,1 +n,bgSymbol,ab[d_a],ab[c_a])end end end end end)end}dd.__index=dd;return setmetatable(dd,db)end end\
aa[\"objects\"][\"MovableFrame\"]=function(...)\
local ab,bb,cb,db=math.max,math.min,string.sub,string.rep\
return\
function(_c,ac)local bc=ac.getObject(\"Frame\")(_c,ac)local cc=\"MovableFrame\"\
local dc;local _d,ad,bd=0,0,false;local cd={{x1=1,x2=\"width\",y1=1,y2=1}}\
local dd={getType=function()return cc end,setDraggingMap=function(__a,a_a)\
cd=a_a;return __a end,getDraggingMap=function(__a)return cd end,isType=function(__a,a_a)\
return cc==a_a or(bc.isType~=nil and\
bc.isType(a_a))or false end,getBase=function(__a)return bc end,load=function(__a)\
bc.load(__a)__a:listenEvent(\"mouse_click\")\
__a:listenEvent(\"mouse_up\")__a:listenEvent(\"mouse_drag\")end,removeChildren=function(__a)\
bc.removeChildren(__a)__a:listenEvent(\"mouse_click\")\
__a:listenEvent(\"mouse_up\")__a:listenEvent(\"mouse_drag\")end,dragHandler=function(__a,a_a,b_a,c_a)\
if\
(bc.dragHandler(__a,a_a,b_a,c_a))then\
if(bd)then local d_a,_aa=dc:getOffset()\
d_a=d_a<0 and math.abs(d_a)or-d_a;_aa=_aa<0 and math.abs(_aa)or-_aa;local aaa=1\
local baa=1;aaa,baa=dc:getAbsolutePosition()\
__a:setPosition(b_a+_d- (aaa-1)+d_a,\
c_a+ad- (baa-1)+_aa)__a:updateDraw()end;return true end end,mouseHandler=function(__a,a_a,b_a,c_a,...)\
if\
(bc.mouseHandler(__a,a_a,b_a,c_a,...))then dc:setImportant(__a)local d_a,_aa=__a:getAbsolutePosition()\
local aaa,baa=__a:getSize()\
for caa,daa in pairs(cd)do local _ba,aba=daa.x1 ==\"width\"and aaa or daa.x1,daa.x2 ==\"width\"and\
aaa or daa.x2;local bba,cba=\
daa.y1 ==\"height\"and baa or daa.y1,\
daa.y2 ==\"height\"and baa or daa.y2\
if\
(b_a>=\
d_a+_ba-1)and(b_a<=d_a+aba-1)and(c_a>=_aa+bba-1)and(c_a<=_aa+cba-1)then bd=true\
_d=d_a-b_a;ad=_aa-c_a;return true end end;return true end end,mouseUpHandler=function(__a,...)\
bd=false;return bc.mouseUpHandler(__a,...)end,setParent=function(__a,a_a,...)\
bc.setParent(__a,a_a,...)dc=a_a;return __a end}dd.__index=dd;return setmetatable(dd,bc)end end\
aa[\"objects\"][\"Radio\"]=function(...)local ab=da(\"utils\")local bb=da(\"tHex\")\
return\
function(cb,db)\
local _c=db.getObject(\"List\")(cb,db)local ac=\"Radio\"_c:setSize(1,1)_c:setZIndex(5)local bc={}\
local cc=colors.black;local dc=colors.green;local _d=colors.black;local ad=colors.red;local bd=true;local cd=\"\\7\"\
local dd=\"left\"\
local __a={getType=function(a_a)return ac end,addItem=function(a_a,b_a,c_a,d_a,_aa,aaa,...)_c.addItem(a_a,b_a,_aa,aaa,...)table.insert(bc,{x=c_a or 1,y=\
d_a or#bc*2})\
return a_a end,removeItem=function(a_a,b_a)\
_c.removeItem(a_a,b_a)table.remove(bc,b_a)return a_a end,clear=function(a_a)\
_c.clear(a_a)bc={}return a_a end,editItem=function(a_a,b_a,c_a,d_a,_aa,aaa,baa,...)\
_c.editItem(a_a,b_a,c_a,aaa,baa,...)table.remove(bc,b_a)\
table.insert(bc,b_a,{x=d_a or 1,y=_aa or 1})return a_a end,setBoxSelectionColor=function(a_a,b_a,c_a)\
cc=b_a;dc=c_a;return a_a end,setBoxSelectionBG=function(a_a,b_a)\
return a_a:setBoxSelectionColor(b_a,dc)end,setBoxSelectionFG=function(a_a,b_a)\
return a_a:setBoxSelectionColor(cc,b_a)end,getBoxSelectionColor=function(a_a)return cc,dc end,getBoxSelectionBG=function(a_a)return cc end,getBoxSelectionFG=function(a_a)\
return dc end,setBoxDefaultColor=function(a_a,b_a,c_a)_d=b_a;ad=c_a;return a_a end,setBoxDefaultBG=function(a_a,b_a)return\
a_a:setBoxDefaultColor(b_a,ad)end,setBoxDefaultFG=function(a_a,b_a)return\
a_a:setBoxDefaultColor(_d,b_a)end,getBoxDefaultColor=function(a_a)return _d,ad end,getBoxDefaultBG=function(a_a)return _d end,getBoxDefaultFG=function(a_a)return\
ad end,mouseHandler=function(a_a,b_a,c_a,d_a,...)\
if(#bc>0)then local _aa,aaa=a_a:getAbsolutePosition()\
local baa=a_a:getAll()\
for caa,daa in pairs(baa)do\
if\
\
(_aa+bc[caa].x-1 <=c_a)and(_aa+bc[caa].x-1 +\
daa.text:len()+1 >=c_a)and(aaa+bc[caa].y-1 ==d_a)then a_a:setValue(daa)\
local _ba=a_a:sendEvent(\"mouse_click\",a_a,\"mouse_click\",b_a,c_a,d_a,...)a_a:updateDraw()if(_ba==false)then return _ba end;return true end end end end,draw=function(a_a)\
a_a:addDraw(\"radio\",function()\
local b_a,c_a=a_a:getSelectionColor()local d_a=a_a:getAll()\
for _aa,aaa in pairs(d_a)do\
if(aaa==a_a:getValue())then\
a_a:addBlit(bc[_aa].x,bc[_aa].y,cd,bb[dc],bb[cc])\
a_a:addBlit(bc[_aa].x+2,bc[_aa].y,aaa.text,bb[c_a]:rep(#aaa.text),bb[b_a]:rep(\
#aaa.text))else\
a_a:addBackgroundBox(bc[_aa].x,bc[_aa].y,1,1,_d or colors.black)\
a_a:addBlit(bc[_aa].x+2,bc[_aa].y,aaa.text,bb[aaa.fgCol]:rep(#aaa.text),bb[aaa.bgCol]:rep(\
#aaa.text))end end;return true end)end}__a.__index=__a;return setmetatable(__a,_c)end end\
aa[\"objects\"][\"VisualObject\"]=function(...)local ab=da(\"utils\")local bb=da(\"tHex\")\
local cb,db,_c=string.sub,string.find,table.insert\
return\
function(ac,bc)local cc=bc.getObject(\"Object\")(ac,bc)\
local dc=\"VisualObject\"local _d,ad,bd,cd,dd=true,false,false,false,false;local __a=1;local a_a,b_a,c_a,d_a=1,1,1,1\
local _aa,aaa,baa,caa=0,0,0,0;local daa,_ba,aba=colors.black,colors.white,false;local bba;local cba={}local dba={}local _ca={}\
local aca={}\
local function bca(dca,_da)local ada={}if dca==\"\"then return ada end;_da=_da or\" \"local bda=1\
local cda,dda=db(dca,_da,bda)\
while cda do\
_c(ada,{x=bda,value=cb(dca,bda,cda-1)})bda=dda+1;cda,dda=db(dca,_da,bda)end;_c(ada,{x=bda,value=cb(dca,bda)})return ada end\
local cca={getType=function(dca)return dc end,getBase=function(dca)return cc end,isType=function(dca,_da)\
return dc==_da or\
cc.isType~=nil and cc.isType(_da)or false end,getBasalt=function(dca)return bc end,show=function(dca)_d=true\
dca:updateDraw()return dca end,hide=function(dca)_d=false;dca:updateDraw()return dca end,isVisible=function(dca)return\
_d end,setVisible=function(dca,_da)_d=_da or not _d;dca:updateDraw()return dca end,setTransparency=function(dca,_da)aba=\
_da~=nil and _da or true;dca:updateDraw()\
return dca end,setParent=function(dca,_da,ada)\
cc.setParent(dca,_da,ada)bba=_da;return dca end,setFocus=function(dca)if(bba~=nil)then\
bba:setFocusedChild(dca)end;return dca end,setZIndex=function(dca,_da)__a=_da\
if\
(bba~=nil)then bba:updateZIndex(dca,__a)dca:updateDraw()end;return dca end,getZIndex=function(dca)return __a end,updateDraw=function(dca)if(\
bba~=nil)then bba:updateDraw()end;return dca end,setPosition=function(dca,_da,ada,bda)\
local cda,dda=a_a,b_a\
if(type(_da)==\"number\")then a_a=bda and a_a+_da or _da end\
if(type(ada)==\"number\")then b_a=bda and b_a+ada or ada end;if(bba~=nil)then\
bba:customEventHandler(\"basalt_FrameReposition\",dca)end;if(dca:getType()==\"Container\")then\
bba:customEventHandler(\"basalt_FrameReposition\",dca)end;dca:updateDraw()\
dca:repositionHandler(cda,dda)return dca end,getX=function(dca)return\
a_a end,setX=function(dca,_da)return dca:setPosition(_da,b_a)end,getY=function(dca)return\
b_a end,setY=function(dca,_da)return dca:setPosition(a_a,_da)end,getPosition=function(dca)return\
a_a,b_a end,setSize=function(dca,_da,ada,bda)local cda,dda=c_a,d_a;if(type(_da)==\"number\")then c_a=\
bda and c_a+_da or _da end;if\
(type(ada)==\"number\")then d_a=bda and d_a+ada or ada end\
if\
(bba~=nil)then bba:customEventHandler(\"basalt_FrameResize\",dca)if(\
dca:getType()==\"Container\")then\
bba:customEventHandler(\"basalt_FrameResize\",dca)end end;dca:resizeHandler(cda,dda)dca:updateDraw()return dca end,getHeight=function(dca)return\
d_a end,setHeight=function(dca,_da)return dca:setSize(c_a,_da)end,getWidth=function(dca)return\
c_a end,setWidth=function(dca,_da)return dca:setSize(_da,d_a)end,getSize=function(dca)return\
c_a,d_a end,setBackground=function(dca,_da)daa=_da;dca:updateDraw()return dca end,getBackground=function(dca)return\
daa end,setForeground=function(dca,_da)_ba=_da or false;dca:updateDraw()return dca end,getForeground=function(dca)return\
_ba end,getAbsolutePosition=function(dca,_da,ada)if(_da==nil)or(ada==nil)then\
_da,ada=dca:getPosition()end\
if(bba~=nil)then\
local bda,cda=bba:getAbsolutePosition()_da=bda+_da-1;ada=cda+ada-1 end;return _da,ada end,ignoreOffset=function(dca,_da)\
ad=_da;if(_da==nil)then ad=true end;return dca end,getIgnoreOffset=function(dca)return ad end,isCoordsInObject=function(dca,_da,ada)\
if\
(_d)and(dca:isEnabled())then\
if(_da==nil)or(ada==nil)then return false end;local bda,cda=dca:getAbsolutePosition()local dda,__b=dca:getSize()if\
\
(bda<=_da)and(bda+dda>_da)and(cda<=ada)and(cda+__b>ada)then return true end end;return false end,onGetFocus=function(dca,...)\
for _da,ada in\
pairs(table.pack(...))do if(type(ada)==\"function\")then\
dca:registerEvent(\"get_focus\",ada)end end;return dca end,onLoseFocus=function(dca,...)\
for _da,ada in\
pairs(table.pack(...))do if(type(ada)==\"function\")then\
dca:registerEvent(\"lose_focus\",ada)end end;return dca end,isFocused=function(dca)if(\
bba~=nil)then return bba:getFocused()==dca end;return\
true end,resizeHandler=function(dca,...)\
if(dca:isEnabled())then\
local _da=dca:sendEvent(\"basalt_resize\",...)if(_da==false)then return false end end;return true end,repositionHandler=function(dca,...)if\
(dca:isEnabled())then local _da=dca:sendEvent(\"basalt_reposition\",...)if(_da==false)then\
return false end end;return\
true end,onResize=function(dca,...)\
for _da,ada in\
pairs(table.pack(...))do if(type(ada)==\"function\")then\
dca:registerEvent(\"basalt_resize\",ada)end end;return dca end,onReposition=function(dca,...)\
for _da,ada in\
pairs(table.pack(...))do if(type(ada)==\"function\")then\
dca:registerEvent(\"basalt_reposition\",ada)end end;return dca end,mouseHandler=function(dca,_da,ada,bda,cda)\
if\
(dca:isCoordsInObject(ada,bda))then local dda,__b=dca:getAbsolutePosition()\
local a_b=dca:sendEvent(\"mouse_click\",_da,ada- (dda-1),\
bda- (__b-1),ada,bda,cda)if(a_b==false)then return false end;if(bba~=nil)then\
bba:setFocusedChild(dca)end;cd=true;dd=true;_aa,aaa=ada,bda;return true end end,mouseUpHandler=function(dca,_da,ada,bda)\
dd=false\
if(cd)then local cda,dda=dca:getAbsolutePosition()\
local __b=dca:sendEvent(\"mouse_release\",_da,ada- (cda-1),\
bda- (dda-1),ada,bda)cd=false end\
if(dca:isCoordsInObject(ada,bda))then local cda,dda=dca:getAbsolutePosition()\
local __b=dca:sendEvent(\"mouse_up\",_da,\
ada- (cda-1),bda- (dda-1),ada,bda)if(__b==false)then return false end;return true end end,dragHandler=function(dca,_da,ada,bda)\
if\
(dd)then local cda,dda=dca:getAbsolutePosition()\
local __b=dca:sendEvent(\"mouse_drag\",_da,ada- (cda-1),bda- (\
dda-1),_aa-ada,aaa-bda,ada,bda)_aa,aaa=ada,bda;if(__b==false)then return false end;if(bba~=nil)then\
bba:setFocusedChild(dca)end;return true end\
if(dca:isCoordsInObject(ada,bda))then local cda,dda=dca:getAbsolutePosition()\
_aa,aaa=ada,bda;baa,caa=cda-ada,dda-bda end end,scrollHandler=function(dca,_da,ada,bda)\
if\
(dca:isCoordsInObject(ada,bda))then local cda,dda=dca:getAbsolutePosition()\
local __b=dca:sendEvent(\"mouse_scroll\",_da,ada- (cda-1),\
bda- (dda-1))if(__b==false)then return false end;if(bba~=nil)then\
bba:setFocusedChild(dca)end;return true end end,hoverHandler=function(dca,_da,ada,bda)\
if\
(dca:isCoordsInObject(_da,ada))then local cda=dca:sendEvent(\"mouse_hover\",_da,ada,bda)if(cda==false)then return\
false end;bd=true;return true end\
if(bd)then local cda=dca:sendEvent(\"mouse_leave\",_da,ada,bda)if\
(cda==false)then return false end;bd=false end end,keyHandler=function(dca,_da,ada)if\
(dca:isEnabled())and(_d)then\
if(dca:isFocused())then\
local bda=dca:sendEvent(\"key\",_da,ada)if(bda==false)then return false end;return true end end end,keyUpHandler=function(dca,_da)if\
(dca:isEnabled())and(_d)then\
if(dca:isFocused())then\
local ada=dca:sendEvent(\"key_up\",_da)if(ada==false)then return false end;return true end end end,charHandler=function(dca,_da)if\
(dca:isEnabled())and(_d)then\
if(dca:isFocused())then local ada=dca:sendEvent(\"char\",_da)if(ada==\
false)then return false end;return true end end end,getFocusHandler=function(dca)\
local _da=dca:sendEvent(\"get_focus\")if(_da~=nil)then return _da end;return true end,loseFocusHandler=function(dca)\
dd=false;local _da=dca:sendEvent(\"lose_focus\")\
if(_da~=nil)then return _da end;return true end,addDraw=function(dca,_da,ada,bda,cda,dda)\
local __b=\
(cda==nil or cda==1)and dba or cda==2 and cba or cda==3 and _ca;bda=bda or#__b+1\
if(_da~=nil)then for b_b,c_b in pairs(__b)do if(c_b.name==_da)then\
table.remove(__b,b_b)break end end\
local a_b={name=_da,f=ada,pos=bda,active=\
dda~=nil and dda or true}table.insert(__b,bda,a_b)end;dca:updateDraw()return dca end,addPreDraw=function(dca,_da,ada,bda,cda)\
dca:addDraw(_da,ada,bda,2)return dca end,addPostDraw=function(dca,_da,ada,bda,cda)\
dca:addDraw(_da,ada,bda,3)return dca end,setDrawState=function(dca,_da,ada,bda)\
local cda=\
(bda==nil or bda==1)and dba or bda==2 and cba or bda==3 and _ca\
for dda,__b in pairs(cda)do if(__b.name==_da)then __b.active=ada;break end end;dca:updateDraw()return dca end,getDrawId=function(dca,_da,ada)local bda=\
\
ada==1 and dba or ada==2 and cba or ada==3 and _ca or dba;for cda,dda in pairs(bda)do if(\
dda.name==_da)then return cda end end end,addText=function(dca,_da,ada,bda)local cda=\
dca:getParent()or dca;local dda,__b=dca:getPosition()if(bba~=nil)then\
local b_b,c_b=bba:getOffset()dda=ad and dda or dda-b_b\
__b=ad and __b or __b-c_b end\
if not(aba)then cda:setText(_da+dda-1,\
ada+__b-1,bda)return end;local a_b=bca(bda,\"\\0\")\
for b_b,c_b in pairs(a_b)do if\
(c_b.value~=\"\")and(c_b.value~=\"\\0\")then\
cda:setText(_da+c_b.x+dda-2,ada+__b-1,c_b.value)end end end,addBG=function(dca,_da,ada,bda,cda)local dda=\
bba or dca;local __b,a_b=dca:getPosition()if(bba~=nil)then\
local c_b,d_b=bba:getOffset()__b=ad and __b or __b-c_b\
a_b=ad and a_b or a_b-d_b end\
if not(aba)then dda:setBG(_da+__b-1,\
ada+a_b-1,bda)return end;local b_b=bca(bda)\
for c_b,d_b in pairs(b_b)do\
if(d_b.value~=\"\")and(d_b.value~=\" \")then\
if(cda~=\
true)then\
dda:setText(_da+d_b.x+__b-2,ada+a_b-1,(\" \"):rep(#d_b.value))\
dda:setBG(_da+d_b.x+__b-2,ada+a_b-1,d_b.value)else\
table.insert(aca,{x=_da+d_b.x-1,y=ada,bg=d_b.value})dda:setBG(_da+__b-1,ada+a_b-1,fg)end end end end,addFG=function(dca,_da,ada,bda)local cda=\
bba or dca;local dda,__b=dca:getPosition()if(bba~=nil)then\
local b_b,c_b=bba:getOffset()dda=ad and dda or dda-b_b\
__b=ad and __b or __b-c_b end\
if not(aba)then cda:setFG(_da+dda-1,\
ada+__b-1,bda)return end;local a_b=bca(bda)\
for b_b,c_b in pairs(a_b)do if(c_b.value~=\"\")and(c_b.value~=\" \")then\
cda:setFG(\
_da+c_b.x+dda-2,ada+__b-1,c_b.value)end end end,addBlit=function(dca,_da,ada,bda,cda,dda)local __b=\
bba or dca;local a_b,b_b=dca:getPosition()if(bba~=nil)then\
local aab,bab=bba:getOffset()a_b=ad and a_b or a_b-aab\
b_b=ad and b_b or b_b-bab end\
if not(aba)then __b:blit(_da+a_b-1,\
ada+b_b-1,bda,cda,dda)return end;local c_b=bca(bda,\"\\0\")local d_b=bca(cda)local _ab=bca(dda)\
for aab,bab in pairs(c_b)do if\
(bab.value~=\"\")or(bab.value~=\"\\0\")then\
__b:setText(_da+bab.x+a_b-2,ada+b_b-1,bab.value)end end;for aab,bab in pairs(_ab)do\
if(bab.value~=\"\")or(bab.value~=\" \")then __b:setBG(\
_da+bab.x+a_b-2,ada+b_b-1,bab.value)end end;for aab,bab in pairs(d_b)do\
if(\
bab.value~=\"\")or(bab.value~=\" \")then __b:setFG(_da+bab.x+a_b-2,ada+\
b_b-1,bab.value)end end end,addTextBox=function(dca,_da,ada,bda,cda,dda)local __b=\
bba or dca;local a_b,b_b=dca:getPosition()if(bba~=nil)then\
local c_b,d_b=bba:getOffset()a_b=ad and a_b or a_b-c_b\
b_b=ad and b_b or b_b-d_b end;__b:drawTextBox(_da+a_b-1,\
ada+b_b-1,bda,cda,dda)end,addForegroundBox=function(dca,_da,ada,bda,cda,dda)local __b=\
bba or dca;local a_b,b_b=dca:getPosition()if(bba~=nil)then\
local c_b,d_b=bba:getOffset()a_b=ad and a_b or a_b-c_b\
b_b=ad and b_b or b_b-d_b end;__b:drawForegroundBox(_da+a_b-1,\
ada+b_b-1,bda,cda,dda)end,addBackgroundBox=function(dca,_da,ada,bda,cda,dda)local __b=\
bba or dca;local a_b,b_b=dca:getPosition()if(bba~=nil)then\
local c_b,d_b=bba:getOffset()a_b=ad and a_b or a_b-c_b\
b_b=ad and b_b or b_b-d_b end;__b:drawBackgroundBox(_da+a_b-1,\
ada+b_b-1,bda,cda,dda)end,render=function(dca)if\
(_d)then dca:redraw()end end,redraw=function(dca)for _da,ada in pairs(cba)do if(ada.active)then\
ada.f(dca)end end;for _da,ada in pairs(dba)do if(ada.active)then\
ada.f(dca)end end;for _da,ada in pairs(_ca)do if(ada.active)then\
ada.f(dca)end end;return true end,draw=function(dca)\
dca:addDraw(\"base\",function()\
local _da,ada=dca:getSize()if(daa~=false)then dca:addTextBox(1,1,_da,ada,\" \")\
dca:addBackgroundBox(1,1,_da,ada,daa)end;if(_ba~=false)then\
dca:addForegroundBox(1,1,_da,ada,_ba)end end,1)end}cca.__index=cca;return setmetatable(cca,cc)end end\
aa[\"objects\"][\"ScrollableFrame\"]=function(...)\
local ab,bb,cb,db=math.max,math.min,string.sub,string.rep\
return\
function(_c,ac)local bc=ac.getObject(\"Frame\")(_c,ac)\
local cc=\"ScrollableFrame\"local dc;local _d=0;local ad=0;local bd=true\
local function cd(b_a)local c_a=0;local d_a=b_a:getChildren()\
for _aa,aaa in pairs(d_a)do\
if(\
aaa.element.getWidth~=nil)and(aaa.element.getX~=nil)then\
local baa,caa=aaa.element:getWidth(),aaa.element:getX()local daa=b_a:getWidth()\
if\
(aaa.element:getType()==\"Dropdown\")then if(aaa.element:isOpened())then\
local _ba=aaa.element:getDropdownSize()\
if(_ba+caa-daa>=c_a)then c_a=ab(_ba+caa-daa,0)end end end\
if(baa+caa-daa>=c_a)then c_a=ab(baa+caa-daa,0)end end end;return c_a end\
local function dd(b_a)local c_a=0;local d_a=b_a:getChildren()\
for _aa,aaa in pairs(d_a)do\
if\
(aaa.element.getHeight~=nil)and(aaa.element.getY~=nil)then\
local baa,caa=aaa.element:getHeight(),aaa.element:getY()local daa=b_a:getHeight()\
if\
(aaa.element:getType()==\"Dropdown\")then if(aaa.element:isOpened())then\
local _ba,aba=aaa.element:getDropdownSize()\
if(aba+caa-daa>=c_a)then c_a=ab(aba+caa-daa,0)end end end\
if(baa+caa-daa>=c_a)then c_a=ab(baa+caa-daa,0)end end end;return c_a end\
local function __a(b_a,c_a)local d_a,_aa=b_a:getOffset()local aaa\
if(_d==1)then\
aaa=bd and cd(b_a)or ad\
b_a:setOffset(bb(aaa,ab(0,d_a+c_a)),_aa)elseif(_d==0)then aaa=bd and dd(b_a)or ad\
b_a:setOffset(d_a,bb(aaa,ab(0,_aa+c_a)))end;b_a:updateDraw()end\
local a_a={getType=function()return cc end,isType=function(b_a,c_a)return\
cc==c_a or bc.isType~=nil and bc.isType(c_a)or false end,setDirection=function(b_a,c_a)_d=\
c_a==\"horizontal\"and 1 or c_a==\"vertical\"and 0 or\
_d;return b_a end,setScrollAmount=function(b_a,c_a)\
ad=c_a;bd=false;return b_a end,getBase=function(b_a)return bc end,load=function(b_a)bc.load(b_a)\
b_a:listenEvent(\"mouse_scroll\")end,removeChildren=function(b_a)bc.removeChildren(b_a)\
b_a:listenEvent(\"mouse_scroll\")end,setParent=function(b_a,c_a,...)bc.setParent(b_a,c_a,...)\
dc=c_a;return b_a end,scrollHandler=function(b_a,c_a,d_a,_aa)\
if\
(bc:getBase().scrollHandler(b_a,c_a,d_a,_aa))then b_a:sortChildren()\
for aaa,baa in\
ipairs(b_a:getEvents(\"mouse_scroll\"))do\
if(baa.element.scrollHandler~=nil)then local caa,daa=0,0;if(b_a.getOffset~=nil)then\
caa,daa=b_a:getOffset()end\
if(baa.element.getIgnoreOffset())then caa,daa=0,0 end;if(baa.element.scrollHandler(baa.element,c_a,d_a+caa,_aa+daa))then\
return true end end end;__a(b_a,c_a,d_a,_aa)b_a:clearFocusedChild()return true end end,draw=function(b_a)\
bc.draw(b_a)\
b_a:addDraw(\"scrollableFrame\",function()if(bd)then __a(b_a,0)end end,0)end}a_a.__index=a_a;return setmetatable(a_a,bc)end end\
aa[\"objects\"][\"Scrollbar\"]=function(...)local ab=da(\"tHex\")\
return\
function(bb,cb)\
local db=cb.getObject(\"VisualObject\")(bb,cb)local _c=\"Scrollbar\"db:setZIndex(2)db:setSize(1,8)\
db:setBackground(colors.lightGray,\"\\127\",colors.gray)local ac=\"vertical\"local bc=\" \"local cc=colors.black;local dc=colors.black;local _d=3;local ad=1\
local bd=1;local cd=true\
local function dd()local b_a,c_a=db:getSize()if(cd)then\
bd=math.max((ac==\"vertical\"and c_a or\
b_a- (#bc))- (_d-1),1)end end;dd()\
local function __a(b_a,c_a,d_a,_aa)local aaa,baa=b_a:getAbsolutePosition()\
local caa,daa=b_a:getSize()dd()local _ba=ac==\"vertical\"and daa or caa\
for i=0,_ba do\
if\
\
( (\
ac==\"vertical\"and baa+i==_aa)or(ac==\"horizontal\"and aaa+i==d_a))and(aaa<=d_a)and(aaa+caa>d_a)and(baa<=_aa)and\
(baa+daa>_aa)then ad=math.min(i+1,\
_ba- (#bc+bd-2))\
b_a:scrollbarMoveHandler()b_a:updateDraw()end end end\
local a_a={getType=function(b_a)return _c end,load=function(b_a)db.load(b_a)local c_a=b_a:getParent()\
b_a:listenEvent(\"mouse_click\")b_a:listenEvent(\"mouse_up\")\
b_a:listenEvent(\"mouse_scroll\")b_a:listenEvent(\"mouse_drag\")end,setSymbol=function(b_a,c_a,d_a,_aa)\
bc=c_a:sub(1,1)cc=d_a or cc;dc=_aa or dc;dd()b_a:updateDraw()return b_a end,setSymbolBG=function(b_a,c_a)return b_a:setSymbol(bc,c_a,\
nil)end,setSymbolFG=function(b_a,c_a)return\
b_a:setSymbol(bc,nil,c_a)end,getSymbol=function(b_a)return bc end,getSymbolBG=function(b_a)return cc end,getSymbolFG=function(b_a)return\
dc end,setIndex=function(b_a,c_a)ad=c_a;if(ad<1)then ad=1 end;local d_a,_aa=b_a:getSize()dd()\
b_a:updateDraw()return b_a end,setScrollAmount=function(b_a,c_a)_d=c_a;dd()\
b_a:updateDraw()return b_a end,getScrollAmount=function(b_a)return _d end,getIndex=function(b_a)\
local c_a,d_a=b_a:getSize()return\
_d> (ac==\"vertical\"and d_a or c_a)and\
math.floor(_d/ (\
ac==\"vertical\"and d_a or c_a)*ad)or ad end,setSymbolSize=function(b_a,c_a)bd=\
tonumber(c_a)or 1;cd=c_a~=false and false or true\
dd()b_a:updateDraw()return b_a end,getSymbolSize=function(b_a)return\
bd end,setBarType=function(b_a,c_a)ac=c_a:lower()dd()b_a:updateDraw()return b_a end,getBarType=function(b_a)return\
ac end,mouseHandler=function(b_a,c_a,d_a,_aa,...)if(db.mouseHandler(b_a,c_a,d_a,_aa,...))then\
__a(b_a,c_a,d_a,_aa)return true end;return false end,dragHandler=function(b_a,c_a,d_a,_aa)if\
(db.dragHandler(b_a,c_a,d_a,_aa))then __a(b_a,c_a,d_a,_aa)return true end;return\
false end,setSize=function(b_a,...)\
db.setSize(b_a,...)dd()return b_a end,scrollHandler=function(b_a,c_a,d_a,_aa)\
if(db.scrollHandler(b_a,c_a,d_a,_aa))then\
local aaa,baa=b_a:getSize()dd()ad=ad+c_a;if(ad<1)then ad=1 end\
ad=math.min(ad,\
(ac==\"vertical\"and baa or aaa)- (ac==\"vertical\"and bd-1 or#bc+bd-2))b_a:scrollbarMoveHandler()b_a:updateDraw()end end,onChange=function(b_a,...)\
for c_a,d_a in\
pairs(table.pack(...))do if(type(d_a)==\"function\")then\
b_a:registerEvent(\"scrollbar_moved\",d_a)end end;return b_a end,scrollbarMoveHandler=function(b_a)\
b_a:sendEvent(\"scrollbar_moved\",b_a:getIndex())end,customEventHandler=function(b_a,c_a,...)\
db.customEventHandler(b_a,c_a,...)if(c_a==\"basalt_FrameResize\")then dd()end end,draw=function(b_a)\
db.draw(b_a)\
b_a:addDraw(\"scrollbar\",function()local c_a=b_a:getParent()local d_a,_aa=b_a:getSize()\
local aaa,baa=b_a:getBackground(),b_a:getForeground()\
if(ac==\"horizontal\")then for n=0,_aa-1 do\
b_a:addBlit(ad,1 +n,bc:rep(bd),ab[dc]:rep(#bc*bd),ab[cc]:rep(\
#bc*bd))end elseif(ac==\"vertical\")then\
for n=0,_aa-1 do\
if(ad==n+1)then\
for curIndexOffset=0,math.min(\
bd-1,_aa)do\
b_a:addBlit(1,ad+curIndexOffset,bc:rep(math.max(#bc,d_a)),ab[dc]:rep(math.max(\
#bc,d_a)),ab[cc]:rep(math.max(#bc,d_a)))end end end end end)end}a_a.__index=a_a;return setmetatable(a_a,db)end end\
aa[\"objects\"][\"Thread\"]=function(...)\
return\
function(ab,bb)\
local cb=bb.getObject(\"Object\")(ab,bb)local db=\"Thread\"local _c;local ac;local bc=false;local cc\
local dc={getType=function(_d)return db end,start=function(_d,ad)if(ad==nil)then\
error(\"Function provided to thread is nil\")end;_c=ad;ac=coroutine.create(_c)\
bc=true;cc=nil;local bd,cd=coroutine.resume(ac)cc=cd;if not(bd)then\
if(cd~=\"Terminated\")then error(\
\"Thread Error Occurred - \"..cd)end end\
_d:listenEvent(\"mouse_click\")_d:listenEvent(\"mouse_up\")\
_d:listenEvent(\"mouse_scroll\")_d:listenEvent(\"mouse_drag\")_d:listenEvent(\"key\")\
_d:listenEvent(\"key_up\")_d:listenEvent(\"char\")\
_d:listenEvent(\"other_event\")return _d end,getStatus=function(_d,ad)if(\
ac~=nil)then return coroutine.status(ac)end;return nil end,stop=function(_d,ad)\
bc=false;_d:listenEvent(\"mouse_click\",false)\
_d:listenEvent(\"mouse_up\",false)_d:listenEvent(\"mouse_scroll\",false)\
_d:listenEvent(\"mouse_drag\",false)_d:listenEvent(\"key\",false)\
_d:listenEvent(\"key_up\",false)_d:listenEvent(\"char\",false)\
_d:listenEvent(\"other_event\",false)return _d end,mouseHandler=function(_d,...)\
_d:eventHandler(\"mouse_click\",...)end,mouseUpHandler=function(_d,...)_d:eventHandler(\"mouse_up\",...)end,mouseScrollHandler=function(_d,...)\
_d:eventHandler(\"mouse_scroll\",...)end,mouseDragHandler=function(_d,...)\
_d:eventHandler(\"mouse_drag\",...)end,mouseMoveHandler=function(_d,...)\
_d:eventHandler(\"mouse_move\",...)end,keyHandler=function(_d,...)_d:eventHandler(\"key\",...)end,keyUpHandler=function(_d,...)\
_d:eventHandler(\"key_up\",...)end,charHandler=function(_d,...)_d:eventHandler(\"char\",...)end,eventHandler=function(_d,ad,...)\
cb.eventHandler(_d,ad,...)\
if(bc)then\
if(coroutine.status(ac)==\"suspended\")then if(cc~=nil)then\
if(ad~=cc)then return end;cc=nil end\
local bd,cd=coroutine.resume(ac,ad,...)cc=cd;if not(bd)then if(cd~=\"Terminated\")then\
error(\"Thread Error Occurred - \"..cd)end end else\
_d:stop()end end end}dc.__index=dc;return setmetatable(dc,cb)end end\
aa[\"objects\"][\"Object\"]=function(...)local ab=da(\"basaltEvent\")\
local bb=da(\"utils\")local cb=bb.uuid;local db,_c=table.unpack,string.sub\
return\
function(ac,bc)ac=ac or cb()\
assert(bc~=nil,\
\"Unable to find basalt instance! ID: \"..ac)local cc=\"Object\"local dc,_d=true,false;local ad=ab()local bd={}local cd={}local dd\
local __a={init=function(a_a)\
if(_d)then return false end;_d=true;return true end,load=function(a_a)end,getType=function(a_a)return cc end,isType=function(a_a,b_a)return cc==\
b_a end,getProperty=function(a_a,b_a)\
local c_a=a_a[\"get\"..b_a:gsub(\"^%l\",string.upper)]if(c_a~=nil)then return c_a(a_a)end end,setProperty=function(a_a,b_a,...)\
local c_a=a_a[\
\"set\"..b_a:gsub(\"^%l\",string.upper)]if(c_a~=nil)then return c_a(a_a,...)end end,getName=function(a_a)return\
ac end,getParent=function(a_a)return dd end,setParent=function(a_a,b_a,c_a)if(c_a)then dd=b_a;return a_a end\
if(b_a.getType~=\
nil and b_a:isType(\"Container\"))then a_a:remove()\
b_a:addChild(a_a)if(a_a.show)then a_a:show()end;dd=b_a end;return a_a end,updateEvents=function(a_a)for b_a,c_a in\
pairs(cd)do dd:removeEvent(b_a,a_a)\
if(c_a)then dd:addEvent(b_a,a_a)end end;return a_a end,listenEvent=function(a_a,b_a,c_a)if(\
dd~=nil)then\
if(c_a)or(c_a==nil)then cd[b_a]=true;dd:addEvent(b_a,a_a)elseif\
(c_a==false)then cd[b_a]=false;dd:removeEvent(b_a,a_a)end end\
return a_a end,getZIndex=function(a_a)return\
1 end,enable=function(a_a)dc=true;return a_a end,disable=function(a_a)dc=false;return a_a end,isEnabled=function(a_a)return\
dc end,remove=function(a_a)if(dd~=nil)then dd:removeChild(a_a)end\
a_a:updateDraw()return a_a end,getBaseFrame=function(a_a)if(dd~=nil)then\
return dd:getBaseFrame()end;return a_a end,onEvent=function(a_a,...)\
for b_a,c_a in\
pairs(table.pack(...))do if(type(c_a)==\"function\")then\
a_a:registerEvent(\"other_event\",c_a)end end;return a_a end,getEventSystem=function(a_a)return\
ad end,getRegisteredEvents=function(a_a)return bd end,registerEvent=function(a_a,b_a,c_a)\
if(dd~=nil)then\
if(b_a==\"mouse_drag\")then\
dd:addEvent(\"mouse_click\",a_a)dd:addEvent(\"mouse_up\",a_a)end;dd:addEvent(b_a,a_a)end;ad:registerEvent(b_a,c_a)\
if(bd[b_a]==nil)then bd[b_a]={}end;table.insert(bd[b_a],c_a)end,removeEvent=function(a_a,b_a,c_a)if(\
ad:getEventCount(b_a)<1)then\
if(dd~=nil)then dd:removeEvent(b_a,a_a)end end;ad:removeEvent(b_a,c_a)if(\
bd[b_a]~=nil)then table.remove(bd[b_a],c_a)if(#bd[b_a]==0)then\
bd[b_a]=nil end end end,eventHandler=function(a_a,b_a,...)\
local c_a=a_a:sendEvent(\"other_event\",b_a,...)if(c_a~=nil)then return c_a end end,customEventHandler=function(a_a,b_a,...)\
local c_a=a_a:sendEvent(\"custom_event\",b_a,...)if(c_a~=nil)then return c_a end;return true end,sendEvent=function(a_a,b_a,...)if(\
b_a==\"other_event\")or(b_a==\"custom_event\")then return\
ad:sendEvent(b_a,a_a,...)end;return\
ad:sendEvent(b_a,a_a,b_a,...)end,onClick=function(a_a,...)\
for b_a,c_a in\
pairs(table.pack(...))do if(type(c_a)==\"function\")then\
a_a:registerEvent(\"mouse_click\",c_a)end end;return a_a end,onClickUp=function(a_a,...)for b_a,c_a in\
pairs(table.pack(...))do\
if(type(c_a)==\"function\")then a_a:registerEvent(\"mouse_up\",c_a)end end;return a_a end,onRelease=function(a_a,...)\
for b_a,c_a in\
pairs(table.pack(...))do if(type(c_a)==\"function\")then\
a_a:registerEvent(\"mouse_release\",c_a)end end;return a_a end,onScroll=function(a_a,...)\
for b_a,c_a in\
pairs(table.pack(...))do if(type(c_a)==\"function\")then\
a_a:registerEvent(\"mouse_scroll\",c_a)end end;return a_a end,onHover=function(a_a,...)\
for b_a,c_a in\
pairs(table.pack(...))do if(type(c_a)==\"function\")then\
a_a:registerEvent(\"mouse_hover\",c_a)end end;return a_a end,onLeave=function(a_a,...)\
for b_a,c_a in\
pairs(table.pack(...))do if(type(c_a)==\"function\")then\
a_a:registerEvent(\"mouse_leave\",c_a)end end;return a_a end,onDrag=function(a_a,...)\
for b_a,c_a in\
pairs(table.pack(...))do if(type(c_a)==\"function\")then\
a_a:registerEvent(\"mouse_drag\",c_a)end end;return a_a end,onKey=function(a_a,...)for b_a,c_a in\
pairs(table.pack(...))do\
if(type(c_a)==\"function\")then a_a:registerEvent(\"key\",c_a)end end;return a_a end,onChar=function(a_a,...)for b_a,c_a in\
pairs(table.pack(...))do\
if(type(c_a)==\"function\")then a_a:registerEvent(\"char\",c_a)end end;return a_a end,onKeyUp=function(a_a,...)for b_a,c_a in\
pairs(table.pack(...))do\
if(type(c_a)==\"function\")then a_a:registerEvent(\"key_up\",c_a)end end;return a_a end}__a.__index=__a;return __a end end\
aa[\"objects\"][\"MonitorFrame\"]=function(...)local ab=da(\"basaltMon\")\
local bb,cb,db,_c=math.max,math.min,string.sub,string.rep\
return\
function(ac,bc)local cc=bc.getObject(\"BaseFrame\")(ac,bc)\
local dc=\"MonitorFrame\"cc:setTerm(nil)local _d=false;local ad\
local bd={getType=function()return dc end,isType=function(cd,dd)\
return dc==dd or cc.isType~=nil and\
cc.isType(dd)or false end,getBase=function(cd)return cc end,setMonitor=function(cd,dd)\
if\
(type(dd)==\"string\")then local __a=peripheral.wrap(dd)\
if(__a~=nil)then cd:setTerm(__a)end elseif(type(dd)==\"table\")then cd:setTerm(dd)end;return cd end,setMonitorGroup=function(cd,dd)\
ad=ab(dd)cd:setTerm(ad)_d=true;return cd end,render=function(cd)if(cd:getTerm()~=\
nil)then cc.render(cd)end end,show=function(cd)\
cc:getBase().show(cd)bc.setActiveFrame(cd)\
for dd,__a in pairs(colors)do if(type(__a)==\"number\")then\
termObject.setPaletteColor(__a,colors.packRGB(term.nativePaletteColor((__a))))end end\
for dd,__a in pairs(colorTheme)do\
if(type(__a)==\"number\")then\
termObject.setPaletteColor(\
type(dd)==\"number\"and dd or colors[dd],__a)else local a_a,b_a,c_a=table.unpack(__a)\
termObject.setPaletteColor(\
type(dd)==\"number\"and dd or colors[dd],a_a,b_a,c_a)end end;return cd end}\
bd.mouseHandler=function(cd,dd,__a,a_a,b_a,c_a,...)\
if(_d)then __a,a_a=ad.calculateClick(c_a,__a,a_a)end;cc.mouseHandler(cd,dd,__a,a_a,b_a,c_a,...)end;bd.__index=bd;return setmetatable(bd,cc)end end\
aa[\"objects\"][\"Switch\"]=function(...)\
return\
function(ab,bb)\
local cb=bb.getObject(\"ChangeableObject\")(ab,bb)local db=\"Switch\"cb:setSize(4,1)cb:setValue(false)\
cb:setZIndex(5)local _c=colors.black;local ac=colors.red;local bc=colors.green\
local cc={getType=function(dc)return db end,setSymbol=function(dc,_d)\
_c=_d;return dc end,getSymbol=function(dc)return _c end,setActiveBackground=function(dc,_d)bc=_d;return dc end,getActiveBackground=function(dc)return bc end,setInactiveBackground=function(dc,_d)\
ac=_d;return dc end,getInactiveBackground=function(dc)return ac end,load=function(dc)\
dc:listenEvent(\"mouse_click\")end,mouseHandler=function(dc,...)\
if(cb.mouseHandler(dc,...))then\
dc:setValue(not dc:getValue())dc:updateDraw()return true end end,draw=function(dc)cb.draw(dc)\
dc:addDraw(\"switch\",function()\
local _d=dc:getParent()local ad,bd=dc:getBackground(),dc:getForeground()\
local cd,dd=dc:getSize()\
if(dc:getValue())then dc:addBackgroundBox(1,1,cd,dd,bc)\
dc:addBackgroundBox(cd,1,1,dd,_c)else dc:addBackgroundBox(1,1,cd,dd,ac)\
dc:addBackgroundBox(1,1,1,dd,_c)end end)end}cc.__index=cc;return setmetatable(cc,cb)end end\
aa[\"objects\"][\"Treeview\"]=function(...)local ab=da(\"utils\")local bb=da(\"tHex\")\
return\
function(cb,db)\
local _c=db.getObject(\"ChangeableObject\")(cb,db)local ac=\"Treeview\"local bc={}local cc=colors.black;local dc=colors.lightGray;local _d=true\
local ad=\"left\"local bd,cd=0,0;local dd=true;_c:setSize(16,8)_c:setZIndex(5)\
local function __a(c_a,d_a)\
c_a=c_a or\"\"d_a=d_a or false;local _aa=false;local aaa=nil;local baa={}local caa={}local daa\
caa={getChildren=function(_ba)return baa end,setParent=function(_ba,aba)if(\
aaa~=nil)then\
aaa.removeChild(aaa.findChildrenByText(caa.getText()))end;aaa=aba;_c:updateDraw()return caa end,getParent=function(_ba)return\
aaa end,addChild=function(_ba,aba,bba)local cba=__a(aba,bba)cba.setParent(caa)\
table.insert(baa,cba)_c:updateDraw()return cba end,setExpanded=function(_ba,aba)if\
(d_a)then _aa=aba end;_c:updateDraw()return caa end,isExpanded=function(_ba)return\
_aa end,onSelect=function(_ba,...)for aba,bba in pairs(table.pack(...))do if(type(bba)==\"function\")then\
daa=bba end end;return caa end,callOnSelect=function(_ba)if(\
daa~=nil)then daa(caa)end end,setExpandable=function(_ba,aba)aba=aba\
_c:updateDraw()return caa end,isExpandable=function(_ba)return d_a end,removeChild=function(_ba,aba)\
if(type(aba)==\"table\")then for bba,cba in\
pairs(aba)do if(cba==aba)then aba=bba;break end end end;table.remove(baa,aba)_c:updateDraw()return caa end,findChildrenByText=function(_ba,aba)\
local bba={}\
for cba,dba in ipairs(baa)do if string.find(dba.getText(),aba)then\
table.insert(bba,dba)end end;return bba end,getText=function(_ba)return\
c_a end,setText=function(_ba,aba)c_a=aba;_c:updateDraw()return caa end}return caa end;local a_a=__a(\"Root\",true)a_a:setExpanded(true)\
local b_a={init=function(c_a)\
local d_a=c_a:getParent()c_a:listenEvent(\"mouse_click\")\
c_a:listenEvent(\"mouse_scroll\")return _c.init(c_a)end,getBase=function(c_a)return\
_c end,getType=function(c_a)return ac end,isType=function(c_a,d_a)\
return ac==d_a or\
_c.isType~=nil and _c.isType(d_a)or false end,setOffset=function(c_a,d_a,_aa)bd=d_a;cd=_aa;return c_a end,setXOffset=function(c_a,d_a)return\
c_a:setOffset(d_a,cd)end,setYOffset=function(c_a,d_a)return c_a:setOffset(bd,d_a)end,getOffset=function(c_a)return\
bd,cd end,getXOffset=function(c_a)return bd end,getYOffset=function(c_a)return cd end,setScrollable=function(c_a,d_a)dd=d_a;return c_a end,getScrollable=function(c_a,d_a)return\
dd end,setSelectionColor=function(c_a,d_a,_aa,aaa)cc=d_a or c_a:getBackground()dc=_aa or\
c_a:getForeground()_d=aaa~=nil and aaa or true\
c_a:updateDraw()return c_a end,setSelectionBG=function(c_a,d_a)return c_a:setSelectionColor(d_a,\
nil,_d)end,setSelectionFG=function(c_a,d_a)return c_a:setSelectionColor(\
nil,d_a,_d)end,getSelectionColor=function(c_a)\
return cc,dc end,getSelectionBG=function(c_a)return cc end,getSelectionFG=function(c_a)return dc end,isSelectionColorActive=function(c_a)return _d end,getRoot=function(c_a)\
return a_a end,setRoot=function(c_a,d_a)a_a=d_a;d_a.setParent(nil)return c_a end,onSelect=function(c_a,...)\
for d_a,_aa in\
pairs(table.pack(...))do if(type(_aa)==\"function\")then\
c_a:registerEvent(\"treeview_select\",_aa)end end;return c_a end,selectionHandler=function(c_a,d_a)\
d_a.callOnSelect(d_a)c_a:sendEvent(\"treeview_select\",d_a)return c_a end,mouseHandler=function(c_a,d_a,_aa,aaa)\
if\
_c.mouseHandler(c_a,d_a,_aa,aaa)then local baa=1 -cd;local caa,daa=c_a:getAbsolutePosition()\
local _ba,aba=c_a:getSize()\
local function bba(cba,dba)\
if aaa==daa+baa-1 then\
if _aa>=caa and _aa<caa+_ba then cba:setExpanded(not\
cba:isExpanded())\
c_a:selectionHandler(cba)c_a:setValue(cba)c_a:updateDraw()return true end end;baa=baa+1\
if cba:isExpanded()then for _ca,aca in ipairs(cba:getChildren())do if bba(aca,dba+1)then return\
true end end end;return false end\
for cba,dba in ipairs(a_a:getChildren())do if bba(dba,1)then return true end end end end,scrollHandler=function(c_a,d_a,_aa,aaa)\
if\
_c.scrollHandler(c_a,d_a,_aa,aaa)then\
if dd then local baa,caa=c_a:getSize()cd=cd+d_a;if cd<0 then cd=0 end\
if d_a>=1 then local daa=0\
local function _ba(aba,bba)\
daa=daa+1;if aba:isExpanded()then\
for cba,dba in ipairs(aba:getChildren())do _ba(dba,bba+1)end end end;for aba,bba in ipairs(a_a:getChildren())do _ba(bba,1)end\
if\
daa>caa then if cd>daa-caa then cd=daa-caa end else cd=cd-1 end end;c_a:updateDraw()end;return true end;return false end,draw=function(c_a)\
_c.draw(c_a)\
c_a:addDraw(\"treeview\",function()local d_a=1 -cd;local _aa=c_a:getValue()\
local function aaa(baa,caa)\
local daa,_ba=c_a:getSize()\
if d_a>=1 and d_a<=_ba then\
local aba=(baa==_aa)and cc or c_a:getBackground()\
local bba=(baa==_aa)and dc or c_a:getForeground()local cba=baa.getText()\
c_a:addBlit(1 +caa+bd,d_a,cba,bb[bba]:rep(#cba),bb[aba]:rep(\
#cba))end;d_a=d_a+1;if baa:isExpanded()then for aba,bba in ipairs(baa:getChildren())do\
aaa(bba,caa+1)end end end;for baa,caa in ipairs(a_a:getChildren())do aaa(caa,1)end end)end}b_a.__index=b_a;return setmetatable(b_a,_c)end end\
aa[\"objects\"][\"Timer\"]=function(...)\
return\
function(ab,bb)\
local cb=bb.getObject(\"Object\")(ab,bb)local db=\"Timer\"local _c=0;local ac=0;local bc=0;local cc;local dc=false\
local _d={getType=function(ad)return db end,setTime=function(ad,bd,cd)_c=bd or 0\
ac=cd or 1;return ad end,getTime=function(ad)return _c end,start=function(ad)if(dc)then\
os.cancelTimer(cc)end;bc=ac;cc=os.startTimer(_c)dc=true\
ad:listenEvent(\"other_event\")return ad end,isActive=function(ad)return dc end,cancel=function(ad)if(\
cc~=nil)then os.cancelTimer(cc)end;dc=false\
ad:removeEvent(\"other_event\")return ad end,setStart=function(ad,bd)if(bd==true)then\
return ad:start()else return ad:cancel()end end,onCall=function(ad,bd)\
ad:registerEvent(\"timed_event\",bd)return ad end,eventHandler=function(ad,bd,...)cb.eventHandler(ad,bd,...)\
if\
bd==\"timer\"and tObj==cc and dc then\
ad:sendEvent(\"timed_event\")if(bc>=1)then bc=bc-1;if(bc>=1)then cc=os.startTimer(_c)end elseif(bc==-1)then\
cc=os.startTimer(_c)end end end}_d.__index=_d;return setmetatable(_d,cb)end end\
aa[\"objects\"][\"Program\"]=function(...)local ab=da(\"tHex\")local bb=da(\"process\")\
local cb=string.sub\
return\
function(db,_c)local ac=_c.getObject(\"VisualObject\")(db,_c)\
local bc=\"Program\"local cc;local dc;local _d={}\
local function ad(_aa,aaa,baa,caa)local daa,_ba=1,1;local aba,bba=colors.black,colors.white;local cba=false\
local dba=false;local _ca={}local aca={}local bca={}local cca={}local dca;local _da={}for i=0,15 do local cab=2 ^i\
cca[cab]={_c.getTerm().getPaletteColour(cab)}end;local function ada()dca=(\" \"):rep(baa)\
for n=0,15 do\
local cab=2 ^n;local dab=ab[cab]_da[cab]=dab:rep(baa)end end\
local function bda()ada()local cab=dca\
local dab=_da[colors.white]local _bb=_da[colors.black]\
for n=1,caa do\
_ca[n]=cb(_ca[n]==nil and cab or _ca[n]..cab:sub(1,\
baa-_ca[n]:len()),1,baa)\
bca[n]=cb(bca[n]==nil and dab or bca[n]..\
dab:sub(1,baa-bca[n]:len()),1,baa)\
aca[n]=cb(aca[n]==nil and _bb or aca[n]..\
_bb:sub(1,baa-aca[n]:len()),1,baa)end;ac.updateDraw(ac)end;bda()local function cda()if\
daa>=1 and _ba>=1 and daa<=baa and _ba<=caa then else end end\
local function dda(cab,dab,_bb)if\
\
_ba<1 or _ba>caa or daa<1 or daa+#cab-1 >baa then return end\
_ca[_ba]=cb(_ca[_ba],1,daa-1)..cab..cb(_ca[_ba],\
daa+#cab,baa)bca[_ba]=cb(bca[_ba],1,daa-1)..\
dab..cb(bca[_ba],daa+#cab,baa)\
aca[_ba]=\
cb(aca[_ba],1,daa-1).._bb..cb(aca[_ba],daa+#cab,baa)daa=daa+#cab;if dba then cda()end;cc:updateDraw()end\
local function __b(cab,dab,_bb)\
if(_bb~=nil)then local abb=_ca[dab]if(abb~=nil)then\
_ca[dab]=cb(abb:sub(1,cab-1).._bb..abb:sub(cab+\
(_bb:len()),baa),1,baa)end end;cc:updateDraw()end\
local function a_b(cab,dab,_bb)\
if(_bb~=nil)then local abb=aca[dab]if(abb~=nil)then\
aca[dab]=cb(abb:sub(1,cab-1).._bb..abb:sub(cab+\
(_bb:len()),baa),1,baa)end end;cc:updateDraw()end\
local function b_b(cab,dab,_bb)\
if(_bb~=nil)then local abb=bca[dab]if(abb~=nil)then\
bca[dab]=cb(abb:sub(1,cab-1).._bb..abb:sub(cab+\
(_bb:len()),baa),1,baa)end end;cc:updateDraw()end\
local c_b=function(cab)\
if type(cab)~=\"number\"then\
error(\"bad argument #1 (expected number, got \"..type(cab)..\")\",2)elseif ab[cab]==nil then\
error(\"Invalid color (got \"..cab..\")\",2)end;bba=cab end\
local d_b=function(cab)\
if type(cab)~=\"number\"then\
error(\"bad argument #1 (expected number, got \"..type(cab)..\")\",2)elseif ab[cab]==nil then\
error(\"Invalid color (got \"..cab..\")\",2)end;aba=cab end\
local _ab=function(cab,dab,_bb,abb)if type(cab)~=\"number\"then\
error(\"bad argument #1 (expected number, got \"..type(cab)..\")\",2)end\
if ab[cab]==nil then error(\"Invalid color (got \"..\
cab..\")\",2)end;local bbb\
if\
type(dab)==\"number\"and _bb==nil and abb==nil then bbb={colours.rgb8(dab)}cca[cab]=bbb else if\
type(dab)~=\"number\"then\
error(\"bad argument #2 (expected number, got \"..type(dab)..\")\",2)end;if type(_bb)~=\"number\"then\
error(\
\"bad argument #3 (expected number, got \"..type(_bb)..\")\",2)end;if type(abb)~=\"number\"then\
error(\
\"bad argument #4 (expected number, got \"..type(abb)..\")\",2)end;bbb=cca[cab]bbb[1]=dab\
bbb[2]=_bb;bbb[3]=abb end end\
local aab=function(cab)if type(cab)~=\"number\"then\
error(\"bad argument #1 (expected number, got \"..type(cab)..\")\",2)end\
if ab[cab]==nil then error(\"Invalid color (got \"..\
cab..\")\",2)end;local dab=cca[cab]return dab[1],dab[2],dab[3]end\
local bab={setCursorPos=function(cab,dab)if type(cab)~=\"number\"then\
error(\"bad argument #1 (expected number, got \"..type(cab)..\")\",2)end;if type(dab)~=\"number\"then\
error(\
\"bad argument #2 (expected number, got \"..type(dab)..\")\",2)end;daa=math.floor(cab)\
_ba=math.floor(dab)if(dba)then cda()end end,getCursorPos=function()return\
daa,_ba end,setCursorBlink=function(cab)if type(cab)~=\"boolean\"then\
error(\"bad argument #1 (expected boolean, got \"..\
type(cab)..\")\",2)end;cba=cab end,getCursorBlink=function()return\
cba end,getPaletteColor=aab,getPaletteColour=aab,setBackgroundColor=d_b,setBackgroundColour=d_b,setTextColor=c_b,setTextColour=c_b,setPaletteColor=_ab,setPaletteColour=_ab,getBackgroundColor=function()return aba end,getBackgroundColour=function()return aba end,getSize=function()\
return baa,caa end,getTextColor=function()return bba end,getTextColour=function()return bba end,basalt_resize=function(cab,dab)baa,caa=cab,dab;bda()end,basalt_reposition=function(cab,dab)\
_aa,aaa=cab,dab end,basalt_setVisible=function(cab)dba=cab end,drawBackgroundBox=function(cab,dab,_bb,abb,bbb)for n=1,abb do\
a_b(cab,dab+ (n-1),ab[bbb]:rep(_bb))end end,drawForegroundBox=function(cab,dab,_bb,abb,bbb)\
for n=1,abb do b_b(cab,\
dab+ (n-1),ab[bbb]:rep(_bb))end end,drawTextBox=function(cab,dab,_bb,abb,bbb)for n=1,abb do\
__b(cab,dab+ (n-1),bbb:rep(_bb))end end,basalt_update=function()for n=1,caa do\
cc:addBlit(1,n,_ca[n],bca[n],aca[n])end end,scroll=function(cab)\
assert(type(cab)==\
\"number\",\"bad argument #1 (expected number, got \"..type(cab)..\")\")\
if cab~=0 then\
for newY=1,caa do local dab=newY+cab;if dab<1 or dab>caa then _ca[newY]=dca\
bca[newY]=_da[bba]aca[newY]=_da[aba]else _ca[newY]=_ca[dab]aca[newY]=aca[dab]\
bca[newY]=bca[dab]end end end;if(dba)then cda()end end,isColor=function()return\
_c.getTerm().isColor()end,isColour=function()\
return _c.getTerm().isColor()end,write=function(cab)cab=tostring(cab)if(dba)then\
dda(cab,ab[bba]:rep(cab:len()),ab[aba]:rep(cab:len()))end end,clearLine=function()\
if\
(dba)then __b(1,_ba,(\" \"):rep(baa))\
a_b(1,_ba,ab[aba]:rep(baa))b_b(1,_ba,ab[bba]:rep(baa))end;if(dba)then cda()end end,clear=function()\
for n=1,caa\
do __b(1,n,(\" \"):rep(baa))\
a_b(1,n,ab[aba]:rep(baa))b_b(1,n,ab[bba]:rep(baa))end;if(dba)then cda()end end,blit=function(cab,dab,_bb)if\
type(cab)~=\"string\"then\
error(\"bad argument #1 (expected string, got \"..type(cab)..\")\",2)end;if type(dab)~=\"string\"then\
error(\
\"bad argument #2 (expected string, got \"..type(dab)..\")\",2)end;if type(_bb)~=\"string\"then\
error(\
\"bad argument #3 (expected string, got \"..type(_bb)..\")\",2)end\
if\
#dab~=#cab or#_bb~=#cab then error(\"Arguments must be the same length\",2)end;if(dba)then dda(cab,dab,_bb)end end}return bab end;ac:setZIndex(5)ac:setSize(30,12)local bd=ad(1,1,30,12)local cd\
local dd=false;local __a={}\
local function a_a(_aa)local aaa=_aa:getParent()local baa,caa=bd.getCursorPos()\
local daa,_ba=_aa:getPosition()local aba,bba=_aa:getSize()\
if(daa+baa-1 >=1 and\
daa+baa-1 <=daa+aba-1 and caa+_ba-1 >=1 and\
caa+_ba-1 <=_ba+bba-1)then\
aaa:setCursor(\
_aa:isFocused()and bd.getCursorBlink(),daa+baa-1,caa+_ba-1,bd.getTextColor())end end\
local function b_a(_aa,aaa,...)local baa,caa=cd:resume(aaa,...)\
if(baa==false)and(caa~=nil)and\
(caa~=\"Terminated\")then\
local daa=_aa:sendEvent(\"program_error\",caa)\
if(daa~=false)then error(\"Basalt Program - \"..caa)end end\
if(cd:getStatus()==\"dead\")then _aa:sendEvent(\"program_done\")end end\
local function c_a(_aa,aaa,baa,caa,daa)if(cd==nil)then return false end\
if not(cd:isDead())then if not(dd)then\
local _ba,aba=_aa:getAbsolutePosition()b_a(_aa,aaa,baa,caa-_ba+1,daa-aba+1)\
a_a(_aa)end end end\
local function d_a(_aa,aaa,baa,caa)if(cd==nil)then return false end\
if not(cd:isDead())then if not(dd)then if(_aa.draw)then\
b_a(_aa,aaa,baa,caa)a_a(_aa)end end end end\
cc={getType=function(_aa)return bc end,show=function(_aa)ac.show(_aa)\
bd.setBackgroundColor(_aa:getBackground())bd.setTextColor(_aa:getForeground())\
bd.basalt_setVisible(true)return _aa end,hide=function(_aa)\
ac.hide(_aa)bd.basalt_setVisible(false)return _aa end,setPosition=function(_aa,aaa,baa,caa)\
ac.setPosition(_aa,aaa,baa,caa)bd.basalt_reposition(_aa:getPosition())return _aa end,getBasaltWindow=function()return\
bd end,getBasaltProcess=function()return cd end,setSize=function(_aa,aaa,baa,caa)ac.setSize(_aa,aaa,baa,caa)\
bd.basalt_resize(_aa:getWidth(),_aa:getHeight())return _aa end,getStatus=function(_aa)if(cd~=nil)then return\
cd:getStatus()end;return\"inactive\"end,setEnviroment=function(_aa,aaa)_d=\
aaa or{}return _aa end,execute=function(_aa,aaa,...)dc=aaa or dc\
cd=bb:new(dc,bd,_d,...)bd.setBackgroundColor(colors.black)\
bd.setTextColor(colors.white)bd.clear()bd.setCursorPos(1,1)\
bd.setBackgroundColor(_aa:getBackground())\
bd.setTextColor(_aa:getForeground()or colors.white)bd.basalt_setVisible(true)b_a(_aa)dd=false\
_aa:listenEvent(\"mouse_click\",_aa)_aa:listenEvent(\"mouse_up\",_aa)\
_aa:listenEvent(\"mouse_drag\",_aa)_aa:listenEvent(\"mouse_scroll\",_aa)\
_aa:listenEvent(\"key\",_aa)_aa:listenEvent(\"key_up\",_aa)\
_aa:listenEvent(\"char\",_aa)_aa:listenEvent(\"other_event\",_aa)return _aa end,setExecute=function(_aa,aaa,...)return\
_aa:execute(aaa,...)end,stop=function(_aa)local aaa=_aa:getParent()\
if(cd~=nil)then if not\
(cd:isDead())then b_a(_aa,\"terminate\")if(cd:isDead())then\
aaa:setCursor(false)end end end;aaa:removeEvents(_aa)return _aa end,pause=function(_aa,aaa)dd=\
aaa or(not dd)if(cd~=nil)then\
if not(cd:isDead())then if not(dd)then\
_aa:injectEvents(table.unpack(__a))__a={}end end end;return _aa end,isPaused=function(_aa)return\
dd end,injectEvent=function(_aa,aaa,baa,...)\
if(cd~=nil)then if not(cd:isDead())then\
if(dd==false)or(baa)then\
b_a(_aa,aaa,...)else table.insert(__a,{event=aaa,args={...}})end end end;return _aa end,getQueuedEvents=function(_aa)return\
__a end,updateQueuedEvents=function(_aa,aaa)__a=aaa or __a;return _aa end,injectEvents=function(_aa,...)if(cd~=nil)then\
if not\
(cd:isDead())then for aaa,baa in pairs({...})do\
b_a(_aa,baa.event,table.unpack(baa.args))end end end;return _aa end,mouseHandler=function(_aa,aaa,baa,caa)\
if\
(ac.mouseHandler(_aa,aaa,baa,caa))then c_a(_aa,\"mouse_click\",aaa,baa,caa)return true end;return false end,mouseUpHandler=function(_aa,aaa,baa,caa)\
if\
(ac.mouseUpHandler(_aa,aaa,baa,caa))then c_a(_aa,\"mouse_up\",aaa,baa,caa)return true end;return false end,scrollHandler=function(_aa,aaa,baa,caa)\
if\
(ac.scrollHandler(_aa,aaa,baa,caa))then c_a(_aa,\"mouse_scroll\",aaa,baa,caa)return true end;return false end,dragHandler=function(_aa,aaa,baa,caa)\
if\
(ac.dragHandler(_aa,aaa,baa,caa))then c_a(_aa,\"mouse_drag\",aaa,baa,caa)return true end;return false end,keyHandler=function(_aa,aaa,baa)if\
(ac.keyHandler(_aa,aaa,baa))then d_a(_aa,\"key\",aaa,baa)return true end;return\
false end,keyUpHandler=function(_aa,aaa)if\
(ac.keyUpHandler(_aa,aaa))then d_a(_aa,\"key_up\",aaa)return true end\
return false end,charHandler=function(_aa,aaa)if\
(ac.charHandler(_aa,aaa))then d_a(_aa,\"char\",aaa)return true end\
return false end,getFocusHandler=function(_aa)\
ac.getFocusHandler(_aa)\
if(cd~=nil)then\
if not(cd:isDead())then\
if not(dd)then local aaa=_aa:getParent()\
if(aaa~=nil)then\
local baa,caa=bd.getCursorPos()local daa,_ba=_aa:getPosition()local aba,bba=_aa:getSize()\
if\
(\
\
daa+baa-1 >=1 and daa+baa-1 <=daa+aba-1 and caa+_ba-1 >=1 and caa+_ba-1 <=_ba+bba-1)then\
aaa:setCursor(bd.getCursorBlink(),daa+baa-1,caa+_ba-1,bd.getTextColor())end end end end end end,loseFocusHandler=function(_aa)\
ac.loseFocusHandler(_aa)\
if(cd~=nil)then if not(cd:isDead())then local aaa=_aa:getParent()if(aaa~=nil)then\
aaa:setCursor(false)end end end end,eventHandler=function(_aa,aaa,...)\
ac.eventHandler(_aa,aaa,...)if cd==nil then return end\
if not cd:isDead()then\
if not dd then b_a(_aa,aaa,...)\
if\
_aa:isFocused()then local baa=_aa:getParent()local caa,daa=_aa:getPosition()\
local _ba,aba=bd.getCursorPos()local bba,cba=_aa:getSize()\
if caa+_ba-1 >=1 and\
caa+_ba-1 <=caa+bba-1 and aba+daa-1 >=1 and\
aba+daa-1 <=daa+cba-1 then\
baa:setCursor(bd.getCursorBlink(),\
caa+_ba-1,aba+daa-1,bd.getTextColor())end end else table.insert(__a,{event=aaa,args={...}})end end end,resizeHandler=function(_aa,...)\
ac.resizeHandler(_aa,...)\
if(cd~=nil)then\
if not(cd:isDead())then\
if not(dd)then\
bd.basalt_resize(_aa:getSize())b_a(_aa,\"term_resize\",_aa:getSize())else\
bd.basalt_resize(_aa:getSize())\
table.insert(__a,{event=\"term_resize\",args={_aa:getSize()}})end end end end,repositionHandler=function(_aa,...)\
ac.repositionHandler(_aa,...)\
if(cd~=nil)then if not(cd:isDead())then\
bd.basalt_reposition(_aa:getPosition())end end end,draw=function(_aa)\
ac.draw(_aa)\
_aa:addDraw(\"program\",function()local aaa=_aa:getParent()local baa,caa=_aa:getPosition()\
local daa,_ba=bd.getCursorPos()local aba,bba=_aa:getSize()bd.basalt_update()end)end,onError=function(_aa,...)\
for baa,caa in\
pairs(table.pack(...))do if(type(caa)==\"function\")then\
_aa:registerEvent(\"program_error\",caa)end end;local aaa=_aa:getParent()_aa:listenEvent(\"other_event\")\
return _aa end,onDone=function(_aa,...)\
for baa,caa in\
pairs(table.pack(...))do if(type(caa)==\"function\")then\
_aa:registerEvent(\"program_done\",caa)end end;local aaa=_aa:getParent()_aa:listenEvent(\"other_event\")\
return _aa end}cc.__index=cc;return setmetatable(cc,ac)end end\
aa[\"objects\"][\"Progressbar\"]=function(...)\
return\
function(ab,bb)\
local cb=bb.getObject(\"ChangeableObject\")(ab,bb)local db=\"Progressbar\"local _c=0;cb:setZIndex(5)cb:setValue(false)\
cb:setSize(25,3)local ac=colors.black;local bc=\"\"local cc=colors.white;local dc=\"\"local _d=0\
local ad={getType=function(bd)return db end,setDirection=function(bd,cd)\
_d=cd;bd:updateDraw()return bd end,getDirection=function(bd)return _d end,setProgressBar=function(bd,cd,dd,__a)\
ac=cd or ac;bc=dd or bc;cc=__a or cc;bd:updateDraw()return bd end,getProgressBar=function(bd)return\
ac,bc,cc end,setActiveBarColor=function(bd,cd)return bd:setProgressBar(cd,nil,nil)end,getActiveBarColor=function(bd)return\
ac end,setActiveBarSymbol=function(bd,cd)return bd:setProgressBar(nil,cd,nil)end,getActiveBarSymbol=function(bd)return\
bc end,setActiveBarSymbolColor=function(bd,cd)return bd:setProgressBar(nil,nil,cd)end,getActiveBarSymbolColor=function(bd)return\
cc end,setBackgroundSymbol=function(bd,cd)dc=cd:sub(1,1)bd:updateDraw()return bd end,getBackgroundSymbol=function(bd)return\
dc end,setProgress=function(bd,cd)\
if(cd>=0)and(cd<=100)and(_c~=cd)then _c=cd\
bd:setValue(_c)if(_c==100)then bd:progressDoneHandler()end end;bd:updateDraw()return bd end,getProgress=function(bd)return\
_c end,onProgressDone=function(bd,cd)bd:registerEvent(\"progress_done\",cd)\
return bd end,progressDoneHandler=function(bd)\
bd:sendEvent(\"progress_done\")end,draw=function(bd)cb.draw(bd)\
bd:addDraw(\"progressbar\",function()\
local cd,dd=bd:getPosition()local __a,a_a=bd:getSize()\
local b_a,c_a=bd:getBackground(),bd:getForeground()\
if(b_a~=false)then bd:addBackgroundBox(1,1,__a,a_a,b_a)end;if(dc~=\"\")then bd:addTextBox(1,1,__a,a_a,dc)end\
if\
(c_a~=false)then bd:addForegroundBox(1,1,__a,a_a,c_a)end\
if(_d==1)then bd:addBackgroundBox(1,1,__a,a_a/100 *_c,ac)bd:addForegroundBox(1,1,__a,\
a_a/100 *_c,cc)\
bd:addTextBox(1,1,__a,a_a/100 *_c,bc)elseif(_d==3)then\
bd:addBackgroundBox(1,1 +math.ceil(a_a-a_a/100 *_c),__a,\
a_a/100 *_c,ac)\
bd:addForegroundBox(1,1 +math.ceil(a_a-a_a/100 *_c),__a,\
a_a/100 *_c,cc)\
bd:addTextBox(1,1 +math.ceil(a_a-a_a/100 *_c),__a,a_a/100 *_c,bc)elseif(_d==2)then\
bd:addBackgroundBox(1 +math.ceil(__a-__a/100 *_c),1,__a/\
100 *_c,a_a,ac)\
bd:addForegroundBox(1 +math.ceil(__a-__a/100 *_c),1,__a/100 *_c,a_a,cc)\
bd:addTextBox(1 +math.ceil(__a-__a/100 *_c),1,__a/100 *_c,a_a,bc)else\
bd:addBackgroundBox(1,1,math.ceil(__a/100 *_c),a_a,ac)\
bd:addForegroundBox(1,1,math.ceil(__a/100 *_c),a_a,cc)\
bd:addTextBox(1,1,math.ceil(__a/100 *_c),a_a,bc)end end)end}ad.__index=ad;return setmetatable(ad,cb)end end\
aa[\"objects\"][\"Textfield\"]=function(...)local ab=da(\"tHex\")\
local bb,cb,db,_c,ac=string.rep,string.find,string.gmatch,string.sub,string.len\
return\
function(bc,cc)\
local dc=cc.getObject(\"ChangeableObject\")(bc,cc)local _d=\"Textfield\"local ad,bd,cd,dd=1,1,1,1;local __a={\"\"}local a_a={\"\"}local b_a={\"\"}local c_a={}local d_a={}\
local _aa,aaa,baa,caa;local daa,_ba=colors.lightBlue,colors.black;dc:setSize(30,12)\
dc:setZIndex(5)\
local function aba()if\
(_aa~=nil)and(aaa~=nil)and(baa~=nil)and(caa~=nil)then return true end;return false end\
local function bba()local cca,dca,_da,ada=_aa,aaa,baa,caa\
if aba()then\
if _aa<aaa and baa<=caa then cca=_aa;dca=aaa;if baa<caa then\
_da=baa;ada=caa else _da=caa;ada=baa end elseif _aa>aaa and baa>=caa then\
cca=aaa;dca=_aa;if baa>caa then _da=caa;ada=baa else _da=baa;ada=caa end elseif baa>caa then\
cca=aaa;dca=_aa;_da=caa;ada=baa end;return cca,dca,_da,ada end end\
local function cba(cca)local dca,_da,ada,bda=bba()local cda=__a[ada]local dda=__a[bda]__a[ada]=cda:sub(1,dca-1)..dda:sub(\
_da+1,dda:len())\
a_a[ada]=a_a[ada]:sub(1,\
dca-1)..a_a[bda]:sub(_da+1,a_a[bda]:len())b_a[ada]=b_a[ada]:sub(1,dca-1)..\
b_a[bda]:sub(_da+1,b_a[bda]:len())for i=bda,ada+1,-1 do\
if i~=ada then\
table.remove(__a,i)table.remove(a_a,i)table.remove(b_a,i)end end;cd,dd=dca,ada\
_aa,aaa,baa,caa=nil,nil,nil,nil;return cca end\
local function dba(cca,dca)local _da={}\
if(cca:len()>0)then\
for ada in db(cca,dca)do local bda,cda=cb(cca,ada)\
if\
(bda~=nil)and(cda~=nil)then table.insert(_da,bda)table.insert(_da,cda)\
local dda=_c(cca,1,(bda-1))local __b=_c(cca,cda+1,cca:len())cca=dda.. (\":\"):rep(ada:len())..\
__b end end end;return _da end\
local function _ca(cca,dca)dca=dca or dd\
local _da=ab[cca:getForeground()]:rep(b_a[dca]:len())\
local ada=ab[cca:getBackground()]:rep(a_a[dca]:len())\
for bda,cda in pairs(d_a)do local dda=dba(__a[dca],cda[1])\
if(#dda>0)then\
for x=1,#dda/2 do\
local __b=x*2 -1;if(cda[2]~=nil)then\
_da=_da:sub(1,dda[__b]-1)..ab[cda[2]]:rep(dda[__b+1]- (\
dda[__b]-1))..\
_da:sub(dda[__b+1]+1,_da:len())end;if\
(cda[3]~=nil)then\
ada=ada:sub(1,dda[__b]-1)..\
\
ab[cda[3]]:rep(dda[__b+1]- (dda[__b]-1))..ada:sub(dda[__b+1]+1,ada:len())end end end end\
for bda,cda in pairs(c_a)do\
for dda,__b in pairs(cda)do local a_b=dba(__a[dca],__b)\
if(#a_b>0)then for x=1,#a_b/2 do\
local b_b=x*2 -1\
_da=_da:sub(1,a_b[b_b]-1)..\
\
ab[bda]:rep(a_b[b_b+1]- (a_b[b_b]-1)).._da:sub(a_b[b_b+1]+1,_da:len())end end end end;b_a[dca]=_da;a_a[dca]=ada;cca:updateDraw()end;local function aca(cca)for n=1,#__a do _ca(cca,n)end end\
local bca={getType=function(cca)return _d end,setBackground=function(cca,dca)\
dc.setBackground(cca,dca)aca(cca)return cca end,setForeground=function(cca,dca)\
dc.setForeground(cca,dca)aca(cca)return cca end,setSelection=function(cca,dca,_da)_ba=dca or _ba\
daa=_da or daa;return cca end,setSelectionFG=function(cca,dca)\
return cca:setSelection(dca,nil)end,setSelectionBG=function(cca,dca)return cca:setSelection(nil,dca)end,getSelection=function(cca)return\
_ba,daa end,getSelectionFG=function(cca)return _ba end,getSelectionBG=function(cca)return daa end,getLines=function(cca)return __a end,getLine=function(cca,dca)return\
__a[dca]end,editLine=function(cca,dca,_da)__a[dca]=_da or __a[dca]\
_ca(cca,dca)cca:updateDraw()return cca end,clear=function(cca)\
__a={\"\"}a_a={\"\"}b_a={\"\"}_aa,aaa,baa,caa=nil,nil,nil,nil;ad,bd,cd,dd=1,1,1,1\
cca:updateDraw()return cca end,addLine=function(cca,dca,_da)\
if(dca~=nil)then\
local ada=cca:getBackground()local bda=cca:getForeground()\
if(#__a==1)and(__a[1]==\"\")then\
__a[1]=dca;a_a[1]=ab[ada]:rep(dca:len())\
b_a[1]=ab[bda]:rep(dca:len())_ca(cca,1)return cca end\
if(_da~=nil)then table.insert(__a,_da,dca)\
table.insert(a_a,_da,ab[ada]:rep(dca:len()))\
table.insert(b_a,_da,ab[bda]:rep(dca:len()))else table.insert(__a,dca)\
table.insert(a_a,ab[ada]:rep(dca:len()))\
table.insert(b_a,ab[bda]:rep(dca:len()))end end;_ca(cca,_da or#__a)cca:updateDraw()return cca end,addKeywords=function(cca,dca,_da)if(\
c_a[dca]==nil)then c_a[dca]={}end;for ada,bda in pairs(_da)do\
table.insert(c_a[dca],bda)end;cca:updateDraw()return cca end,addRule=function(cca,dca,_da,ada)\
table.insert(d_a,{dca,_da,ada})cca:updateDraw()return cca end,editRule=function(cca,dca,_da,ada)for bda,cda in\
pairs(d_a)do\
if(cda[1]==dca)then d_a[bda][2]=_da;d_a[bda][3]=ada end end;cca:updateDraw()return cca end,removeRule=function(cca,dca)\
for _da,ada in\
pairs(d_a)do if(ada[1]==dca)then table.remove(d_a,_da)end end;cca:updateDraw()return cca end,setKeywords=function(cca,dca,_da)\
c_a[dca]=_da;cca:updateDraw()return cca end,removeLine=function(cca,dca)\
if(#__a>1)then table.remove(__a,\
dca or#__a)\
table.remove(a_a,dca or#a_a)table.remove(b_a,dca or#b_a)else __a={\"\"}a_a={\"\"}b_a={\"\"}end;cca:updateDraw()return cca end,getTextCursor=function(cca)return\
cd,dd end,getOffset=function(cca)return bd,ad end,setOffset=function(cca,dca,_da)bd=dca or bd;ad=_da or ad\
cca:updateDraw()return cca end,getXOffset=function(cca)return bd end,setXOffset=function(cca,dca)return\
cca:setOffset(dca,nil)end,getYOffset=function(cca)return ad end,setYOffset=function(cca,dca)return\
cca:setOffset(nil,dca)end,getFocusHandler=function(cca)dc.getFocusHandler(cca)\
local dca,_da=cca:getPosition()\
cca:getParent():setCursor(true,dca+cd-bd,_da+dd-ad,cca:getForeground())end,loseFocusHandler=function(cca)\
dc.loseFocusHandler(cca)cca:getParent():setCursor(false)end,keyHandler=function(cca,dca)\
if\
(dc.keyHandler(cca,dca))then local _da=cca:getParent()local ada,bda=cca:getPosition()\
local cda,dda=cca:getSize()\
if(dca==keys.backspace)then\
if(aba())then cba(cca)else\
if(__a[dd]==\"\")then\
if(dd>1)then\
table.remove(__a,dd)table.remove(b_a,dd)table.remove(a_a,dd)cd=\
__a[dd-1]:len()+1;bd=cd-cda+1;if(bd<1)then bd=1 end;dd=dd-1 end elseif(cd<=1)then\
if(dd>1)then cd=__a[dd-1]:len()+1;bd=cd-cda+1;if(bd<1)then\
bd=1 end;__a[dd-1]=__a[dd-1]..__a[dd]b_a[dd-1]=\
b_a[dd-1]..b_a[dd]\
a_a[dd-1]=a_a[dd-1]..a_a[dd]table.remove(__a,dd)table.remove(b_a,dd)\
table.remove(a_a,dd)dd=dd-1 end else __a[dd]=__a[dd]:sub(1,cd-2)..\
__a[dd]:sub(cd,__a[dd]:len())\
b_a[dd]=\
b_a[dd]:sub(1,cd-2)..b_a[dd]:sub(cd,b_a[dd]:len())a_a[dd]=a_a[dd]:sub(1,cd-2)..\
a_a[dd]:sub(cd,a_a[dd]:len())\
if(cd>1)then cd=cd-1 end;if(bd>1)then if(cd<bd)then bd=bd-1 end end end;if(dd<ad)then ad=ad-1 end end;_ca(cca)cca:setValue(\"\")elseif(dca==keys.delete)then\
if(aba())then cba(cca)else\
if(cd>\
__a[dd]:len())then if(__a[dd+1]~=nil)then __a[dd]=__a[dd]..__a[dd+1]table.remove(__a,\
dd+1)table.remove(a_a,dd+1)\
table.remove(b_a,dd+1)end else\
__a[dd]=__a[dd]:sub(1,\
cd-1)..__a[dd]:sub(cd+1,__a[dd]:len())b_a[dd]=b_a[dd]:sub(1,cd-1)..\
b_a[dd]:sub(cd+1,b_a[dd]:len())\
a_a[dd]=a_a[dd]:sub(1,\
cd-1)..a_a[dd]:sub(cd+1,a_a[dd]:len())end end;_ca(cca)elseif(dca==keys.enter)then if(aba())then cba(cca)end\
table.insert(__a,dd+1,__a[dd]:sub(cd,__a[dd]:len()))\
table.insert(b_a,dd+1,b_a[dd]:sub(cd,b_a[dd]:len()))\
table.insert(a_a,dd+1,a_a[dd]:sub(cd,a_a[dd]:len()))__a[dd]=__a[dd]:sub(1,cd-1)\
b_a[dd]=b_a[dd]:sub(1,cd-1)a_a[dd]=a_a[dd]:sub(1,cd-1)dd=dd+1;cd=1;bd=1;if(dd-ad>=dda)then\
ad=ad+1 end;cca:setValue(\"\")elseif(dca==keys.up)then\
_aa,baa,aaa,caa=nil,nil,nil,nil\
if(dd>1)then dd=dd-1;if(cd>__a[dd]:len()+1)then\
cd=__a[dd]:len()+1 end;if(bd>1)then\
if(cd<bd)then bd=cd-cda+1;if(bd<1)then bd=1 end end end\
if(ad>1)then if(dd<ad)then ad=ad-1 end end end elseif(dca==keys.down)then _aa,baa,aaa,caa=nil,nil,nil,nil\
if(dd<#__a)then dd=dd+1\
if(cd>\
__a[dd]:len()+1)then cd=__a[dd]:len()+1 end\
if(bd>1)then if(cd<bd)then bd=cd-cda+1;if(bd<1)then bd=1 end end end;if(dd>=ad+dda)then ad=ad+1 end end elseif(dca==keys.right)then _aa,baa,aaa,caa=nil,nil,nil,nil;cd=cd+1\
if(dd<#__a)then if(cd>\
__a[dd]:len()+1)then cd=1;dd=dd+1 end elseif\
(cd>__a[dd]:len())then cd=__a[dd]:len()+1 end;if(cd<1)then cd=1 end\
if(cd<bd)or(cd>=cda+bd)then bd=cd-cda+1 end;if(bd<1)then bd=1 end elseif(dca==keys.left)then _aa,baa,aaa,caa=nil,nil,nil,nil;cd=cd-1\
if(cd>=1)then if(\
cd<bd)or(cd>=cda+bd)then bd=cd end end;if(dd>1)then\
if(cd<1)then dd=dd-1;cd=__a[dd]:len()+1;bd=cd-cda+1 end end;if(cd<1)then cd=1 end;if(bd<1)then bd=1 end elseif(dca==\
keys.tab)then\
if(cd%3 ==0)then\
__a[dd]=__a[dd]:sub(1,cd-1)..\" \"..\
__a[dd]:sub(cd,__a[dd]:len())\
b_a[dd]=b_a[dd]:sub(1,cd-1)..ab[cca:getForeground()]..\
b_a[dd]:sub(cd,b_a[dd]:len())\
a_a[dd]=a_a[dd]:sub(1,cd-1)..ab[cca:getBackground()]..\
a_a[dd]:sub(cd,a_a[dd]:len())cd=cd+1 end\
while cd%3 ~=0 do\
__a[dd]=__a[dd]:sub(1,cd-1)..\" \"..\
__a[dd]:sub(cd,__a[dd]:len())\
b_a[dd]=b_a[dd]:sub(1,cd-1)..ab[cca:getForeground()]..\
b_a[dd]:sub(cd,b_a[dd]:len())\
a_a[dd]=a_a[dd]:sub(1,cd-1)..ab[cca:getBackground()]..\
a_a[dd]:sub(cd,a_a[dd]:len())cd=cd+1 end end\
if not\
( (ada+cd-bd>=ada and ada+cd-bd<ada+cda)and(\
bda+dd-ad>=bda and bda+dd-ad<bda+dda))then bd=math.max(1,\
__a[dd]:len()-cda+1)\
ad=math.max(1,dd-dda+1)end;local __b=\
(cd<=__a[dd]:len()and cd-1 or __a[dd]:len())- (bd-1)\
if(__b>cca:getX()+\
cda-1)then __b=cca:getX()+cda-1 end;local a_b=(dd-ad<dda and dd-ad or dd-ad-1)if\
(__b<1)then __b=0 end\
_da:setCursor(true,ada+__b,bda+a_b,cca:getForeground())cca:updateDraw()return true end end,charHandler=function(cca,dca)\
if\
(dc.charHandler(cca,dca))then local _da=cca:getParent()local ada,bda=cca:getPosition()\
local cda,dda=cca:getSize()if(aba())then cba(cca)end\
__a[dd]=__a[dd]:sub(1,cd-1)..dca..\
__a[dd]:sub(cd,__a[dd]:len())\
b_a[dd]=b_a[dd]:sub(1,cd-1)..ab[cca:getForeground()]..\
b_a[dd]:sub(cd,b_a[dd]:len())\
a_a[dd]=a_a[dd]:sub(1,cd-1)..ab[cca:getBackground()]..\
a_a[dd]:sub(cd,a_a[dd]:len())cd=cd+1;if(cd>=cda+bd)then bd=bd+1 end;_ca(cca)\
cca:setValue(\"\")\
if not\
( (ada+cd-bd>=ada and ada+cd-bd<ada+cda)and(\
bda+dd-ad>=bda and bda+dd-ad<bda+dda))then bd=math.max(1,\
__a[dd]:len()-cda+1)\
ad=math.max(1,dd-dda+1)end;local __b=\
(cd<=__a[dd]:len()and cd-1 or __a[dd]:len())- (bd-1)\
if(__b>cca:getX()+\
cda-1)then __b=cca:getX()+cda-1 end;local a_b=(dd-ad<dda and dd-ad or dd-ad-1)if\
(__b<1)then __b=0 end\
_da:setCursor(true,ada+__b,bda+a_b,cca:getForeground())cca:updateDraw()return true end end,dragHandler=function(cca,dca,_da,ada)\
if\
(dc.dragHandler(cca,dca,_da,ada))then local bda=cca:getParent()local cda,dda=cca:getAbsolutePosition()\
local __b,a_b=cca:getPosition()local b_b,c_b=cca:getSize()\
if(__a[ada-dda+ad]~=nil)then\
if\
(_da-cda+bd>0)and(_da-cda+bd<=b_b)then cd=_da-cda+bd\
dd=ada-dda+ad\
if cd>__a[dd]:len()then cd=__a[dd]:len()+1 end;aaa=cd;caa=dd;if cd<bd then bd=cd-1;if bd<1 then bd=1 end end\
bda:setCursor(not\
aba(),__b+cd-bd,a_b+dd-ad,cca:getForeground())cca:updateDraw()end end;return true end end,scrollHandler=function(cca,dca,_da,ada)\
if\
(dc.scrollHandler(cca,dca,_da,ada))then local bda=cca:getParent()local cda,dda=cca:getAbsolutePosition()\
local __b,a_b=cca:getPosition()local b_b,c_b=cca:getSize()ad=ad+dca;if(ad>#__a- (c_b-1))then\
ad=#__a- (c_b-1)end;if(ad<1)then ad=1 end\
if(cda+cd-bd>=cda and cda+cd-bd<\
cda+b_b)and\
(a_b+dd-ad>=a_b and a_b+dd-ad<a_b+c_b)then\
bda:setCursor(not aba(),__b+cd-bd,a_b+dd-ad,cca:getForeground())else bda:setCursor(false)end;cca:updateDraw()return true end end,mouseHandler=function(cca,dca,_da,ada)\
if\
(dc.mouseHandler(cca,dca,_da,ada))then local bda=cca:getParent()local cda,dda=cca:getAbsolutePosition()\
local __b,a_b=cca:getPosition()\
if(__a[ada-dda+ad]~=nil)then cd=_da-cda+bd;dd=ada-dda+ad;aaa=\
nil;caa=nil;_aa=cd;baa=dd;if(cd>__a[dd]:len())then\
cd=__a[dd]:len()+1;_aa=cd end\
if(cd<bd)then bd=cd-1;if(bd<1)then bd=1 end end;cca:updateDraw()end\
bda:setCursor(true,__b+cd-bd,a_b+dd-ad,cca:getForeground())return true end end,mouseUpHandler=function(cca,dca,_da,ada)\
if\
(dc.mouseUpHandler(cca,dca,_da,ada))then local bda,cda=cca:getAbsolutePosition()\
if\
(__a[ada-cda+ad]~=nil)then aaa=_da-bda+bd;caa=ada-cda+ad;if(aaa>__a[caa]:len())then aaa=\
__a[caa]:len()+1 end;if(_aa==aaa)and(baa==caa)then _aa,aaa,baa,caa=\
nil,nil,nil,nil end\
cca:updateDraw()end;return true end end,eventHandler=function(cca,dca,_da,...)\
dc.eventHandler(cca,dca,_da,...)\
if(dca==\"paste\")then\
if(cca:isFocused())then local ada=cca:getParent()\
local bda,cda=cca:getForeground(),cca:getBackground()local dda,__b=cca:getSize()\
__a[dd]=__a[dd]:sub(1,cd-1).._da..\
__a[dd]:sub(cd,__a[dd]:len())\
b_a[dd]=b_a[dd]:sub(1,cd-1)..ab[bda]:rep(_da:len())..\
b_a[dd]:sub(cd,b_a[dd]:len())\
a_a[dd]=a_a[dd]:sub(1,cd-1)..ab[cda]:rep(_da:len())..\
a_a[dd]:sub(cd,a_a[dd]:len())cd=cd+_da:len()if(cd>=dda+bd)then bd=(cd+1)-dda end\
local a_b,b_b=cca:getPosition()\
ada:setCursor(true,a_b+cd-bd,b_b+dd-ad,bda)_ca(cca)cca:updateDraw()end end end,draw=function(cca)\
dc.draw(cca)\
cca:addDraw(\"textfield\",function()local dca,_da=cca:getSize()\
local ada=ab[cca:getBackground()]local bda=ab[cca:getForeground()]\
for n=1,_da do local cda=\"\"local dda=\"\"local __b=\"\"if __a[\
n+ad-1]then cda=__a[n+ad-1]__b=b_a[n+ad-1]\
dda=a_a[n+ad-1]end;cda=_c(cda,bd,dca+bd-1)\
dda=bb(ada,dca)__b=bb(bda,dca)cca:addText(1,n,cda)cca:addBG(1,n,dda)\
cca:addFG(1,n,__b)cca:addBlit(1,n,cda,__b,dda)end\
if _aa and aaa and baa and caa then local cda,dda,__b,a_b=bba()\
for n=__b,a_b do local b_b=#__a[n]\
local c_b=0\
if n==__b and n==a_b then c_b=cda-1 - (bd-1)b_b=\
b_b- (cda-1 - (bd-1))- (b_b-dda+ (bd-1))elseif n==a_b then b_b=b_b- (\
b_b-dda+ (bd-1))elseif n==__b then b_b=b_b- (cda-1)c_b=cda-1 -\
(bd-1)end;local d_b=math.min(b_b,dca-c_b)\
cca:addBG(1 +c_b,n,bb(ab[daa],d_b))cca:addFG(1 +c_b,n,bb(ab[_ba],d_b))end end end)end,load=function(cca)\
cca:listenEvent(\"mouse_click\")cca:listenEvent(\"mouse_up\")\
cca:listenEvent(\"mouse_scroll\")cca:listenEvent(\"mouse_drag\")\
cca:listenEvent(\"key\")cca:listenEvent(\"char\")\
cca:listenEvent(\"other_event\")end}bca.__index=bca;return setmetatable(bca,dc)end end;return aa[\"main\"]()",
    ["server/modules/disk.lua"] = "local a;local b={}b.__index=b;local c={\"Disk could not be found: \",\"Disk already partitioned: \",\"Percentages dont add up to 100: \"}function b.new(d,e,f)local self=setmetatable({},b)self.disks={}self.capacity=0;self.freeSpace=0;self.configPath=d or\"/GuardLink/server/config/partitions.json\"self.labelPrefix=e or\"DISK\"a=f or require(\"lib.fileUtils\")return self end;function b:getConfig()return textutils.unserializeJSON(a.read(self.configPath))end;function b:getDisks()return self.disks end;function b:diskCount()local g=0;for h,h in pairs(self.disks)do g=g+1 end;return g end;function b:disksToString()local i=self:getDisks()local j=\"Disks: [\"for k,l in pairs(i)do j=j..\", \"..k end;return j..\"]\"end;function b:getDisk(m)return self.disks[m]end;function b:getDiskLabels()local n={}for h,l in pairs(self.disks)do table.insert(n,l.label)end;return n end;function b:clearDisk(m)local disk=self.disks[m]if not disk then return{1,c[1]..m}end;for h,o in ipairs(fs.list(disk.path))do fs.delete(disk.path..\"/\"..o)end;return{0}end;function b:generateLabel()local p=1;local q;repeat q=self.labelPrefix..\"_\"..p;p=p+1 until not self.disks[q]return q end;function b:scan()self.disks={}self.capacity=0;self.freeSpace=0;for h,r in ipairs(peripheral.getNames())do if peripheral.getType(r)==\"drive\"and disk.isPresent(r)then local s=disk.getMountPath(r)local m=disk.getLabel(r)if not m then m=self:generateLabel()disk.setLabel(r,m)end;self.disks[m]={path=s,peripheral=r,freeSpace=fs.getFreeSpace(s),capacity=fs.getCapacity(s),label=m}self.capacity=self.capacity+fs.getCapacity(s)self.freeSpace=self.freeSpace+fs.getFreeSpace(s)end end;return{0}end;function b:validateLayout(t)local u;if fs.exists(self.configPath)then u=textutils.unserializeJSON(a.read(self.configPath))else u={}end;local v={}for h,l in pairs(u)do for h,w in ipairs(l)do if w.disk then v[w.disk]=true end end end;for h,m in ipairs(t.whitelist)do if not self.disks[m]then return{1,c[1]..m}end;if v[m]then return{2,c[2]..m}end end;local x=0;for h,l in ipairs(t.layout)do if l.percentage<=0 then return{3,c[3]..x}end;x=x+l.percentage end;if x~=100 then return{3,c[3]..x}end;return{0}end;function b:updateDisk(m)local y=self.disks[m]if not y then return{1,c[1]..m}end;y.path=disk.getMountPath(y.peripheral)y.freeSpace=fs.getFreeSpace(y.path)y.capacity=fs.getCapacity(y.path)self.capacity=0;self.freeSpace=0;for h,l in pairs(self.disks)do self.capacity=self.capacity+l.capacity;self.freeSpace=self.freeSpace+l.freeSpace end;return{0}end;local function z(n)local A={whitelist={},layout={}}for h,l in ipairs(n.whitelist)do table.insert(A.whitelist,l)end;for h,l in ipairs(n.layout)do table.insert(A.layout,{name=l.name,percentage=l.percentage})end;return A end;function b:partition(t)if next(self.disks)==nil then error(\"Cant create partitions, no disks were found! Use scan() first\")end;local j=self:validateLayout(t)if j[1]~=0 then error(j[2])end;local t=z(t)local B=next(self.disks)local C=fs.getCapacity(self.disks[B].path)or 125000;for h,m in ipairs(t.whitelist)do self:clearDisk(m)end;local u;if fs.exists(self.configPath)then u=textutils.unserializeJSON(a.read(self.configPath))or{}else u={}end;for h,D in ipairs(t.layout)do u[D.name]=u[D.name]or{}D.bytes=math.floor(#t.whitelist*C*D.percentage/100)end;local E=1;local F=t.whitelist;for h,D in ipairs(t.layout)do local G=D.bytes;while G>0 and E<=#F do local m=F[E]local y=self.disks[m]local H=C-(y.usedBytes or 0)local I=math.min(G,H)table.insert(u[D.name],{disk=m,bytes=I,percentage=I/C*100})y.usedBytes=(y.usedBytes or 0)+I;G=G-I;if y.usedBytes>=C then E=E+1 end end end;for h,m in ipairs(t.whitelist)do local y=self.disks[m]for r,J in pairs(u)do for h,w in ipairs(J)do if w.disk==m then fs.makeDir(y.path..\"/\"..r)end end end;fs.makeDir(y.path..\"/.cache\")y.usedBytes=nil end;local K=textutils.serializeJSON(u)a.newFile(self.configPath)return a.write(self.configPath,K)end;return b\
",
    ["server/lib/pixelbox_lite.lua"] = "local a={initialized=false,shared_data={},internal={}}local b={}local c=table.concat;local d={{2,3,4,5,6},{4,1,6,3,5},{1,4,5,2,6},{2,6,3,5,1},{3,6,1,4,2},{4,5,2,3,1}}local e=load(\"return {\"..string.rep(\"false,\",599)..\"[0]=false}\",\"=pb_preload\",\"t\")()local f=load(\"return {\"..string.rep(\"false,\",599)..\"[0]=false}\",\"=pb_preload\",\"t\")()local g=load(\"return {\"..string.rep(\"false,\",599)..\"[0]=false}\",\"=pb_preload\",\"t\")()local h={}a.internal.texel_character_lookup=e;a.internal.texel_foreground_lookup=f;a.internal.texel_background_lookup=g;a.internal.to_blit_lookup=h;a.internal.sampling_lookup=d;local function i(j,k,l,m,n,o)return k*1+l*3+m*4+n*20+o*100 end;local function p(q,r,s,t,u,v)local w={q,r,s,t,u,v}local x={}for y=1,6 do local z=w[y]local A=x[z]x[z]=A and A+1 or 1 end;local B={}for C,D in pairs(x)do B[#B+1]={value=C,count=D}end;table.sort(B,function(E,F)return E.count>F.count end)local G={}for H=1,6 do local I=w[H]if I==B[1].value then G[H]=1 elseif I==B[2].value then G[H]=0 else local J=d[H]for K=1,5 do local L=J[K]local M=w[L]local N=M==B[1].value;local O=M==B[2].value;if N or O then G[H]=N and 1 or 0;break end end end end;local P=128;local Q=G[6]if G[1]~=Q then P=P+1 end;if G[2]~=Q then P=P+2 end;if G[3]~=Q then P=P+4 end;if G[4]~=Q then P=P+8 end;if G[5]~=Q then P=P+16 end;local R,S;if#B>1 then R=B[Q+1].value;S=B[2-Q].value else R=B[1].value;S=B[1].value end;return P,R,S end;local function T(U,V,W)return math.floor(U/V^W)end;local X=0;local function Y()for Z=0,15 do h[2^Z]=(\"%x\"):format(Z)end;for _=0,6^6 do local a0=T(_,6,0)%6;local a1=T(_,6,1)%6;local a2=T(_,6,2)%6;local a3=T(_,6,3)%6;local a4=T(_,6,4)%6;local a5=T(_,6,5)%6;local a6={}a6[a5]=5;a6[a4]=4;a6[a3]=3;a6[a2]=2;a6[a1]=1;a6[a0]=0;local a7=i(a6[a0],a6[a1],a6[a2],a6[a3],a6[a4],a6[a5])if not e[a7]then X=X+1;local a8,a9,aa=p(a0,a1,a2,a3,a4,a5)local ab=a6[a9]+1;local ac=a6[aa]+1;f[a7]=ab;g[a7]=ac;e[a7]=string.char(a8)end end end;a.internal.generate_lookups=Y;a.internal.calculate_texel=p;a.internal.make_pattern_id=i;a.internal.base_n_rshift=T;function a.make_canvas_scanline(ad)return setmetatable({},{__newindex=function(ae,af,ag)if type(af)==\"number\"and af%1~=0 then error((\"Tried to write a float pixel. x:%s y:%s\"):format(af,ad),2)else rawset(ae,af,ag)end end})end;function a.make_canvas(ah)local ai=a.make_canvas_scanline(\"NONE\")local aj=getmetatable(ai)function aj.tostring()return\"pixelbox_dummy_oob\"end;return setmetatable(ah or{},{__index=function(ak,al)if type(al)==\"number\"and al%1~=0 then error((\"Tried to write float scanline. y:%s\"):format(al),2)end;return ai end})end;function a.setup_canvas(am,an,ao,ap)for aq=1,am.height do local ar;if not rawget(an,aq)then ar=a.make_canvas_scanline(aq)rawset(an,aq,ar)else ar=an[aq]end;for as=1,am.width do if not(ar[as]and ap)then ar[as]=ao end end end;return an end;function a.restore(at,au,av,aw)if not av then local ax=a.setup_canvas(at,a.make_canvas(),au)at.canvas=ax;at.CANVAS=ax else a.setup_canvas(at,at.canvas,au,aw)end end;local ay={}local az={0,0,0,0,0,0}function b:render()local aA=self.term;local aB,aC=aA.blit,aA.setCursorPos;local aD=self.canvas;local aE,aF,aG={},{},{}local aH,aI=self.x_offset,self.y_offset;local aJ,aK=self.width,self.height;local aL=0;for aM=1,aK,3 do aL=aL+1;local aN=aD[aM]local aO=aD[aM+1]local aP=aD[aM+2]local aQ=0;for aR=1,aJ,2 do local aS=aR+1;local aT,aU,aV,aW,aX,aY=aN[aR],aN[aS],aO[aR],aO[aS],aP[aR],aP[aS]local aZ,a_,b0=\" \",1,aT;local b1=aU==aT and aV==aT and aW==aT and aX==aT and aY==aT;if not b1 then ay[aY]=5;ay[aX]=4;ay[aW]=3;ay[aV]=2;ay[aU]=1;ay[aT]=0;local b2=ay[aU]+ay[aV]*3+ay[aW]*4+ay[aX]*20+ay[aY]*100;local b3=f[b2]local b4=g[b2]az[1]=aT;az[2]=aU;az[3]=aV;az[4]=aW;az[5]=aX;az[6]=aY;a_=az[b3]b0=az[b4]aZ=e[b2]end;aQ=aQ+1;aE[aQ]=aZ;aF[aQ]=h[a_]aG[aQ]=h[b0]end;aC(1+aH,aL+aI)aB(c(aE,\"\"),c(aF,\"\"),c(aG,\"\"))end end;function b:clear(b5)a.restore(self,h[b5 or\"\"]and b5 or self.background,true,false)end;function b:set_pixel(b6,b7,b8)self.canvas[b7][b6]=b8 end;function b:set_canvas(b9)self.canvas=b9;self.CANVAS=b9 end;function b:resize(ba,bb,bc)self.term_width=math.floor(ba+0.5)self.term_height=math.floor(bb+0.5)self.width=math.floor(ba+0.5)*2;self.height=math.floor(bb+0.5)*3;a.restore(self,bc or self.background,true,true)end;function a.module_error(bd,be,bf,bg)bf=bf or 1;if bd.__contact and not bg then local bh,bi=pcall(error,be,bf+2)printError(bi)error((bd.__report_msg or\"\\nReport module issue at:\\n-> __contact\"):gsub(\"[%w_]+\",bd),0)elseif not bg then error(be,bf+1)end end;function b:load_module(bj)for bk,bl in ipairs(bj or{})do local bm={__author=bl.author,__name=bl.name,__contact=bl.contact,__report_msg=bl.report_msg}local bn,bo=bl.init(self,bm,a,a.shared_data,a.initialized,bj)bo=bo or{}bm.__fn=bn;if self.modules[bl.id]and not bj.force then a.module_error(bm,(\"Module ID conflict: %q\"):format(bl.id),2,bj.supress)else self.modules[bl.id]=bm;if bo.verified_load then bo.verified_load()end end;for bp in pairs(bn)do if self.modules.module_functions[bp]and not bj.force then a.module_error(bm,(\"Module %q tried to register already existing element: %q\"):format(bl.id,bp),2,bj.supress)else self.modules.module_functions[bp]={id=bl.id,name=bp}end end end end;function a.new(bq,br,bs)local bt={modules={module_functions={}}}bt.background=br or bq.getBackgroundColor()local bu,bv=bq.getSize()bt.term=bq;setmetatable(bt,{__index=function(bw,bx)local by=rawget(bt.modules.module_functions,bx)if by then return bt.modules[by.id].__fn[by.name]end;return rawget(b,bx)end})bt.__pixelbox_lite=true;bt.term_width=bu;bt.term_height=bv;bt.width=bu*2;bt.height=bv*3;bt.x_offset=0;bt.y_offset=0;a.restore(bt,bt.background)if type(bs)==\"table\"then bt:load_module(bs)end;if not a.initialized then Y()a.initialized=true end;return bt end;return a\
",
    ["server/network/clientManager.lua"] = "local a=require\"lib.errors\"local b=require\"network.message\"local c=require\"lib.aes\"os.loadAPI('/GuardLink/server/lib/aes.lua')local d={}d.__index=d;function d.new(e,f)local self=setmetatable({},d)self.clients={}self.session=e or nil;self.max_idle=(f.clients.max_idle or 60)*1000;self.heartbeat_interval=f.clients.heartbeat_interval or 60;self.maxClients=f.clients.maxClients or 30;self.throttleLimit=(f.clients.throttleLimit or 7200)*1000;self.channelRotation=f.clients.channelRotation or 30;self.clientIDLength=f.clients.idLength or 5;_G.shutdown.register(function()self:disconnectAll(\"SERVER_SHUTDOWN\")end)return self end;function d:getClientByToken(g)for h,i in pairs(self.clients)do if i.token==g then return self.clients[h]end end;return nil end;function d:exists(j)return self.clients[j]~=nil end;function d:getClient(j)return self.clients[j]end;function d:updateActivity(j,k)local l=self:getClient(j)if l then l.lastActivityTime=os.epoch(\"utc\")l.lastActivityType=k;return 0 end;return a.UNKNOWN_CLIENT end;function d:disconnectClient(j,m)local l=self.clients[j]if l then local n=b.create(\"network\",{action=\"disconnect\",reason=m or\"unknown_reason\"},l.aesKey,false)self.session:send(l.channel,textutils.serialize({plaintext=false,message=n}))self.session:close(l.channel)self.clients[j]=nil;return 0 else return a.UNKNOWN_CLIENT end end;function d:disconnectAll(m)local o={action=\"disconnect\",reason=m or\"unknown_reason\"}local p=0;for q,l in pairs(self.clients)do local n=b.create(\"network\",o,l.aesKey,false)self.session:send(l.channel,textutils.serialize({plaintext=false,message=n}))self.session:close(l.channel)p=p+1 end;self.clients={}_G.logger:info(\"[clientManager] Disconnected \"..p..\" clients!\")return 0 end;function d:count()local r=0;for q in pairs(self.clients)do r=r+1 end;return r end;function d:computeChannel(s)local t=math.floor(os.epoch(\"utc\")/1000)local u=_G.utils.stringToNumber(s)+t;return u%65534+1 end;function d:registerClient(v,w)if self:count()+1>self.maxClients then return a.SERVER_FULL end;local x;local s;repeat x=_G.utils.randomString(self.clientIDLength,\"numbers\")s=_G.utils.randomString(32,\"generic\")local y=false;for h,i in pairs(self.clients)do if i.token==s then y=true;break end end until not self.clients[x]and not y;local z=self:computeChannel(s)self.session:open(z)self.clients[x]={token=s,id=x,connectedAt=os.date(\"%Y-%m-%d %H:%M:%S\"),connectedAtEpoch=os.epoch(\"utc\"),lastActivityTime=os.epoch(\"utc\"),lastActivityType=\"connected\",throttle=0,account=v,channel=z,aesKey=c.Cipher:new(nil,w),sleepy=false}return self.clients[x]end;function d:listClients()local A={}for h,i in pairs(self.clients)do table.insert(A,h)end;return A end;function d:setThrottle(j,B)local l=self:getClient(j)if not l then return a.UNKNOWN_CLIENT end;l.throttle=math.min((B or 0)*1000,self.throttleLimit)return 0 end;function d:getStaleClients()local C={}local D=os.epoch(\"utc\")for q,i in pairs(self.clients)do if D-i.lastActivityTime-(i.throttle or 0)>self.max_idle then table.insert(C,i)end end;return C end;function d:heartbeats()local D=os.epoch(\"utc\")local E=self:getStaleClients()for q,i in pairs(E)do if i.sleepy then if D-i.lastActivityTime>self.max_idle then self:disconnectClient(i.id,\"time_out\")else i.sleepy=false end else i.sleepy=true;local n=b.create(\"network\",{action=\"heartbeat\"},i.aesKey,false)self.session:send(i.channel,n)end end end;function d:updateChannels()for q,i in pairs(self.clients)do local F=self:computeChannel(i.token)local n=b.create(\"network\",{action=\"update_channel\",channel=F},i.aesKey,false)self.session:send(i.channel,textutils.serialize({plaintext=false,message=n}))self.session:close(i.channel)i.channel=F end;for q,i in pairs(self.clients)do self.session:open(i.channel)end;return 0 end;return d\
",
    ["server/lib/aes.lua"] = "if not bit then error(\"bit API not found\")end;local a,b,c,d=bit.band,bit.bor,bit.bxor,bit.bnot;local function e(f,g)return a(bit.blshift(f,g),0xffffffff)end;local function h(f,g)if g==0 then return f end;if a(f,0x80000000)==0 then return bit.brshift(f,g)end;return c(bit.brshift(0x7fffffff,g-1),bit.brshift(d(f),g))end;local function i(j,k)local l=#k<#j and k or j;local m={}for n,o in ipairs(l)do m[n]=c(j[n],k[n])end;return m end;local function p(f)return a(f,0xff)end;local function q(r)return b(r[4],b(e(r[3],8),b(e(r[2],16),e(r[1],24))))end;local function s(f)return string.char(p(h(f,24)),p(h(f,16)),p(h(f,8)),p(f))end;local function t(u)return{q({string.byte(u,1,4)}),q({string.byte(u,5,8)}),q({string.byte(u,9,12)}),q({string.byte(u,13,16)})}end;local function v(k)return s(k[1])..s(k[2])..s(k[3])..s(k[4])end;local w={0x01,0x02,0x04,0x08,0x10,0x20,0x40,0x80,0x1b,0x36,0x6c,0xd8,0xab,0x4d,0x9a,0x2f}local x={[0]=0x63,0x7c,0x77,0x7b,0xf2,0x6b,0x6f,0xc5,0x30,0x01,0x67,0x2b,0xfe,0xd7,0xab,0x76,0xca,0x82,0xc9,0x7d,0xfa,0x59,0x47,0xf0,0xad,0xd4,0xa2,0xaf,0x9c,0xa4,0x72,0xc0,0xb7,0xfd,0x93,0x26,0x36,0x3f,0xf7,0xcc,0x34,0xa5,0xe5,0xf1,0x71,0xd8,0x31,0x15,0x04,0xc7,0x23,0xc3,0x18,0x96,0x05,0x9a,0x07,0x12,0x80,0xe2,0xeb,0x27,0xb2,0x75,0x09,0x83,0x2c,0x1a,0x1b,0x6e,0x5a,0xa0,0x52,0x3b,0xd6,0xb3,0x29,0xe3,0x2f,0x84,0x53,0xd1,0x00,0xed,0x20,0xfc,0xb1,0x5b,0x6a,0xcb,0xbe,0x39,0x4a,0x4c,0x58,0xcf,0xd0,0xef,0xaa,0xfb,0x43,0x4d,0x33,0x85,0x45,0xf9,0x02,0x7f,0x50,0x3c,0x9f,0xa8,0x51,0xa3,0x40,0x8f,0x92,0x9d,0x38,0xf5,0xbc,0xb6,0xda,0x21,0x10,0xff,0xf3,0xd2,0xcd,0x0c,0x13,0xec,0x5f,0x97,0x44,0x17,0xc4,0xa7,0x7e,0x3d,0x64,0x5d,0x19,0x73,0x60,0x81,0x4f,0xdc,0x22,0x2a,0x90,0x88,0x46,0xee,0xb8,0x14,0xde,0x5e,0x0b,0xdb,0xe0,0x32,0x3a,0x0a,0x49,0x06,0x24,0x5c,0xc2,0xd3,0xac,0x62,0x91,0x95,0xe4,0x79,0xe7,0xc8,0x37,0x6d,0x8d,0xd5,0x4e,0xa9,0x6c,0x56,0xf4,0xea,0x65,0x7a,0xae,0x08,0xba,0x78,0x25,0x2e,0x1c,0xa6,0xb4,0xc6,0xe8,0xdd,0x74,0x1f,0x4b,0xbd,0x8b,0x8a,0x70,0x3e,0xb5,0x66,0x48,0x03,0xf6,0x0e,0x61,0x35,0x57,0xb9,0x86,0xc1,0x1d,0x9e,0xe1,0xf8,0x98,0x11,0x69,0xd9,0x8e,0x94,0x9b,0x1e,0x87,0xe9,0xce,0x55,0x28,0xdf,0x8c,0xa1,0x89,0x0d,0xbf,0xe6,0x42,0x68,0x41,0x99,0x2d,0x0f,0xb0,0x54,0xbb,0x16}local y={[0]=0x52,0x09,0x6a,0xd5,0x30,0x36,0xa5,0x38,0xbf,0x40,0xa3,0x9e,0x81,0xf3,0xd7,0xfb,0x7c,0xe3,0x39,0x82,0x9b,0x2f,0xff,0x87,0x34,0x8e,0x43,0x44,0xc4,0xde,0xe9,0xcb,0x54,0x7b,0x94,0x32,0xa6,0xc2,0x23,0x3d,0xee,0x4c,0x95,0x0b,0x42,0xfa,0xc3,0x4e,0x08,0x2e,0xa1,0x66,0x28,0xd9,0x24,0xb2,0x76,0x5b,0xa2,0x49,0x6d,0x8b,0xd1,0x25,0x72,0xf8,0xf6,0x64,0x86,0x68,0x98,0x16,0xd4,0xa4,0x5c,0xcc,0x5d,0x65,0xb6,0x92,0x6c,0x70,0x48,0x50,0xfd,0xed,0xb9,0xda,0x5e,0x15,0x46,0x57,0xa7,0x8d,0x9d,0x84,0x90,0xd8,0xab,0x00,0x8c,0xbc,0xd3,0x0a,0xf7,0xe4,0x58,0x05,0xb8,0xb3,0x45,0x06,0xd0,0x2c,0x1e,0x8f,0xca,0x3f,0x0f,0x02,0xc1,0xaf,0xbd,0x03,0x01,0x13,0x8a,0x6b,0x3a,0x91,0x11,0x41,0x4f,0x67,0xdc,0xea,0x97,0xf2,0xcf,0xce,0xf0,0xb4,0xe6,0x73,0x96,0xac,0x74,0x22,0xe7,0xad,0x35,0x85,0xe2,0xf9,0x37,0xe8,0x1c,0x75,0xdf,0x6e,0x47,0xf1,0x1a,0x71,0x1d,0x29,0xc5,0x89,0x6f,0xb7,0x62,0x0e,0xaa,0x18,0xbe,0x1b,0xfc,0x56,0x3e,0x4b,0xc6,0xd2,0x79,0x20,0x9a,0xdb,0xc0,0xfe,0x78,0xcd,0x5a,0xf4,0x1f,0xdd,0xa8,0x33,0x88,0x07,0xc7,0x31,0xb1,0x12,0x10,0x59,0x27,0x80,0xec,0x5f,0x60,0x51,0x7f,0xa9,0x19,0xb5,0x4a,0x0d,0x2d,0xe5,0x7a,0x9f,0x93,0xc9,0x9c,0xef,0xa0,0xe0,0x3b,0x4d,0xae,0x2a,0xf5,0xb0,0xc8,0xeb,0xbb,0x3c,0x83,0x53,0x99,0x61,0x17,0x2b,0x04,0x7e,0xba,0x77,0xd6,0x26,0xe1,0x69,0x14,0x63,0x55,0x21,0x0c,0x7d}local z={[0]=0xc66363a5,0xf87c7c84,0xee777799,0xf67b7b8d,0xfff2f20d,0xd66b6bbd,0xde6f6fb1,0x91c5c554,0x60303050,0x02010103,0xce6767a9,0x562b2b7d,0xe7fefe19,0xb5d7d762,0x4dababe6,0xec76769a,0x8fcaca45,0x1f82829d,0x89c9c940,0xfa7d7d87,0xeffafa15,0xb25959eb,0x8e4747c9,0xfbf0f00b,0x41adadec,0xb3d4d467,0x5fa2a2fd,0x45afafea,0x239c9cbf,0x53a4a4f7,0xe4727296,0x9bc0c05b,0x75b7b7c2,0xe1fdfd1c,0x3d9393ae,0x4c26266a,0x6c36365a,0x7e3f3f41,0xf5f7f702,0x83cccc4f,0x6834345c,0x51a5a5f4,0xd1e5e534,0xf9f1f108,0xe2717193,0xabd8d873,0x62313153,0x2a15153f,0x0804040c,0x95c7c752,0x46232365,0x9dc3c35e,0x30181828,0x379696a1,0x0a05050f,0x2f9a9ab5,0x0e070709,0x24121236,0x1b80809b,0xdfe2e23d,0xcdebeb26,0x4e272769,0x7fb2b2cd,0xea75759f,0x1209091b,0x1d83839e,0x582c2c74,0x341a1a2e,0x361b1b2d,0xdc6e6eb2,0xb45a5aee,0x5ba0a0fb,0xa45252f6,0x763b3b4d,0xb7d6d661,0x7db3b3ce,0x5229297b,0xdde3e33e,0x5e2f2f71,0x13848497,0xa65353f5,0xb9d1d168,0x00000000,0xc1eded2c,0x40202060,0xe3fcfc1f,0x79b1b1c8,0xb65b5bed,0xd46a6abe,0x8dcbcb46,0x67bebed9,0x7239394b,0x944a4ade,0x984c4cd4,0xb05858e8,0x85cfcf4a,0xbbd0d06b,0xc5efef2a,0x4faaaae5,0xedfbfb16,0x864343c5,0x9a4d4dd7,0x66333355,0x11858594,0x8a4545cf,0xe9f9f910,0x04020206,0xfe7f7f81,0xa05050f0,0x783c3c44,0x259f9fba,0x4ba8a8e3,0xa25151f3,0x5da3a3fe,0x804040c0,0x058f8f8a,0x3f9292ad,0x219d9dbc,0x70383848,0xf1f5f504,0x63bcbcdf,0x77b6b6c1,0xafdada75,0x42212163,0x20101030,0xe5ffff1a,0xfdf3f30e,0xbfd2d26d,0x81cdcd4c,0x180c0c14,0x26131335,0xc3ecec2f,0xbe5f5fe1,0x359797a2,0x884444cc,0x2e171739,0x93c4c457,0x55a7a7f2,0xfc7e7e82,0x7a3d3d47,0xc86464ac,0xba5d5de7,0x3219192b,0xe6737395,0xc06060a0,0x19818198,0x9e4f4fd1,0xa3dcdc7f,0x44222266,0x542a2a7e,0x3b9090ab,0x0b888883,0x8c4646ca,0xc7eeee29,0x6bb8b8d3,0x2814143c,0xa7dede79,0xbc5e5ee2,0x160b0b1d,0xaddbdb76,0xdbe0e03b,0x64323256,0x743a3a4e,0x140a0a1e,0x924949db,0x0c06060a,0x4824246c,0xb85c5ce4,0x9fc2c25d,0xbdd3d36e,0x43acacef,0xc46262a6,0x399191a8,0x319595a4,0xd3e4e437,0xf279798b,0xd5e7e732,0x8bc8c843,0x6e373759,0xda6d6db7,0x018d8d8c,0xb1d5d564,0x9c4e4ed2,0x49a9a9e0,0xd86c6cb4,0xac5656fa,0xf3f4f407,0xcfeaea25,0xca6565af,0xf47a7a8e,0x47aeaee9,0x10080818,0x6fbabad5,0xf0787888,0x4a25256f,0x5c2e2e72,0x381c1c24,0x57a6a6f1,0x73b4b4c7,0x97c6c651,0xcbe8e823,0xa1dddd7c,0xe874749c,0x3e1f1f21,0x964b4bdd,0x61bdbddc,0x0d8b8b86,0x0f8a8a85,0xe0707090,0x7c3e3e42,0x71b5b5c4,0xcc6666aa,0x904848d8,0x06030305,0xf7f6f601,0x1c0e0e12,0xc26161a3,0x6a35355f,0xae5757f9,0x69b9b9d0,0x17868691,0x99c1c158,0x3a1d1d27,0x279e9eb9,0xd9e1e138,0xebf8f813,0x2b9898b3,0x22111133,0xd26969bb,0xa9d9d970,0x078e8e89,0x339494a7,0x2d9b9bb6,0x3c1e1e22,0x15878792,0xc9e9e920,0x87cece49,0xaa5555ff,0x50282878,0xa5dfdf7a,0x038c8c8f,0x59a1a1f8,0x09898980,0x1a0d0d17,0x65bfbfda,0xd7e6e631,0x844242c6,0xd06868b8,0x824141c3,0x299999b0,0x5a2d2d77,0x1e0f0f11,0x7bb0b0cb,0xa85454fc,0x6dbbbbd6,0x2c16163a}local A={[0]=0xa5c66363,0x84f87c7c,0x99ee7777,0x8df67b7b,0x0dfff2f2,0xbdd66b6b,0xb1de6f6f,0x5491c5c5,0x50603030,0x03020101,0xa9ce6767,0x7d562b2b,0x19e7fefe,0x62b5d7d7,0xe64dabab,0x9aec7676,0x458fcaca,0x9d1f8282,0x4089c9c9,0x87fa7d7d,0x15effafa,0xebb25959,0xc98e4747,0x0bfbf0f0,0xec41adad,0x67b3d4d4,0xfd5fa2a2,0xea45afaf,0xbf239c9c,0xf753a4a4,0x96e47272,0x5b9bc0c0,0xc275b7b7,0x1ce1fdfd,0xae3d9393,0x6a4c2626,0x5a6c3636,0x417e3f3f,0x02f5f7f7,0x4f83cccc,0x5c683434,0xf451a5a5,0x34d1e5e5,0x08f9f1f1,0x93e27171,0x73abd8d8,0x53623131,0x3f2a1515,0x0c080404,0x5295c7c7,0x65462323,0x5e9dc3c3,0x28301818,0xa1379696,0x0f0a0505,0xb52f9a9a,0x090e0707,0x36241212,0x9b1b8080,0x3ddfe2e2,0x26cdebeb,0x694e2727,0xcd7fb2b2,0x9fea7575,0x1b120909,0x9e1d8383,0x74582c2c,0x2e341a1a,0x2d361b1b,0xb2dc6e6e,0xeeb45a5a,0xfb5ba0a0,0xf6a45252,0x4d763b3b,0x61b7d6d6,0xce7db3b3,0x7b522929,0x3edde3e3,0x715e2f2f,0x97138484,0xf5a65353,0x68b9d1d1,0x00000000,0x2cc1eded,0x60402020,0x1fe3fcfc,0xc879b1b1,0xedb65b5b,0xbed46a6a,0x468dcbcb,0xd967bebe,0x4b723939,0xde944a4a,0xd4984c4c,0xe8b05858,0x4a85cfcf,0x6bbbd0d0,0x2ac5efef,0xe54faaaa,0x16edfbfb,0xc5864343,0xd79a4d4d,0x55663333,0x94118585,0xcf8a4545,0x10e9f9f9,0x06040202,0x81fe7f7f,0xf0a05050,0x44783c3c,0xba259f9f,0xe34ba8a8,0xf3a25151,0xfe5da3a3,0xc0804040,0x8a058f8f,0xad3f9292,0xbc219d9d,0x48703838,0x04f1f5f5,0xdf63bcbc,0xc177b6b6,0x75afdada,0x63422121,0x30201010,0x1ae5ffff,0x0efdf3f3,0x6dbfd2d2,0x4c81cdcd,0x14180c0c,0x35261313,0x2fc3ecec,0xe1be5f5f,0xa2359797,0xcc884444,0x392e1717,0x5793c4c4,0xf255a7a7,0x82fc7e7e,0x477a3d3d,0xacc86464,0xe7ba5d5d,0x2b321919,0x95e67373,0xa0c06060,0x98198181,0xd19e4f4f,0x7fa3dcdc,0x66442222,0x7e542a2a,0xab3b9090,0x830b8888,0xca8c4646,0x29c7eeee,0xd36bb8b8,0x3c281414,0x79a7dede,0xe2bc5e5e,0x1d160b0b,0x76addbdb,0x3bdbe0e0,0x56643232,0x4e743a3a,0x1e140a0a,0xdb924949,0x0a0c0606,0x6c482424,0xe4b85c5c,0x5d9fc2c2,0x6ebdd3d3,0xef43acac,0xa6c46262,0xa8399191,0xa4319595,0x37d3e4e4,0x8bf27979,0x32d5e7e7,0x438bc8c8,0x596e3737,0xb7da6d6d,0x8c018d8d,0x64b1d5d5,0xd29c4e4e,0xe049a9a9,0xb4d86c6c,0xfaac5656,0x07f3f4f4,0x25cfeaea,0xafca6565,0x8ef47a7a,0xe947aeae,0x18100808,0xd56fbaba,0x88f07878,0x6f4a2525,0x725c2e2e,0x24381c1c,0xf157a6a6,0xc773b4b4,0x5197c6c6,0x23cbe8e8,0x7ca1dddd,0x9ce87474,0x213e1f1f,0xdd964b4b,0xdc61bdbd,0x860d8b8b,0x850f8a8a,0x90e07070,0x427c3e3e,0xc471b5b5,0xaacc6666,0xd8904848,0x05060303,0x01f7f6f6,0x121c0e0e,0xa3c26161,0x5f6a3535,0xf9ae5757,0xd069b9b9,0x91178686,0x5899c1c1,0x273a1d1d,0xb9279e9e,0x38d9e1e1,0x13ebf8f8,0xb32b9898,0x33221111,0xbbd26969,0x70a9d9d9,0x89078e8e,0xa7339494,0xb62d9b9b,0x223c1e1e,0x92158787,0x20c9e9e9,0x4987cece,0xffaa5555,0x78502828,0x7aa5dfdf,0x8f038c8c,0xf859a1a1,0x80098989,0x171a0d0d,0xda65bfbf,0x31d7e6e6,0xc6844242,0xb8d06868,0xc3824141,0xb0299999,0x775a2d2d,0x111e0f0f,0xcb7bb0b0,0xfca85454,0xd66dbbbb,0x3a2c1616}local B={[0]=0x63a5c663,0x7c84f87c,0x7799ee77,0x7b8df67b,0xf20dfff2,0x6bbdd66b,0x6fb1de6f,0xc55491c5,0x30506030,0x01030201,0x67a9ce67,0x2b7d562b,0xfe19e7fe,0xd762b5d7,0xabe64dab,0x769aec76,0xca458fca,0x829d1f82,0xc94089c9,0x7d87fa7d,0xfa15effa,0x59ebb259,0x47c98e47,0xf00bfbf0,0xadec41ad,0xd467b3d4,0xa2fd5fa2,0xafea45af,0x9cbf239c,0xa4f753a4,0x7296e472,0xc05b9bc0,0xb7c275b7,0xfd1ce1fd,0x93ae3d93,0x266a4c26,0x365a6c36,0x3f417e3f,0xf702f5f7,0xcc4f83cc,0x345c6834,0xa5f451a5,0xe534d1e5,0xf108f9f1,0x7193e271,0xd873abd8,0x31536231,0x153f2a15,0x040c0804,0xc75295c7,0x23654623,0xc35e9dc3,0x18283018,0x96a13796,0x050f0a05,0x9ab52f9a,0x07090e07,0x12362412,0x809b1b80,0xe23ddfe2,0xeb26cdeb,0x27694e27,0xb2cd7fb2,0x759fea75,0x091b1209,0x839e1d83,0x2c74582c,0x1a2e341a,0x1b2d361b,0x6eb2dc6e,0x5aeeb45a,0xa0fb5ba0,0x52f6a452,0x3b4d763b,0xd661b7d6,0xb3ce7db3,0x297b5229,0xe33edde3,0x2f715e2f,0x84971384,0x53f5a653,0xd168b9d1,0x00000000,0xed2cc1ed,0x20604020,0xfc1fe3fc,0xb1c879b1,0x5bedb65b,0x6abed46a,0xcb468dcb,0xbed967be,0x394b7239,0x4ade944a,0x4cd4984c,0x58e8b058,0xcf4a85cf,0xd06bbbd0,0xef2ac5ef,0xaae54faa,0xfb16edfb,0x43c58643,0x4dd79a4d,0x33556633,0x85941185,0x45cf8a45,0xf910e9f9,0x02060402,0x7f81fe7f,0x50f0a050,0x3c44783c,0x9fba259f,0xa8e34ba8,0x51f3a251,0xa3fe5da3,0x40c08040,0x8f8a058f,0x92ad3f92,0x9dbc219d,0x38487038,0xf504f1f5,0xbcdf63bc,0xb6c177b6,0xda75afda,0x21634221,0x10302010,0xff1ae5ff,0xf30efdf3,0xd26dbfd2,0xcd4c81cd,0x0c14180c,0x13352613,0xec2fc3ec,0x5fe1be5f,0x97a23597,0x44cc8844,0x17392e17,0xc45793c4,0xa7f255a7,0x7e82fc7e,0x3d477a3d,0x64acc864,0x5de7ba5d,0x192b3219,0x7395e673,0x60a0c060,0x81981981,0x4fd19e4f,0xdc7fa3dc,0x22664422,0x2a7e542a,0x90ab3b90,0x88830b88,0x46ca8c46,0xee29c7ee,0xb8d36bb8,0x143c2814,0xde79a7de,0x5ee2bc5e,0x0b1d160b,0xdb76addb,0xe03bdbe0,0x32566432,0x3a4e743a,0x0a1e140a,0x49db9249,0x060a0c06,0x246c4824,0x5ce4b85c,0xc25d9fc2,0xd36ebdd3,0xacef43ac,0x62a6c462,0x91a83991,0x95a43195,0xe437d3e4,0x798bf279,0xe732d5e7,0xc8438bc8,0x37596e37,0x6db7da6d,0x8d8c018d,0xd564b1d5,0x4ed29c4e,0xa9e049a9,0x6cb4d86c,0x56faac56,0xf407f3f4,0xea25cfea,0x65afca65,0x7a8ef47a,0xaee947ae,0x08181008,0xbad56fba,0x7888f078,0x256f4a25,0x2e725c2e,0x1c24381c,0xa6f157a6,0xb4c773b4,0xc65197c6,0xe823cbe8,0xdd7ca1dd,0x749ce874,0x1f213e1f,0x4bdd964b,0xbddc61bd,0x8b860d8b,0x8a850f8a,0x7090e070,0x3e427c3e,0xb5c471b5,0x66aacc66,0x48d89048,0x03050603,0xf601f7f6,0x0e121c0e,0x61a3c261,0x355f6a35,0x57f9ae57,0xb9d069b9,0x86911786,0xc15899c1,0x1d273a1d,0x9eb9279e,0xe138d9e1,0xf813ebf8,0x98b32b98,0x11332211,0x69bbd269,0xd970a9d9,0x8e89078e,0x94a73394,0x9bb62d9b,0x1e223c1e,0x87921587,0xe920c9e9,0xce4987ce,0x55ffaa55,0x28785028,0xdf7aa5df,0x8c8f038c,0xa1f859a1,0x89800989,0x0d171a0d,0xbfda65bf,0xe631d7e6,0x42c68442,0x68b8d068,0x41c38241,0x99b02999,0x2d775a2d,0x0f111e0f,0xb0cb7bb0,0x54fca854,0xbbd66dbb,0x163a2c16}local C={[0]=0x6363a5c6,0x7c7c84f8,0x777799ee,0x7b7b8df6,0xf2f20dff,0x6b6bbdd6,0x6f6fb1de,0xc5c55491,0x30305060,0x01010302,0x6767a9ce,0x2b2b7d56,0xfefe19e7,0xd7d762b5,0xababe64d,0x76769aec,0xcaca458f,0x82829d1f,0xc9c94089,0x7d7d87fa,0xfafa15ef,0x5959ebb2,0x4747c98e,0xf0f00bfb,0xadadec41,0xd4d467b3,0xa2a2fd5f,0xafafea45,0x9c9cbf23,0xa4a4f753,0x727296e4,0xc0c05b9b,0xb7b7c275,0xfdfd1ce1,0x9393ae3d,0x26266a4c,0x36365a6c,0x3f3f417e,0xf7f702f5,0xcccc4f83,0x34345c68,0xa5a5f451,0xe5e534d1,0xf1f108f9,0x717193e2,0xd8d873ab,0x31315362,0x15153f2a,0x04040c08,0xc7c75295,0x23236546,0xc3c35e9d,0x18182830,0x9696a137,0x05050f0a,0x9a9ab52f,0x0707090e,0x12123624,0x80809b1b,0xe2e23ddf,0xebeb26cd,0x2727694e,0xb2b2cd7f,0x75759fea,0x09091b12,0x83839e1d,0x2c2c7458,0x1a1a2e34,0x1b1b2d36,0x6e6eb2dc,0x5a5aeeb4,0xa0a0fb5b,0x5252f6a4,0x3b3b4d76,0xd6d661b7,0xb3b3ce7d,0x29297b52,0xe3e33edd,0x2f2f715e,0x84849713,0x5353f5a6,0xd1d168b9,0x00000000,0xeded2cc1,0x20206040,0xfcfc1fe3,0xb1b1c879,0x5b5bedb6,0x6a6abed4,0xcbcb468d,0xbebed967,0x39394b72,0x4a4ade94,0x4c4cd498,0x5858e8b0,0xcfcf4a85,0xd0d06bbb,0xefef2ac5,0xaaaae54f,0xfbfb16ed,0x4343c586,0x4d4dd79a,0x33335566,0x85859411,0x4545cf8a,0xf9f910e9,0x02020604,0x7f7f81fe,0x5050f0a0,0x3c3c4478,0x9f9fba25,0xa8a8e34b,0x5151f3a2,0xa3a3fe5d,0x4040c080,0x8f8f8a05,0x9292ad3f,0x9d9dbc21,0x38384870,0xf5f504f1,0xbcbcdf63,0xb6b6c177,0xdada75af,0x21216342,0x10103020,0xffff1ae5,0xf3f30efd,0xd2d26dbf,0xcdcd4c81,0x0c0c1418,0x13133526,0xecec2fc3,0x5f5fe1be,0x9797a235,0x4444cc88,0x1717392e,0xc4c45793,0xa7a7f255,0x7e7e82fc,0x3d3d477a,0x6464acc8,0x5d5de7ba,0x19192b32,0x737395e6,0x6060a0c0,0x81819819,0x4f4fd19e,0xdcdc7fa3,0x22226644,0x2a2a7e54,0x9090ab3b,0x8888830b,0x4646ca8c,0xeeee29c7,0xb8b8d36b,0x14143c28,0xdede79a7,0x5e5ee2bc,0x0b0b1d16,0xdbdb76ad,0xe0e03bdb,0x32325664,0x3a3a4e74,0x0a0a1e14,0x4949db92,0x06060a0c,0x24246c48,0x5c5ce4b8,0xc2c25d9f,0xd3d36ebd,0xacacef43,0x6262a6c4,0x9191a839,0x9595a431,0xe4e437d3,0x79798bf2,0xe7e732d5,0xc8c8438b,0x3737596e,0x6d6db7da,0x8d8d8c01,0xd5d564b1,0x4e4ed29c,0xa9a9e049,0x6c6cb4d8,0x5656faac,0xf4f407f3,0xeaea25cf,0x6565afca,0x7a7a8ef4,0xaeaee947,0x08081810,0xbabad56f,0x787888f0,0x25256f4a,0x2e2e725c,0x1c1c2438,0xa6a6f157,0xb4b4c773,0xc6c65197,0xe8e823cb,0xdddd7ca1,0x74749ce8,0x1f1f213e,0x4b4bdd96,0xbdbddc61,0x8b8b860d,0x8a8a850f,0x707090e0,0x3e3e427c,0xb5b5c471,0x6666aacc,0x4848d890,0x03030506,0xf6f601f7,0x0e0e121c,0x6161a3c2,0x35355f6a,0x5757f9ae,0xb9b9d069,0x86869117,0xc1c15899,0x1d1d273a,0x9e9eb927,0xe1e138d9,0xf8f813eb,0x9898b32b,0x11113322,0x6969bbd2,0xd9d970a9,0x8e8e8907,0x9494a733,0x9b9bb62d,0x1e1e223c,0x87879215,0xe9e920c9,0xcece4987,0x5555ffaa,0x28287850,0xdfdf7aa5,0x8c8c8f03,0xa1a1f859,0x89898009,0x0d0d171a,0xbfbfda65,0xe6e631d7,0x4242c684,0x6868b8d0,0x4141c382,0x9999b029,0x2d2d775a,0x0f0f111e,0xb0b0cb7b,0x5454fca8,0xbbbbd66d,0x16163a2c}local D={[0]=0x51f4a750,0x7e416553,0x1a17a4c3,0x3a275e96,0x3bab6bcb,0x1f9d45f1,0xacfa58ab,0x4be30393,0x2030fa55,0xad766df6,0x88cc7691,0xf5024c25,0x4fe5d7fc,0xc52acbd7,0x26354480,0xb562a38f,0xdeb15a49,0x25ba1b67,0x45ea0e98,0x5dfec0e1,0xc32f7502,0x814cf012,0x8d4697a3,0x6bd3f9c6,0x038f5fe7,0x15929c95,0xbf6d7aeb,0x955259da,0xd4be832d,0x587421d3,0x49e06929,0x8ec9c844,0x75c2896a,0xf48e7978,0x99583e6b,0x27b971dd,0xbee14fb6,0xf088ad17,0xc920ac66,0x7dce3ab4,0x63df4a18,0xe51a3182,0x97513360,0x62537f45,0xb16477e0,0xbb6bae84,0xfe81a01c,0xf9082b94,0x70486858,0x8f45fd19,0x94de6c87,0x527bf8b7,0xab73d323,0x724b02e2,0xe31f8f57,0x6655ab2a,0xb2eb2807,0x2fb5c203,0x86c57b9a,0xd33708a5,0x302887f2,0x23bfa5b2,0x02036aba,0xed16825c,0x8acf1c2b,0xa779b492,0xf307f2f0,0x4e69e2a1,0x65daf4cd,0x0605bed5,0xd134621f,0xc4a6fe8a,0x342e539d,0xa2f355a0,0x058ae132,0xa4f6eb75,0x0b83ec39,0x4060efaa,0x5e719f06,0xbd6e1051,0x3e218af9,0x96dd063d,0xdd3e05ae,0x4de6bd46,0x91548db5,0x71c45d05,0x0406d46f,0x605015ff,0x1998fb24,0xd6bde997,0x894043cc,0x67d99e77,0xb0e842bd,0x07898b88,0xe7195b38,0x79c8eedb,0xa17c0a47,0x7c420fe9,0xf8841ec9,0x00000000,0x09808683,0x322bed48,0x1e1170ac,0x6c5a724e,0xfd0efffb,0x0f853856,0x3daed51e,0x362d3927,0x0a0fd964,0x685ca621,0x9b5b54d1,0x24362e3a,0x0c0a67b1,0x9357e70f,0xb4ee96d2,0x1b9b919e,0x80c0c54f,0x61dc20a2,0x5a774b69,0x1c121a16,0xe293ba0a,0xc0a02ae5,0x3c22e043,0x121b171d,0x0e090d0b,0xf28bc7ad,0x2db6a8b9,0x141ea9c8,0x57f11985,0xaf75074c,0xee99ddbb,0xa37f60fd,0xf701269f,0x5c72f5bc,0x44663bc5,0x5bfb7e34,0x8b432976,0xcb23c6dc,0xb6edfc68,0xb8e4f163,0xd731dcca,0x42638510,0x13972240,0x84c61120,0x854a247d,0xd2bb3df8,0xaef93211,0xc729a16d,0x1d9e2f4b,0xdcb230f3,0x0d8652ec,0x77c1e3d0,0x2bb3166c,0xa970b999,0x119448fa,0x47e96422,0xa8fc8cc4,0xa0f03f1a,0x567d2cd8,0x223390ef,0x87494ec7,0xd938d1c1,0x8ccaa2fe,0x98d40b36,0xa6f581cf,0xa57ade28,0xdab78e26,0x3fadbfa4,0x2c3a9de4,0x5078920d,0x6a5fcc9b,0x547e4662,0xf68d13c2,0x90d8b8e8,0x2e39f75e,0x82c3aff5,0x9f5d80be,0x69d0937c,0x6fd52da9,0xcf2512b3,0xc8ac993b,0x10187da7,0xe89c636e,0xdb3bbb7b,0xcd267809,0x6e5918f4,0xec9ab701,0x834f9aa8,0xe6956e65,0xaaffe67e,0x21bccf08,0xef15e8e6,0xbae79bd9,0x4a6f36ce,0xea9f09d4,0x29b07cd6,0x31a4b2af,0x2a3f2331,0xc6a59430,0x35a266c0,0x744ebc37,0xfc82caa6,0xe090d0b0,0x33a7d815,0xf104984a,0x41ecdaf7,0x7fcd500e,0x1791f62f,0x764dd68d,0x43efb04d,0xccaa4d54,0xe49604df,0x9ed1b5e3,0x4c6a881b,0xc12c1fb8,0x4665517f,0x9d5eea04,0x018c355d,0xfa877473,0xfb0b412e,0xb3671d5a,0x92dbd252,0xe9105633,0x6dd64713,0x9ad7618c,0x37a10c7a,0x59f8148e,0xeb133c89,0xcea927ee,0xb761c935,0xe11ce5ed,0x7a47b13c,0x9cd2df59,0x55f2733f,0x1814ce79,0x73c737bf,0x53f7cdea,0x5ffdaa5b,0xdf3d6f14,0x7844db86,0xcaaff381,0xb968c43e,0x3824342c,0xc2a3405f,0x161dc372,0xbce2250c,0x283c498b,0xff0d9541,0x39a80171,0x080cb3de,0xd8b4e49c,0x6456c190,0x7bcb8461,0xd532b670,0x486c5c74,0xd0b85742}local E={[0]=0x5051f4a7,0x537e4165,0xc31a17a4,0x963a275e,0xcb3bab6b,0xf11f9d45,0xabacfa58,0x934be303,0x552030fa,0xf6ad766d,0x9188cc76,0x25f5024c,0xfc4fe5d7,0xd7c52acb,0x80263544,0x8fb562a3,0x49deb15a,0x6725ba1b,0x9845ea0e,0xe15dfec0,0x02c32f75,0x12814cf0,0xa38d4697,0xc66bd3f9,0xe7038f5f,0x9515929c,0xebbf6d7a,0xda955259,0x2dd4be83,0xd3587421,0x2949e069,0x448ec9c8,0x6a75c289,0x78f48e79,0x6b99583e,0xdd27b971,0xb6bee14f,0x17f088ad,0x66c920ac,0xb47dce3a,0x1863df4a,0x82e51a31,0x60975133,0x4562537f,0xe0b16477,0x84bb6bae,0x1cfe81a0,0x94f9082b,0x58704868,0x198f45fd,0x8794de6c,0xb7527bf8,0x23ab73d3,0xe2724b02,0x57e31f8f,0x2a6655ab,0x07b2eb28,0x032fb5c2,0x9a86c57b,0xa5d33708,0xf2302887,0xb223bfa5,0xba02036a,0x5ced1682,0x2b8acf1c,0x92a779b4,0xf0f307f2,0xa14e69e2,0xcd65daf4,0xd50605be,0x1fd13462,0x8ac4a6fe,0x9d342e53,0xa0a2f355,0x32058ae1,0x75a4f6eb,0x390b83ec,0xaa4060ef,0x065e719f,0x51bd6e10,0xf93e218a,0x3d96dd06,0xaedd3e05,0x464de6bd,0xb591548d,0x0571c45d,0x6f0406d4,0xff605015,0x241998fb,0x97d6bde9,0xcc894043,0x7767d99e,0xbdb0e842,0x8807898b,0x38e7195b,0xdb79c8ee,0x47a17c0a,0xe97c420f,0xc9f8841e,0x00000000,0x83098086,0x48322bed,0xac1e1170,0x4e6c5a72,0xfbfd0eff,0x560f8538,0x1e3daed5,0x27362d39,0x640a0fd9,0x21685ca6,0xd19b5b54,0x3a24362e,0xb10c0a67,0x0f9357e7,0xd2b4ee96,0x9e1b9b91,0x4f80c0c5,0xa261dc20,0x695a774b,0x161c121a,0x0ae293ba,0xe5c0a02a,0x433c22e0,0x1d121b17,0x0b0e090d,0xadf28bc7,0xb92db6a8,0xc8141ea9,0x8557f119,0x4caf7507,0xbbee99dd,0xfda37f60,0x9ff70126,0xbc5c72f5,0xc544663b,0x345bfb7e,0x768b4329,0xdccb23c6,0x68b6edfc,0x63b8e4f1,0xcad731dc,0x10426385,0x40139722,0x2084c611,0x7d854a24,0xf8d2bb3d,0x11aef932,0x6dc729a1,0x4b1d9e2f,0xf3dcb230,0xec0d8652,0xd077c1e3,0x6c2bb316,0x99a970b9,0xfa119448,0x2247e964,0xc4a8fc8c,0x1aa0f03f,0xd8567d2c,0xef223390,0xc787494e,0xc1d938d1,0xfe8ccaa2,0x3698d40b,0xcfa6f581,0x28a57ade,0x26dab78e,0xa43fadbf,0xe42c3a9d,0x0d507892,0x9b6a5fcc,0x62547e46,0xc2f68d13,0xe890d8b8,0x5e2e39f7,0xf582c3af,0xbe9f5d80,0x7c69d093,0xa96fd52d,0xb3cf2512,0x3bc8ac99,0xa710187d,0x6ee89c63,0x7bdb3bbb,0x09cd2678,0xf46e5918,0x01ec9ab7,0xa8834f9a,0x65e6956e,0x7eaaffe6,0x0821bccf,0xe6ef15e8,0xd9bae79b,0xce4a6f36,0xd4ea9f09,0xd629b07c,0xaf31a4b2,0x312a3f23,0x30c6a594,0xc035a266,0x37744ebc,0xa6fc82ca,0xb0e090d0,0x1533a7d8,0x4af10498,0xf741ecda,0x0e7fcd50,0x2f1791f6,0x8d764dd6,0x4d43efb0,0x54ccaa4d,0xdfe49604,0xe39ed1b5,0x1b4c6a88,0xb8c12c1f,0x7f466551,0x049d5eea,0x5d018c35,0x73fa8774,0x2efb0b41,0x5ab3671d,0x5292dbd2,0x33e91056,0x136dd647,0x8c9ad761,0x7a37a10c,0x8e59f814,0x89eb133c,0xeecea927,0x35b761c9,0xede11ce5,0x3c7a47b1,0x599cd2df,0x3f55f273,0x791814ce,0xbf73c737,0xea53f7cd,0x5b5ffdaa,0x14df3d6f,0x867844db,0x81caaff3,0x3eb968c4,0x2c382434,0x5fc2a340,0x72161dc3,0x0cbce225,0x8b283c49,0x41ff0d95,0x7139a801,0xde080cb3,0x9cd8b4e4,0x906456c1,0x617bcb84,0x70d532b6,0x74486c5c,0x42d0b857}local F={[0]=0xa75051f4,0x65537e41,0xa4c31a17,0x5e963a27,0x6bcb3bab,0x45f11f9d,0x58abacfa,0x03934be3,0xfa552030,0x6df6ad76,0x769188cc,0x4c25f502,0xd7fc4fe5,0xcbd7c52a,0x44802635,0xa38fb562,0x5a49deb1,0x1b6725ba,0x0e9845ea,0xc0e15dfe,0x7502c32f,0xf012814c,0x97a38d46,0xf9c66bd3,0x5fe7038f,0x9c951592,0x7aebbf6d,0x59da9552,0x832dd4be,0x21d35874,0x692949e0,0xc8448ec9,0x896a75c2,0x7978f48e,0x3e6b9958,0x71dd27b9,0x4fb6bee1,0xad17f088,0xac66c920,0x3ab47dce,0x4a1863df,0x3182e51a,0x33609751,0x7f456253,0x77e0b164,0xae84bb6b,0xa01cfe81,0x2b94f908,0x68587048,0xfd198f45,0x6c8794de,0xf8b7527b,0xd323ab73,0x02e2724b,0x8f57e31f,0xab2a6655,0x2807b2eb,0xc2032fb5,0x7b9a86c5,0x08a5d337,0x87f23028,0xa5b223bf,0x6aba0203,0x825ced16,0x1c2b8acf,0xb492a779,0xf2f0f307,0xe2a14e69,0xf4cd65da,0xbed50605,0x621fd134,0xfe8ac4a6,0x539d342e,0x55a0a2f3,0xe132058a,0xeb75a4f6,0xec390b83,0xefaa4060,0x9f065e71,0x1051bd6e,0x8af93e21,0x063d96dd,0x05aedd3e,0xbd464de6,0x8db59154,0x5d0571c4,0xd46f0406,0x15ff6050,0xfb241998,0xe997d6bd,0x43cc8940,0x9e7767d9,0x42bdb0e8,0x8b880789,0x5b38e719,0xeedb79c8,0x0a47a17c,0x0fe97c42,0x1ec9f884,0x00000000,0x86830980,0xed48322b,0x70ac1e11,0x724e6c5a,0xfffbfd0e,0x38560f85,0xd51e3dae,0x3927362d,0xd9640a0f,0xa621685c,0x54d19b5b,0x2e3a2436,0x67b10c0a,0xe70f9357,0x96d2b4ee,0x919e1b9b,0xc54f80c0,0x20a261dc,0x4b695a77,0x1a161c12,0xba0ae293,0x2ae5c0a0,0xe0433c22,0x171d121b,0x0d0b0e09,0xc7adf28b,0xa8b92db6,0xa9c8141e,0x198557f1,0x074caf75,0xddbbee99,0x60fda37f,0x269ff701,0xf5bc5c72,0x3bc54466,0x7e345bfb,0x29768b43,0xc6dccb23,0xfc68b6ed,0xf163b8e4,0xdccad731,0x85104263,0x22401397,0x112084c6,0x247d854a,0x3df8d2bb,0x3211aef9,0xa16dc729,0x2f4b1d9e,0x30f3dcb2,0x52ec0d86,0xe3d077c1,0x166c2bb3,0xb999a970,0x48fa1194,0x642247e9,0x8cc4a8fc,0x3f1aa0f0,0x2cd8567d,0x90ef2233,0x4ec78749,0xd1c1d938,0xa2fe8cca,0x0b3698d4,0x81cfa6f5,0xde28a57a,0x8e26dab7,0xbfa43fad,0x9de42c3a,0x920d5078,0xcc9b6a5f,0x4662547e,0x13c2f68d,0xb8e890d8,0xf75e2e39,0xaff582c3,0x80be9f5d,0x937c69d0,0x2da96fd5,0x12b3cf25,0x993bc8ac,0x7da71018,0x636ee89c,0xbb7bdb3b,0x7809cd26,0x18f46e59,0xb701ec9a,0x9aa8834f,0x6e65e695,0xe67eaaff,0xcf0821bc,0xe8e6ef15,0x9bd9bae7,0x36ce4a6f,0x09d4ea9f,0x7cd629b0,0xb2af31a4,0x23312a3f,0x9430c6a5,0x66c035a2,0xbc37744e,0xcaa6fc82,0xd0b0e090,0xd81533a7,0x984af104,0xdaf741ec,0x500e7fcd,0xf62f1791,0xd68d764d,0xb04d43ef,0x4d54ccaa,0x04dfe496,0xb5e39ed1,0x881b4c6a,0x1fb8c12c,0x517f4665,0xea049d5e,0x355d018c,0x7473fa87,0x412efb0b,0x1d5ab367,0xd25292db,0x5633e910,0x47136dd6,0x618c9ad7,0x0c7a37a1,0x148e59f8,0x3c89eb13,0x27eecea9,0xc935b761,0xe5ede11c,0xb13c7a47,0xdf599cd2,0x733f55f2,0xce791814,0x37bf73c7,0xcdea53f7,0xaa5b5ffd,0x6f14df3d,0xdb867844,0xf381caaf,0xc43eb968,0x342c3824,0x405fc2a3,0xc372161d,0x250cbce2,0x498b283c,0x9541ff0d,0x017139a8,0xb3de080c,0xe49cd8b4,0xc1906456,0x84617bcb,0xb670d532,0x5c74486c,0x5742d0b8}local G={[0]=0xf4a75051,0x4165537e,0x17a4c31a,0x275e963a,0xab6bcb3b,0x9d45f11f,0xfa58abac,0xe303934b,0x30fa5520,0x766df6ad,0xcc769188,0x024c25f5,0xe5d7fc4f,0x2acbd7c5,0x35448026,0x62a38fb5,0xb15a49de,0xba1b6725,0xea0e9845,0xfec0e15d,0x2f7502c3,0x4cf01281,0x4697a38d,0xd3f9c66b,0x8f5fe703,0x929c9515,0x6d7aebbf,0x5259da95,0xbe832dd4,0x7421d358,0xe0692949,0xc9c8448e,0xc2896a75,0x8e7978f4,0x583e6b99,0xb971dd27,0xe14fb6be,0x88ad17f0,0x20ac66c9,0xce3ab47d,0xdf4a1863,0x1a3182e5,0x51336097,0x537f4562,0x6477e0b1,0x6bae84bb,0x81a01cfe,0x082b94f9,0x48685870,0x45fd198f,0xde6c8794,0x7bf8b752,0x73d323ab,0x4b02e272,0x1f8f57e3,0x55ab2a66,0xeb2807b2,0xb5c2032f,0xc57b9a86,0x3708a5d3,0x2887f230,0xbfa5b223,0x036aba02,0x16825ced,0xcf1c2b8a,0x79b492a7,0x07f2f0f3,0x69e2a14e,0xdaf4cd65,0x05bed506,0x34621fd1,0xa6fe8ac4,0x2e539d34,0xf355a0a2,0x8ae13205,0xf6eb75a4,0x83ec390b,0x60efaa40,0x719f065e,0x6e1051bd,0x218af93e,0xdd063d96,0x3e05aedd,0xe6bd464d,0x548db591,0xc45d0571,0x06d46f04,0x5015ff60,0x98fb2419,0xbde997d6,0x4043cc89,0xd99e7767,0xe842bdb0,0x898b8807,0x195b38e7,0xc8eedb79,0x7c0a47a1,0x420fe97c,0x841ec9f8,0x00000000,0x80868309,0x2bed4832,0x1170ac1e,0x5a724e6c,0x0efffbfd,0x8538560f,0xaed51e3d,0x2d392736,0x0fd9640a,0x5ca62168,0x5b54d19b,0x362e3a24,0x0a67b10c,0x57e70f93,0xee96d2b4,0x9b919e1b,0xc0c54f80,0xdc20a261,0x774b695a,0x121a161c,0x93ba0ae2,0xa02ae5c0,0x22e0433c,0x1b171d12,0x090d0b0e,0x8bc7adf2,0xb6a8b92d,0x1ea9c814,0xf1198557,0x75074caf,0x99ddbbee,0x7f60fda3,0x01269ff7,0x72f5bc5c,0x663bc544,0xfb7e345b,0x4329768b,0x23c6dccb,0xedfc68b6,0xe4f163b8,0x31dccad7,0x63851042,0x97224013,0xc6112084,0x4a247d85,0xbb3df8d2,0xf93211ae,0x29a16dc7,0x9e2f4b1d,0xb230f3dc,0x8652ec0d,0xc1e3d077,0xb3166c2b,0x70b999a9,0x9448fa11,0xe9642247,0xfc8cc4a8,0xf03f1aa0,0x7d2cd856,0x3390ef22,0x494ec787,0x38d1c1d9,0xcaa2fe8c,0xd40b3698,0xf581cfa6,0x7ade28a5,0xb78e26da,0xadbfa43f,0x3a9de42c,0x78920d50,0x5fcc9b6a,0x7e466254,0x8d13c2f6,0xd8b8e890,0x39f75e2e,0xc3aff582,0x5d80be9f,0xd0937c69,0xd52da96f,0x2512b3cf,0xac993bc8,0x187da710,0x9c636ee8,0x3bbb7bdb,0x267809cd,0x5918f46e,0x9ab701ec,0x4f9aa883,0x956e65e6,0xffe67eaa,0xbccf0821,0x15e8e6ef,0xe79bd9ba,0x6f36ce4a,0x9f09d4ea,0xb07cd629,0xa4b2af31,0x3f23312a,0xa59430c6,0xa266c035,0x4ebc3774,0x82caa6fc,0x90d0b0e0,0xa7d81533,0x04984af1,0xecdaf741,0xcd500e7f,0x91f62f17,0x4dd68d76,0xefb04d43,0xaa4d54cc,0x9604dfe4,0xd1b5e39e,0x6a881b4c,0x2c1fb8c1,0x65517f46,0x5eea049d,0x8c355d01,0x877473fa,0x0b412efb,0x671d5ab3,0xdbd25292,0x105633e9,0xd647136d,0xd7618c9a,0xa10c7a37,0xf8148e59,0x133c89eb,0xa927eece,0x61c935b7,0x1ce5ede1,0x47b13c7a,0xd2df599c,0xf2733f55,0x14ce7918,0xc737bf73,0xf7cdea53,0xfdaa5b5f,0x3d6f14df,0x44db8678,0xaff381ca,0x68c43eb9,0x24342c38,0xa3405fc2,0x1dc37216,0xe2250cbc,0x3c498b28,0x0d9541ff,0xa8017139,0x0cb3de08,0xb4e49cd8,0x56c19064,0xcb84617b,0x32b670d5,0x6c5c7448,0xb85742d0}local function H(I,J)local K,L,M,N=J[1],J[2],J[3],J[4]K=c(K,I[1])L=c(L,I[2])M=c(M,I[3])N=c(N,I[4])local O=#I/4-2;local P=4;local Q,R,S,T;for o=1,O do Q=c(I[P+1],c(z[p(h(K,24))],c(A[p(h(L,16))],c(B[p(h(M,8))],C[p(N)]))))R=c(I[P+2],c(z[p(h(L,24))],c(A[p(h(M,16))],c(B[p(h(N,8))],C[p(K)]))))S=c(I[P+3],c(z[p(h(M,24))],c(A[p(h(N,16))],c(B[p(h(K,8))],C[p(L)]))))T=c(I[P+4],c(z[p(h(N,24))],c(A[p(h(K,16))],c(B[p(h(L,8))],C[p(M)]))))P=P+4;K,L,M,N=Q,R,S,T end;K=b(e(x[p(h(Q,24))],24),b(e(x[p(h(R,16))],16),b(e(x[p(h(S,8))],8),x[p(T)])))L=b(e(x[p(h(R,24))],24),b(e(x[p(h(S,16))],16),b(e(x[p(h(T,8))],8),x[p(Q)])))M=b(e(x[p(h(S,24))],24),b(e(x[p(h(T,16))],16),b(e(x[p(h(Q,8))],8),x[p(R)])))N=b(e(x[p(h(T,24))],24),b(e(x[p(h(Q,16))],16),b(e(x[p(h(R,8))],8),x[p(S)])))K=c(K,I[P+1])L=c(L,I[P+2])M=c(M,I[P+3])N=c(N,I[P+4])return{K,L,M,N}end;local function U(I,J)local K,L,M,N=J[1],J[2],J[3],J[4]K=c(K,I[1])L=c(L,I[2])M=c(M,I[3])N=c(N,I[4])local O=#I/4-2;local P=4;local Q,R,S,T;for o=1,O do Q=c(I[P+1],c(D[p(h(K,24))],c(E[p(h(N,16))],c(F[p(h(M,8))],G[p(L)]))))R=c(I[P+2],c(D[p(h(L,24))],c(E[p(h(K,16))],c(F[p(h(N,8))],G[p(M)]))))S=c(I[P+3],c(D[p(h(M,24))],c(E[p(h(L,16))],c(F[p(h(K,8))],G[p(N)]))))T=c(I[P+4],c(D[p(h(N,24))],c(E[p(h(M,16))],c(F[p(h(L,8))],G[p(K)]))))P=P+4;K,L,M,N=Q,R,S,T end;K=b(e(y[p(h(Q,24))],24),b(e(y[p(h(T,16))],16),b(e(y[p(h(S,8))],8),y[p(R)])))L=b(e(y[p(h(R,24))],24),b(e(y[p(h(Q,16))],16),b(e(y[p(h(T,8))],8),y[p(S)])))M=b(e(y[p(h(S,24))],24),b(e(y[p(h(R,16))],16),b(e(y[p(h(Q,8))],8),y[p(T)])))N=b(e(y[p(h(T,24))],24),b(e(y[p(h(S,16))],16),b(e(y[p(h(R,8))],8),y[p(Q)])))K=c(K,I[P+1])L=c(L,I[P+2])M=c(M,I[P+3])N=c(N,I[P+4])return{K,L,M,N}end;local function V(W)return c(e(x[p(h(W,24))],24),c(e(x[p(h(W,16))],16),c(e(x[p(h(W,8))],8),x[p(W)])))end;local function X(W)return b(e(W,8),h(W,24))end;local function Y(Z)local _=#Z+28;local a0,a1={},{}local a2=#Z/4;for n=1,a2 do a0[n]=q({string.byte(Z,(n-1)*4+1,n*4)})end;for n=a2,_-1 do local a3=a0[n]if n%a2==0 then local Q=a3;a3=c(V(X(a3)),e(w[n/a2],24))elseif a2>6 and n%a2==4 then a3=V(a3)end;a0[n+1]=c(a0[n-a2+1],a3)end;for n=0,_-1,4 do local a4=_-n-4;for a5=1,4 do local a6=a0[a4+a5]if n>0 and n+4<_ then a6=c(D[x[p(h(a6,24))]],c(E[x[p(h(a6,16))]],c(F[x[p(h(a6,8))]],G[x[p(a6)]])))end;a1[n+a5]=a6 end end;return a0,a1 end;local function a7(J)local a8=#J%16;if a8==0 then return J end;return J..string.rep('\\x00',16-a8)end;Cipher={_enc=nil,_dec=nil,enc_vec=nil,dec_vec=nil}function Cipher:new(a9,Z,aa)a9=a9 or{}setmetatable(a9,{__index=self})assert(string.len(Z)==16 or string.len(Z)==24 or string.len(Z)==32)a9._enc,a9._dec=Y(Z)a9.enc_vec=aa or{0,0,0,0}a9.dec_vec=a9.enc_vec;return a9 end;function Cipher:encryptB(J)assert(#J==16)return v(H(self._enc,t(J)))end;function Cipher:decryptB(J)assert(#J==16)return v(H(self._dec,t(J)))end;function Cipher:encrypt(J)local u=a7(J)local ab=''for n=1,#u,16 do self.enc_vec=H(self._enc,self.enc_vec)ab=ab..v(i(self.enc_vec,t(string.sub(u,n,n+15))))end;return string.sub(ab,0,#J)end;function Cipher:decrypt(J)local u=a7(J)local ab=''for n=1,#u,16 do self.dec_vec=H(self._enc,self.dec_vec)ab=ab..v(i(self.dec_vec,t(string.sub(u,n,n+15))))end;return string.sub(ab,0,#J)end\
",
    ["server/dispatchers/account.lua"] = "local a=require\"lib.errors\"local b=require\"network.message\"local c={}function c.login(d,e,f,g,h)local i=d.payload.username;local j=d.payload.password;local k=d.payload.aesKey;local l=g.accounts.authenticateUser(i,j)if not k or k==\"\"or#k~=16 then return a.MALFORMED_MESSAGE end;if l==0 then local m=h.clientManager.registerClient(i,k)if not m.throttle then return m end;local d=b.create(\"account\",{action=\"login\",status=\"success\",token=m.token,channel=m.channel},m.aesKey)d.id=f;h:send(h.discovery,textutils.serialize({plaintext=false,message=d}))else local d=b.create(\"account\",{action=\"login\",status=\"failure\",error=l[1]})d.id=f;h:send(h.discovery,textutils.serialize({plaintext=true,message=d}))end;return 0 end;function c.info(d,m,f,g,h)end;local function n(d,m,f,g,h)if not c[d.payload.action]then return a.MALFORMED_MESSAGE end;if m and d.payload.token~=m.token then return a.TOKEN_MISMATCH end;return c[d.payload.action](d,m,f,g,h)end;return n\
",
    ["server/setupwizard.lua"] = "local a=false;local b=shell and{}or(_ENV or getfenv())b.versionName=\"Bigfont By Wojbie\"b.versionNum=5.003;b.doc={}local c,d;if require then c,d=require\"cc.expect\".expect,require\"cc.expect\".field else local e,f=pcall(dofile,\"rom/modules/main/cc/expect.lua\")if e then d,c=f.field,f.expect else d,c=function()end,function()end end end;local g={{\"\\32\\32\\32\\137\\156\\148\\158\\159\\148\\135\\135\\144\\159\\139\\32\\136\\157\\32\\159\\139\\32\\32\\143\\32\\32\\143\\32\\32\\32\\32\\32\\32\\32\\32\\147\\148\\150\\131\\148\\32\\32\\32\\151\\140\\148\\151\\140\\147\",\"\\32\\32\\32\\149\\132\\149\\136\\156\\149\\144\\32\\133\\139\\159\\129\\143\\159\\133\\143\\159\\133\\138\\32\\133\\138\\32\\133\\32\\32\\32\\32\\32\\32\\150\\150\\129\\137\\156\\129\\32\\32\\32\\133\\131\\129\\133\\131\\132\",\"\\32\\32\\32\\130\\131\\32\\130\\131\\32\\32\\129\\32\\32\\32\\32\\130\\131\\32\\130\\131\\32\\32\\32\\32\\143\\143\\143\\32\\32\\32\\32\\32\\32\\130\\129\\32\\130\\135\\32\\32\\32\\32\\131\\32\\32\\131\\32\\131\",\"\\139\\144\\32\\32\\143\\148\\135\\130\\144\\149\\32\\149\\150\\151\\149\\158\\140\\129\\32\\32\\32\\135\\130\\144\\135\\130\\144\\32\\149\\32\\32\\139\\32\\159\\148\\32\\32\\32\\32\\159\\32\\144\\32\\148\\32\\147\\131\\132\",\"\\159\\135\\129\\131\\143\\149\\143\\138\\144\\138\\32\\133\\130\\149\\149\\137\\155\\149\\159\\143\\144\\147\\130\\132\\32\\149\\32\\147\\130\\132\\131\\159\\129\\139\\151\\129\\148\\32\\32\\139\\131\\135\\133\\32\\144\\130\\151\\32\",\"\\32\\32\\32\\32\\32\\32\\130\\135\\32\\130\\32\\129\\32\\129\\129\\131\\131\\32\\130\\131\\129\\140\\141\\132\\32\\129\\32\\32\\129\\32\\32\\32\\32\\32\\32\\32\\131\\131\\129\\32\\32\\32\\32\\32\\32\\32\\32\\32\",\"\\32\\32\\32\\32\\149\\32\\159\\154\\133\\133\\133\\144\\152\\141\\132\\133\\151\\129\\136\\153\\32\\32\\154\\32\\159\\134\\129\\130\\137\\144\\159\\32\\144\\32\\148\\32\\32\\32\\32\\32\\32\\32\\32\\32\\32\\32\\151\\129\",\"\\32\\32\\32\\32\\133\\32\\32\\32\\32\\145\\145\\132\\141\\140\\132\\151\\129\\144\\150\\146\\129\\32\\32\\32\\138\\144\\32\\32\\159\\133\\136\\131\\132\\131\\151\\129\\32\\144\\32\\131\\131\\129\\32\\144\\32\\151\\129\\32\",\"\\32\\32\\32\\32\\129\\32\\32\\32\\32\\130\\130\\32\\32\\129\\32\\129\\32\\129\\130\\129\\129\\32\\32\\32\\32\\130\\129\\130\\129\\32\\32\\32\\32\\32\\32\\32\\32\\133\\32\\32\\32\\32\\32\\129\\32\\129\\32\\32\",\"\\150\\156\\148\\136\\149\\32\\134\\131\\148\\134\\131\\148\\159\\134\\149\\136\\140\\129\\152\\131\\32\\135\\131\\149\\150\\131\\148\\150\\131\\148\\32\\148\\32\\32\\148\\32\\32\\152\\129\\143\\143\\144\\130\\155\\32\\134\\131\\148\",\"\\157\\129\\149\\32\\149\\32\\152\\131\\144\\144\\131\\148\\141\\140\\149\\144\\32\\149\\151\\131\\148\\32\\150\\32\\150\\131\\148\\130\\156\\133\\32\\144\\32\\32\\144\\32\\130\\155\\32\\143\\143\\144\\32\\152\\129\\32\\134\\32\",\"\\130\\131\\32\\131\\131\\129\\131\\131\\129\\130\\131\\32\\32\\32\\129\\130\\131\\32\\130\\131\\32\\32\\129\\32\\130\\131\\32\\130\\129\\32\\32\\129\\32\\32\\133\\32\\32\\32\\129\\32\\32\\32\\130\\32\\32\\32\\129\\32\",\"\\150\\140\\150\\137\\140\\148\\136\\140\\132\\150\\131\\132\\151\\131\\148\\136\\147\\129\\136\\147\\129\\150\\156\\145\\138\\143\\149\\130\\151\\32\\32\\32\\149\\138\\152\\129\\149\\32\\32\\157\\152\\149\\157\\144\\149\\150\\131\\148\",\"\\149\\143\\142\\149\\32\\149\\149\\32\\149\\149\\32\\144\\149\\32\\149\\149\\32\\32\\149\\32\\32\\149\\32\\149\\149\\32\\149\\32\\149\\32\\144\\32\\149\\149\\130\\148\\149\\32\\32\\149\\32\\149\\149\\130\\149\\149\\32\\149\",\"\\130\\131\\129\\129\\32\\129\\131\\131\\32\\130\\131\\32\\131\\131\\32\\131\\131\\129\\129\\32\\32\\130\\131\\32\\129\\32\\129\\130\\131\\32\\130\\131\\32\\129\\32\\129\\131\\131\\129\\129\\32\\129\\129\\32\\129\\130\\131\\32\",\"\\136\\140\\132\\150\\131\\148\\136\\140\\132\\153\\140\\129\\131\\151\\129\\149\\32\\149\\149\\32\\149\\149\\32\\149\\137\\152\\129\\137\\152\\129\\131\\156\\133\\149\\131\\32\\150\\32\\32\\130\\148\\32\\152\\137\\144\\32\\32\\32\",\"\\149\\32\\32\\149\\159\\133\\149\\32\\149\\144\\32\\149\\32\\149\\32\\149\\32\\149\\150\\151\\129\\138\\155\\149\\150\\130\\148\\32\\149\\32\\152\\129\\32\\149\\32\\32\\32\\150\\32\\32\\149\\32\\32\\32\\32\\32\\32\\32\",\"\\129\\32\\32\\130\\129\\129\\129\\32\\129\\130\\131\\32\\32\\129\\32\\130\\131\\32\\32\\129\\32\\129\\32\\129\\129\\32\\129\\32\\129\\32\\131\\131\\129\\130\\131\\32\\32\\32\\129\\130\\131\\32\\32\\32\\32\\140\\140\\132\",\"\\32\\154\\32\\159\\143\\32\\149\\143\\32\\159\\143\\32\\159\\144\\149\\159\\143\\32\\159\\137\\145\\159\\143\\144\\149\\143\\32\\32\\145\\32\\32\\32\\145\\149\\32\\144\\32\\149\\32\\143\\159\\32\\143\\143\\32\\159\\143\\32\",\"\\32\\32\\32\\152\\140\\149\\151\\32\\149\\149\\32\\145\\149\\130\\149\\157\\140\\133\\32\\149\\32\\154\\143\\149\\151\\32\\149\\32\\149\\32\\144\\32\\149\\149\\153\\32\\32\\149\\32\\149\\133\\149\\149\\32\\149\\149\\32\\149\",\"\\32\\32\\32\\130\\131\\129\\131\\131\\32\\130\\131\\32\\130\\131\\129\\130\\131\\129\\32\\129\\32\\140\\140\\129\\129\\32\\129\\32\\129\\32\\137\\140\\129\\130\\32\\129\\32\\130\\32\\129\\32\\129\\129\\32\\129\\130\\131\\32\",\"\\144\\143\\32\\159\\144\\144\\144\\143\\32\\159\\143\\144\\159\\138\\32\\144\\32\\144\\144\\32\\144\\144\\32\\144\\144\\32\\144\\144\\32\\144\\143\\143\\144\\32\\150\\129\\32\\149\\32\\130\\150\\32\\134\\137\\134\\134\\131\\148\",\"\\136\\143\\133\\154\\141\\149\\151\\32\\129\\137\\140\\144\\32\\149\\32\\149\\32\\149\\154\\159\\133\\149\\148\\149\\157\\153\\32\\154\\143\\149\\159\\134\\32\\130\\148\\32\\32\\149\\32\\32\\151\\129\\32\\32\\32\\32\\134\\32\",\"\\133\\32\\32\\32\\32\\133\\129\\32\\32\\131\\131\\32\\32\\130\\32\\130\\131\\129\\32\\129\\32\\130\\131\\129\\129\\32\\129\\140\\140\\129\\131\\131\\129\\32\\130\\129\\32\\129\\32\\130\\129\\32\\32\\32\\32\\32\\129\\32\",\"\\32\\32\\32\\32\\149\\32\\32\\149\\32\\32\\32\\32\\32\\32\\32\\32\\149\\32\\32\\149\\32\\32\\32\\32\\32\\32\\32\\32\\149\\32\\32\\149\\32\\32\\32\\32\\32\\32\\32\\32\\149\\32\\32\\149\\32\\32\\32\\32\",\"\\32\\32\\32\\32\\32\\32\\32\\32\\32\\32\\32\\32\\32\\149\\32\\32\\149\\32\\32\\149\\32\\32\\149\\32\\32\\149\\32\\32\\149\\32\\32\\149\\32\\32\\149\\32\\32\\32\\32\\32\\32\\32\\32\\32\\32\\32\\32\\32\",\"\\32\\32\\32\\32\\32\\32\\32\\32\\32\\32\\32\\32\\32\\32\\32\\32\\32\\32\\32\\32\\32\\32\\32\\32\\32\\32\\32\\32\\32\\32\\32\\32\\32\\32\\32\\32\\32\\32\\32\\32\\32\\32\\32\\32\\32\\32\\32\\32\",\"\\32\\32\\32\\32\\149\\32\\32\\149\\32\\32\\32\\32\\32\\32\\32\\32\\149\\32\\32\\149\\32\\32\\32\\32\\32\\32\\32\\32\\149\\32\\32\\149\\32\\32\\32\\32\\32\\32\\32\\32\\149\\32\\32\\149\\32\\32\\32\\32\",\"\\32\\32\\32\\32\\32\\32\\32\\32\\32\\32\\32\\32\\32\\149\\32\\32\\149\\32\\32\\149\\32\\32\\149\\32\\32\\149\\32\\32\\149\\32\\32\\149\\32\\32\\149\\32\\32\\32\\32\\32\\32\\32\\32\\32\\32\\32\\32\\32\",\"\\32\\149\\32\\32\\149\\32\\32\\149\\32\\32\\149\\32\\32\\149\\32\\32\\149\\32\\32\\149\\32\\32\\149\\32\\32\\149\\32\\32\\149\\32\\32\\149\\32\\32\\149\\32\\32\\149\\32\\32\\149\\32\\32\\149\\32\\32\\149\\32\",\"\\32\\32\\32\\32\\145\\32\\159\\139\\32\\151\\131\\132\\155\\143\\132\\134\\135\\145\\32\\149\\32\\158\\140\\129\\130\\130\\32\\152\\147\\155\\157\\134\\32\\32\\144\\144\\32\\32\\32\\32\\32\\32\\152\\131\\155\\131\\131\\129\",\"\\32\\32\\32\\32\\149\\32\\149\\32\\145\\148\\131\\32\\149\\32\\149\\140\\157\\132\\32\\148\\32\\137\\155\\149\\32\\32\\32\\149\\154\\149\\137\\142\\32\\153\\153\\32\\131\\131\\149\\131\\131\\129\\149\\135\\145\\32\\32\\32\",\"\\32\\32\\32\\32\\129\\32\\130\\135\\32\\131\\131\\129\\134\\131\\132\\32\\129\\32\\32\\129\\32\\131\\131\\32\\32\\32\\32\\130\\131\\129\\32\\32\\32\\32\\129\\129\\32\\32\\32\\32\\32\\32\\130\\131\\129\\32\\32\\32\",\"\\150\\150\\32\\32\\148\\32\\134\\32\\32\\132\\32\\32\\134\\32\\32\\144\\32\\144\\150\\151\\149\\32\\32\\32\\32\\32\\32\\145\\32\\32\\152\\140\\144\\144\\144\\32\\133\\151\\129\\133\\151\\129\\132\\151\\129\\32\\145\\32\",\"\\130\\129\\32\\131\\151\\129\\141\\32\\32\\142\\32\\32\\32\\32\\32\\149\\32\\149\\130\\149\\149\\32\\143\\32\\32\\32\\32\\142\\132\\32\\154\\143\\133\\157\\153\\132\\151\\150\\148\\151\\158\\132\\151\\150\\148\\144\\130\\148\",\"\\32\\32\\32\\140\\140\\132\\32\\32\\32\\32\\32\\32\\32\\32\\32\\151\\131\\32\\32\\129\\129\\32\\32\\32\\32\\134\\32\\32\\32\\32\\32\\32\\32\\129\\129\\32\\129\\32\\129\\129\\130\\129\\129\\32\\129\\130\\131\\32\",\"\\156\\143\\32\\159\\141\\129\\153\\140\\132\\153\\137\\32\\157\\141\\32\\159\\142\\32\\150\\151\\129\\150\\131\\132\\140\\143\\144\\143\\141\\145\\137\\140\\148\\141\\141\\144\\157\\142\\32\\159\\140\\32\\151\\134\\32\\157\\141\\32\",\"\\157\\140\\149\\157\\140\\149\\157\\140\\149\\157\\140\\149\\157\\140\\149\\157\\140\\149\\151\\151\\32\\154\\143\\132\\157\\140\\32\\157\\140\\32\\157\\140\\32\\157\\140\\32\\32\\149\\32\\32\\149\\32\\32\\149\\32\\32\\149\\32\",\"\\129\\32\\129\\129\\32\\129\\129\\32\\129\\129\\32\\129\\129\\32\\129\\129\\32\\129\\129\\131\\129\\32\\134\\32\\131\\131\\129\\131\\131\\129\\131\\131\\129\\131\\131\\129\\130\\131\\32\\130\\131\\32\\130\\131\\32\\130\\131\\32\",\"\\151\\131\\148\\152\\137\\145\\155\\140\\144\\152\\142\\145\\153\\140\\132\\153\\137\\32\\154\\142\\144\\155\\159\\132\\150\\156\\148\\147\\32\\144\\144\\130\\145\\136\\137\\32\\146\\130\\144\\144\\130\\145\\130\\136\\32\\151\\140\\132\",\"\\151\\32\\149\\151\\155\\149\\149\\32\\149\\149\\32\\149\\149\\32\\149\\149\\32\\149\\149\\32\\149\\152\\137\\144\\157\\129\\149\\149\\32\\149\\149\\32\\149\\149\\32\\149\\149\\32\\149\\130\\150\\32\\32\\157\\129\\149\\32\\149\",\"\\131\\131\\32\\129\\32\\129\\130\\131\\32\\130\\131\\32\\130\\131\\32\\130\\131\\32\\130\\131\\32\\32\\32\\32\\130\\131\\32\\130\\131\\32\\130\\131\\32\\130\\131\\32\\130\\131\\32\\32\\129\\32\\130\\131\\32\\133\\131\\32\",\"\\156\\143\\32\\159\\141\\129\\153\\140\\132\\153\\137\\32\\157\\141\\32\\159\\142\\32\\159\\159\\144\\152\\140\\144\\156\\143\\32\\159\\141\\129\\153\\140\\132\\157\\141\\32\\130\\145\\32\\32\\147\\32\\136\\153\\32\\130\\146\\32\",\"\\152\\140\\149\\152\\140\\149\\152\\140\\149\\152\\140\\149\\152\\140\\149\\152\\140\\149\\149\\157\\134\\154\\143\\132\\157\\140\\133\\157\\140\\133\\157\\140\\133\\157\\140\\133\\32\\149\\32\\32\\149\\32\\32\\149\\32\\32\\149\\32\",\"\\130\\131\\129\\130\\131\\129\\130\\131\\129\\130\\131\\129\\130\\131\\129\\130\\131\\129\\130\\130\\131\\32\\134\\32\\130\\131\\129\\130\\131\\129\\130\\131\\129\\130\\131\\129\\32\\129\\32\\32\\129\\32\\32\\129\\32\\32\\129\\32\",\"\\159\\134\\144\\137\\137\\32\\156\\143\\32\\159\\141\\129\\153\\140\\132\\153\\137\\32\\157\\141\\32\\32\\132\\32\\159\\143\\32\\147\\32\\144\\144\\130\\145\\136\\137\\32\\146\\130\\144\\144\\130\\145\\130\\138\\32\\146\\130\\144\",\"\\149\\32\\149\\149\\32\\149\\149\\32\\149\\149\\32\\149\\149\\32\\149\\149\\32\\149\\149\\32\\149\\131\\147\\129\\138\\134\\149\\149\\32\\149\\149\\32\\149\\149\\32\\149\\149\\32\\149\\154\\143\\149\\32\\157\\129\\154\\143\\149\",\"\\130\\131\\32\\129\\32\\129\\130\\131\\32\\130\\131\\32\\130\\131\\32\\130\\131\\32\\130\\131\\32\\32\\32\\32\\130\\131\\32\\130\\131\\129\\130\\131\\129\\130\\131\\129\\130\\131\\129\\140\\140\\129\\130\\131\\32\\140\\140\\129\"},{[[000110000110110000110010101000000010000000100101]],[[000000110110000000000010101000000010000000100101]],[[000000000000000000000000000000000000000000000000]],[[100010110100000010000110110000010100000100000110]],[[000000110000000010110110000110000000000000110000]],[[000000000000000000000000000000000000000000000000]],[[000000110110000010000000100000100000000000000010]],[[000000000110110100010000000010000000000000000100]],[[000000000000000000000000000000000000000000000000]],[[010000000000100110000000000000000000000110010000]],[[000000000000000000000000000010000000010110000000]],[[000000000000000000000000000000000000000000000000]],[[011110110000000100100010110000000100000000000000]],[[000000000000000000000000000000000000000000000000]],[[000000000000000000000000000000000000000000000000]],[[110000110110000000000000000000010100100010000000]],[[000010000000000000110110000000000100010010000000]],[[000000000000000000000000000000000000000000000000]],[[010110010110100110110110010000000100000110110110]],[[000000000000000000000110000000000110000000000000]],[[000000000000000000000000000000000000000000000000]],[[010100010110110000000000000000110000000010000000]],[[110110000000000000110000110110100000000010000000]],[[000000000000000000000000000000000000000000000000]],[[000100011111000100011111000100011111000100011111]],[[000000000000100100100100011011011011111111111111]],[[000000000000000000000000000000000000000000000000]],[[000100011111000100011111000100011111000100011111]],[[000000000000100100100100011011011011111111111111]],[[100100100100100100100100100100100100100100100100]],[[000000110100110110000010000011110000000000011000]],[[000000000100000000000010000011000110000000001000]],[[000000000000000000000000000000000000000000000000]],[[010000100100000000000000000100000000010010110000]],[[000000000000000000000000000000110110110110110000]],[[000000000000000000000000000000000000000000000000]],[[110110110110110110000000110110110110110110110110]],[[000000000000000000000110000000000000000000000000]],[[000000000000000000000000000000000000000000000000]],[[000000000000110110000110010000000000000000010010]],[[000010000000000000000000000000000000000000000000]],[[000000000000000000000000000000000000000000000000]],[[110110110110110110110000110110110110000000000000]],[[000000000000000000000110000000000000000000000000]],[[000000000000000000000000000000000000000000000000]],[[110110110110110110110000110000000000000000010000]],[[000000000000000000000000100000000000000110000110]],[[000000000000000000000000000000000000000000000000]]}}if a then g[1][31]=\"\\32\\32\\32\\32\\145\\32\\159\\139\\32\\151\\131\\132\\133\\135\\145\\134\\135\\145\\32\\149\\32\\158\\140\\129\\130\\130\\32\\152\\147\\155\\157\\134\\32\\32\\144\\144\\32\\32\\32\\32\\32\\32\\152\\131\\155\\131\\131\\129\"g[1][32]=\"\\32\\32\\32\\32\\149\\32\\149\\32\\145\\148\\131\\32\\145\\146\\132\\140\\157\\132\\32\\148\\32\\137\\155\\149\\32\\32\\32\\149\\154\\149\\137\\142\\32\\153\\153\\32\\131\\131\\149\\131\\131\\129\\149\\135\\145\\32\\32\\32\"g[1][33]=\"\\32\\32\\32\\32\\129\\32\\130\\135\\32\\131\\131\\129\\130\\128\\129\\32\\129\\32\\32\\129\\32\\131\\131\\32\\32\\32\\32\\130\\131\\129\\32\\32\\32\\32\\129\\129\\32\\32\\32\\32\\32\\32\\130\\131\\129\\32\\32\\32\"g[2][32]=[[000000000100110000000010000011000110000000001000]]end;local h={}local i={}do local j=0;local k=#g[1]local l=#g[1][1]for m=1,k,3 do for n=1,l,3 do local o=string.char(j)local p={}p[1]=g[1][m]:sub(n,n+2)p[2]=g[1][m+1]:sub(n,n+2)p[3]=g[1][m+2]:sub(n,n+2)local q={}q[1]=g[2][m]:sub(n,n+2)q[2]=g[2][m+1]:sub(n,n+2)q[3]=g[2][m+2]:sub(n,n+2)i[o]={p,q}j=j+1 end end;h[1]=i end;local function r(s,t)local u={[\"0\"]=\"1\",[\"1\"]=\"0\"}if s<=#h then return true end;for v=#h+1,s do local w={}local x=h[v-1]for j=0,255 do local o=string.char(j)local p={}local q={}local y=x[o][1]local z=x[o][2]for m=1,#y do local A,B,C,D,E,F={},{},{},{},{},{}for n=1,#y[1]do local G=i[y[m]:sub(n,n)][1]table.insert(A,G[1])table.insert(B,G[2])table.insert(C,G[3])local H=i[y[m]:sub(n,n)][2]if z[m]:sub(n,n)==\"1\"then table.insert(D,H[1]:gsub(\"[01]\",u))table.insert(E,H[2]:gsub(\"[01]\",u))table.insert(F,H[3]:gsub(\"[01]\",u))else table.insert(D,H[1])table.insert(E,H[2])table.insert(F,H[3])end end;table.insert(p,table.concat(A))table.insert(p,table.concat(B))table.insert(p,table.concat(C))table.insert(q,table.concat(D))table.insert(q,table.concat(E))table.insert(q,table.concat(F))end;w[o]={p,q}if t then t=\"Font\"..v..\"Yeld\"..j;os.queueEvent(t)os.pullEvent(t)end end;h[v]=w end;return true end;r(3,false)local I={[colors.white]=\"0\",[colors.orange]=\"1\",[colors.magenta]=\"2\",[colors.lightBlue]=\"3\",[colors.yellow]=\"4\",[colors.lime]=\"5\",[colors.pink]=\"6\",[colors.gray]=\"7\",[colors.lightGray]=\"8\",[colors.cyan]=\"9\",[colors.purple]=\"a\",[colors.blue]=\"b\",[colors.brown]=\"c\",[colors.green]=\"d\",[colors.red]=\"e\",[colors.black]=\"f\"}local function J(K,L,M,N)local O,P=K.getSize()local Q,R=#L[1][1],#L[1]M=M or math.floor((O-Q)/2)+1;N=N or math.floor((P-R)/2)+1;for m=1,R do if m>1 and N+m-1>P then term.scroll(1)N=N-1 end;K.setCursorPos(M,N+m-1)K.blit(L[1][m],L[2][m],L[3][m])end end;local function S(K,L,M,N)local O,P=K.getSize()local Q,R=#L[1][1],#L[1]M=M or math.floor((O-Q)/2)+1;N=N or math.floor((P-R)/2)+1;for m=1,R do K.setCursorPos(M,N+m-1)K.blit(L[1][m],L[2][m],L[3][m])end end;local function T(U,V,W,X,Y)if not type(V)==\"string\"then error(\"Not a String\",3)end;local Z=type(W)==\"string\"and W:sub(1,1)or I[W]or error(\"Wrong Front Color\",3)local _=type(X)==\"string\"and X:sub(1,1)or I[X]or error(\"Wrong Back Color\",3)local a0=h[U]or error(\"Wrong font size selected\",3)if V==\"\"then return{{\"\"},{\"\"},{\"\"}}end;local a1={}for m in V:gmatch('.')do table.insert(a1,m)end;local a2={}local k=#a0[a1[1]][1]for a3=1,k do local a4={}for m=1,#a1 do a4[m]=a0[a1[m]]and a0[a1[m]][1][a3]or\"\"end;a2[a3]=table.concat(a4)end;local a5={}local a6={}local a7={[\"0\"]=Z,[\"1\"]=_}local a8={[\"0\"]=_,[\"1\"]=Z}for a3=1,k do local a9={}local aa={}for m=1,#a1 do local ab=a0[a1[m]]and a0[a1[m]][2][a3]or\"\"a9[m]=ab:gsub(\"[01]\",Y and{[\"0\"]=W:sub(m,m),[\"1\"]=X:sub(m,m)}or a7)aa[m]=ab:gsub(\"[01]\",Y and{[\"0\"]=X:sub(m,m),[\"1\"]=W:sub(m,m)}or a8)end;a5[a3]=table.concat(a9)a6[a3]=table.concat(aa)end;return{a2,a5,a6}end;b.bigWrite=function(V)c(1,V,\"string\")J(term,T(1,V,term.getTextColor(),term.getBackgroundColor()),term.getCursorPos())local ac,ad=term.getCursorPos()term.setCursorPos(ac,ad-2)end;b.bigBlit=function(V,ae,af)c(1,V,\"string\")c(2,ae,\"string\")c(3,af,\"string\")if#V~=#ae then error(\"Invalid length of text color string\",2)end;if#V~=#af then error(\"Invalid length of background color string\",2)end;J(term,T(1,V,ae,af,true),term.getCursorPos())local ac,ad=term.getCursorPos()term.setCursorPos(ac,ad-2)end;b.bigPrint=function(V)c(1,V,\"string\")J(term,T(1,V,term.getTextColor(),term.getBackgroundColor()),term.getCursorPos())print()end;b.hugeWrite=function(V)c(1,V,\"string\")J(term,T(2,V,term.getTextColor(),term.getBackgroundColor()),term.getCursorPos())local ac,ad=term.getCursorPos()term.setCursorPos(ac,ad-8)end;b.hugeBlit=function(V,ae,af)c(1,V,\"string\")c(2,ae,\"string\")c(3,af,\"string\")if#V~=#ae then error(\"Invalid length of text color string\",2)end;if#V~=#af then error(\"Invalid length of background color string\",2)end;J(term,T(2,V,ae,af,true),term.getCursorPos())local ac,ad=term.getCursorPos()term.setCursorPos(ac,ad-8)end;b.hugePrint=function(V)c(1,V,\"string\")J(term,T(2,V,term.getTextColor(),term.getBackgroundColor()),term.getCursorPos())print()end;b.doc.writeOn=[[writeOn(tTerminal, nSize, sString, [nX], [nY]) - Writes sString on tTerminal using current tTerminal colours. nX, nY are coordinates. If any of them are nil then text is centered in that axis using tTerminal size.]]b.writeOn=function(K,U,V,M,N)c(1,K,\"table\")d(K,\"getSize\",\"function\")d(K,\"scroll\",\"function\")d(K,\"setCursorPos\",\"function\")d(K,\"blit\",\"function\")d(K,\"getTextColor\",\"function\")d(K,\"getBackgroundColor\",\"function\")c(2,U,\"number\")c(3,V,\"string\")c(4,M,\"number\",\"nil\")c(5,N,\"number\",\"nil\")S(K,T(U,V,K.getTextColor(),K.getBackgroundColor()),M,N)end;b.doc.blitOn=[[writeOn(tTerminal, nSize, sString, sFront, sBack, [nX], [nY]) - Blits sString on tTerminal with sFront and sBack colors . nX, nY are coordinates. If any of them are nil then text is centered in that axis using tTerminal size.]]b.blitOn=function(K,U,V,ae,af,M,N)c(1,K,\"table\")d(K,\"getSize\",\"function\")d(K,\"scroll\",\"function\")d(K,\"setCursorPos\",\"function\")d(K,\"blit\",\"function\")c(2,U,\"number\")c(3,V,\"string\")c(4,ae,\"string\")c(5,af,\"string\")if#V~=#ae then error(\"Invalid length of text color string\",2)end;if#V~=#af then error(\"Invalid length of background color string\",2)end;c(6,M,\"number\",\"nil\")c(7,N,\"number\",\"nil\")S(K,T(U,V,ae,af,true),M,N)end;b.doc.makeBlittleText=[[makeBlittleText(nSize, sString, nFC, nBC) - Generate blittle object in size nSize with text sString in blittle format for printing with that api. nFC and nBC are colors to generate the object with.]]b.makeBlittleText=function(U,V,W,X)c(1,U,\"number\")c(2,V,\"string\")c(3,W,\"number\")c(4,X,\"number\")local ag=T(U,V,W,X)ag.height=#ag[1]ag.width=#ag[1][1]return ag end;b.doc.generateFontSize=[[generateFontSize(size) - Generates bigger font sizes and enables then on other functions that accept size argument. By default bigfont loads sizes 1-3 as those can be generated without yielding. Using this user can generate sizes 4-6. Warning: This function will internally yield.]]b.generateFontSize=function(s)c(1,s,\"number\")if type(s)~=\"number\"then error(\"Size needs to be a number\",2)end;if s>6 then return false end;return r(math.floor(s),true)end;local ah={basalt=\"https://raw.githubusercontent.com/GoldeneToilette/GuardLink/main/server/lib/basalt.lua\",uiHelper=\"https://raw.githubusercontent.com/GoldeneToilette/GuardLink/main/server/lib/uiHelper.lua\",pixelbox=\"https://raw.githubusercontent.com/GoldeneToilette/GuardLink/main/server/lib/pixelbox_lite.lua\",settings=\"https://raw.githubusercontent.com/GoldeneToilette/GuardLink/main/settings.lua\",disk=\"https://raw.githubusercontent.com/GoldeneToilette/GuardLink/main/server/modules/disk.lua\",fileUtils=\"https://raw.githubusercontent.com/GoldeneToilette/GuardLink/main/server/lib/fileUtils.lua\"}local ai={}for aj,ak in pairs(ah)do ai[aj]=load(http.get(ak).readAll(),aj,\"t\",_G)()end;local al=true;local function am()parallel.waitForAny(ai.basalt.autoUpdate,function()while al do os.sleep(0)end end)term.clear()term.setBackgroundColor(colors.black)term.setTextColor(colors.white)term.setCursorPos(1,1)print(\"Getting latest release...\")local an=\"https://raw.githubusercontent.com/GoldeneToilette/GuardLink/v0.1.0/releases/guardlink_server.lua\"local ao=load(http.get(an).readAll(),\"guardlink_server\",\"t\",_G)()for aj,ak in pairs(ao.files)do ai.fileUtils.newFile(\"GuardLink/\"..aj)ai.fileUtils.write(\"GuardLink/\"..aj,ak)print(\"Created file: \"..aj)os.sleep(0.05)end;print(\"Done! Reboot required\")end;local function ap()term.setTextColor(colors.red)local ac,ad=term.getSize()if ac~=51 then error(\"You cannot install GuardLink server on a pocket computer!\")end;print(\"Computer will be wiped. Proceed with install? Y/N:\")local a1=read()if a1~=\"Y\"and a1~=\"y\"then return end;local aq=fs.list(\"/\")for m=1,#aq do if aq[m]~=\"rom\"and aq[m]:sub(1,4)~=\"disk\"then fs.delete(aq[m])end end;print(\"Done! Creating folders...\")fs.makeDir(\"/GuardLink/server/config\")end;local ar=ai.basalt.createFrame():setVisible(true)local as=ai.uiHelper.newLabel(ar,\"  \\26   \\26  \",1,1,51,1,colors.lightGray,colors.gray,1)local at={}local au=0;for m=1,9,4 do table.insert(at,ai.uiHelper.newLabel(ar,\"\\186\",m,1,1,1,colors.lightGray,colors.gray,1))end;local function av(aw)local v=aw and ar:addScrollableFrame()or ar:addFrame()return v:setSize(\"parent.w\",\"parent.h - 1\"):setPosition(1,2):setBackground(colors.white):setVisible(false)end;local ax={}local function ay()if au>=#ax then error(\"Tried to load panel that doesn't exist!\")end;if au>0 then ax[au].frame:setVisible(false)if au>1 and at and at[au-1]then at[au-1]:setForeground(colors.green)end end;au=au+1;ax[au].frame:setVisible(true)end;local function az()if au<=2 then error(\"Tried to load invalid panel!\")end;ax[au].frame:setVisible(false)if at[au-2]then at[au-2]:setForeground(colors.gray)end;au=au-1;ax[au].frame:setVisible(true)end;local function aA(aB,aC,type)local aD=type==\"error\"and\"Error\"or\"Info\"local aE=type==\"error\"and colors.red or colors.green;local aB=aB:addMovableFrame():setVisible(true):setSize(35,7):setPosition(6,4):setBackground(colors.white):setBorder(colors.lightGray,\"right\",\"bottom\")aB:addLabel():setText(aD):setSize(34,1):setPosition(1,1):setBackground(colors.blue):setForeground(colors.white)aB:addLabel():setText(aC):setPosition(2,3):setSize(30,4):setBackground(colors.white):setForeground(aE)ai.uiHelper.newButton(aB,\"X\",35,1,1,1,colors.blue,colors.red,function(aF,aG,aH,ac,ad)aB:setVisible(false)aB:remove()end)end;ax[1]={data={},ui={},frame=av(),build=function(self)local aI,aB=self.ui,self.frame;aI.title=ai.uiHelper.newLabel(aB,\"Welcome to GuardLink Setup!\",1,2,28,1,colors.white,colors.blue,1)aI.pane=ai.uiHelper.newPane(aB,32,2,19,15,colors.lightGray):setBorder(colors.gray,\"left\")aI.table=ai.uiHelper.newLabel(aB,\"1.Nation          2.Core Settings   3.Final\",33,3,18,9,colors.lightGray,colors.gray)aI.button=ai.uiHelper.newButton(aB,\"Start\",43,13,7,3,colors.gray,colors.white,function()ax[2]:build()ay()end)local function aJ(aK)local aL,aM=aK.width/2,aK.height/2;local aN=math.min(aK.width,aK.height)/3.7;local aO=0.05;local aP={{-1,-1,-1},{1,-1,-1},{1,1,-1},{-1,1,-1},{-1,-1,1},{1,-1,1},{1,1,1},{-1,1,1}}local aQ={{1,2},{2,3},{3,4},{4,1},{5,6},{6,7},{7,8},{8,5},{1,5},{2,6},{3,7},{4,8}}local aR,aS=0,0;while true do aK:clear(colors.white)local aT={}for m,ak in ipairs(aP)do local ac,ad,aU=ak[1],ak[2],ak[3]local aV=ad*math.cos(aR)-aU*math.sin(aR)local aW=ad*math.sin(aR)+aU*math.cos(aR)local aX=ac*math.cos(aS)-aW*math.sin(aS)aT[m]={aL+aX*aN,aM+aV*aN}end;for aY,aZ in ipairs(aQ)do local a_,b0=aT[aZ[1]],aT[aZ[2]]local b1,aV=math.floor(a_[1]),math.floor(a_[2])local aX,b2=math.floor(b0[1]),math.floor(b0[2])local b3,b4=math.abs(aX-b1),math.abs(b2-aV)local b5,b6=b1<aX and 1 or-1,aV<b2 and 1 or-1;local b7=b3-b4;while true do if b1>=1 and b1<=aK.width and aV>=1 and aV<=aK.height then aK.canvas[aV][b1]=colors.blue end;if b1==aX and aV==b2 then break end;local b8=b7*2;if b8>-b4 then b7=b7-b4;b1=b1+b5 end;if b8<b3 then b7=b7+b3;aV=aV+b6 end end end;aK:render()local b9=os.clock()local ba=aO*(0.85+0.15*math.sin(b9*0.8))aR=aR+ba;aS=aS+ba*0.7;os.sleep(0.05)end end;aI.animation=aB:addProgram():setSize(25,14):setPosition(3,5):execute(function()local aK=ai.pixelbox.new(term.current())aJ(aK)end)end,validate=function(self)aA(self.frame,\"NOTHING TO VALIDATE; IF YOU SEE THIS SOMETHING BROKE\",\"error\")end}ax[2]={data={roles={}},ui={},frame=av(),build=function(self)local aI,aB,bb=self.ui,self.frame,self.data;aI.pane=ai.uiHelper.newPane(aB,2,2,21,7,colors.lightGray)aI.nation_name=ai.uiHelper.newLabel(aB,\"Name:\",3,3,5,1,colors.lightGray,colors.gray,1)aI.nation_field=ai.uiHelper.newTextfield(aB,9,3,13,1,colors.gray,colors.white):editLine(1,bb.nation_name or\"\")aI.tag_name=ai.uiHelper.newLabel(aB,\"Tag (3 chars):\",3,5,14,1,colors.lightGray,colors.gray,1)aI.tag_field=ai.uiHelper.newTextfield(aB,18,5,4,1,colors.gray,colors.white):editLine(1,bb.nation_tag or\"\")aI.ethic_label=ai.uiHelper.newLabel(aB,\"Ethic:\",3,7,6,1,colors.lightGray,colors.gray,1)aI.ethic_dropdown=aB:addDropdown():setForeground(colors.white):setBackground(colors.gray):setPosition(10,7)local bc=\"\"for aj,ak in pairs(ai.settings.rules.ethics)do if bc==\"\"then bc=aj end;aI.ethic_dropdown:addItem(ak.name,colors.gray,colors.white,aj)end;if not bb.selectedEthic then bb.selectedEthic=bc end;for m=1,aI.ethic_dropdown:getItemCount()do if aI.ethic_dropdown:getItem(m).args.k==bb.selectedEthic then aI.ethic_dropdown:selectItem(m)end end;aI.ethic_pane=ai.uiHelper.newPane(aB,2,10,1,3,colors.white):setBorder(colors.blue,\"left\")aI.ethic_desc=ai.uiHelper.newLabel(aB,ai.settings.rules.ethics[bb.selectedEthic].description,3,10,21,3,colors.white,colors.gray)aI.ethic_dropdown:onChange(function(aF,aG,bd)aI.ethic_desc:setText(ai.settings.rules.ethics[bd.args[1]].description)bb.selectedEthic=bd.args[1]end)aI.roles_frame=aB:addMovableFrame():setVisible(false):setSize(45,13):setPosition(4,4):setBackground(colors.white):setBorder(colors.lightGray,\"right\",\"bottom\")aI.roles_title=aI.roles_frame:addLabel():setText(\"Manage Roles\"):setSize(44,1):setPosition(1,1):setBackground(colors.blue):setForeground(colors.white)aI.roles_name=ai.uiHelper.newLabel(aI.roles_frame,\"Title:\",2,3,6,1,colors.white,colors.gray,1)aI.roles_name_text=ai.uiHelper.newTextfield(aI.roles_frame,10,3,20,1,colors.lightGray,colors.gray)aI.roles_count=ai.uiHelper.newLabel(aI.roles_frame,\"Count:\",32,3,6,1,colors.white,colors.gray,1)aI.roles_count_text=ai.uiHelper.newTextfield(aI.roles_frame,40,3,4,1,colors.lightGray,colors.gray)aI.roles_list=aI.roles_frame:addList():setBackground(colors.lightGray):setForeground(colors.white):setPosition(2,5):setSize(28,6):setSelectionColor(nil,colors.black):setScrollable(true)for m,ak in ipairs(bb.roles)do aI.roles_list:addItem(ak[1],colors.lightGray,colors.gray,ak[2])end;local function be()return ai.settings.server.formulas.roleLimit(ai.settings.rules.ethics[bb.selectedEthic].values.stability)end;local function bf()return be()-aI.roles_list:getItemCount()end;aI.roles_capacity=ai.uiHelper.newLabel(aI.roles_frame,\"Role Capacity: \"..bf(),2,12,17,1,colors.white,colors.gray,1)aI.roles_new=ai.uiHelper.newButton(aI.roles_frame,\"Add\",32,5,5,3,colors.blue,colors.white):setBorder(colors.white,\"top\"):onClick(function(aF,aG,aH,ac,ad)local bg=be()local bh=aI.roles_list:getItemCount()local bi=aI.roles_name_text:getLine(1)local bj=tonumber(aI.roles_count_text:getLine(1))if bf()>0 and#bi<=ai.settings.rules.maxRoleLength and#bi>=1 and(bj and bj>=1)and type(bj)==\"number\"then aI.roles_list:addItem(bi,colors.lightGray,colors.gray,math.min(bj,500))if bg<0 then aI.roles_capacity:setForeground(colors.red)else aI.roles_capacity:setForeground(colors.green)end;aI.roles_capacity:setText(\"Role Capacity: \"..bf())end end)aI.roles_del=ai.uiHelper.newButton(aI.roles_frame,\"Remove\",32,8,8,3,colors.blue,colors.white):setBorder(colors.white,\"top\"):onClick(function(aF,aG,aH,ac,ad)local bk=aI.roles_list:getItemIndex()if bk and bk>=1 then aI.roles_list:removeItem(bk)local bg=bf()if bg<0 then aI.roles_capacity:setForeground(colors.red)else aI.roles_capacity:setForeground(colors.green)end;aI.roles_capacity:setText(\"Role Capacity: \"..bg)end end)aI.roles_exit=ai.uiHelper.newButton(aI.roles_frame,\"X\",45,1,1,1,colors.blue,colors.red,function(aF,aG,aH,ac,ad)aI.roles_frame:setVisible(false)end)aI.roles_button=ai.uiHelper.newButton(aB,\"Manage Roles\",2,15,14,3,colors.gray,colors.white,function(aF,aG,aH,ac,ad)local bg=bf()if bg<0 then aI.roles_capacity:setForeground(colors.red)else aI.roles_capacity:setForeground(colors.green)end;aI.roles_capacity:setText(\"Role Capacity: \"..bg)aI.roles_frame:setVisible(true)end)aI.paneEco=ai.uiHelper.newPane(aB,25,2,26,7,colors.lightGray)aI.ecoName=ai.uiHelper.newLabel(aB,\"Currency Name:\",26,3,14,1,colors.lightGray,colors.gray)aI.ecoField=ai.uiHelper.newTextfield(aB,41,3,9,1,colors.gray,colors.white):editLine(1,bb.currency_name or\"\")aI.balance=ai.uiHelper.newLabel(aB,\"Starting Balance:\",26,5,17,1,colors.lightGray,colors.gray)aI.balanceField=ai.uiHelper.newTextfield(aB,44,5,6,1,colors.gray,colors.white)aI.balanceField:editLine(1,bb.balance or\"0\")aI.trade=ai.uiHelper.newLabel(aB,\"Inter-Nation Trade:\",26,7,19,1,colors.lightGray,colors.gray)aI.tradeCheck=aB:addCheckbox():setPosition(46,7):setBackground(colors.gray):setForeground(colors.white):setValue(bb.tradeCheck):onChange(function(aF,aG,bl)bb.tradeCheck=bl end)aI.next_button=ai.uiHelper.newButton(aB,\"Next\",45,15,6,3,colors.blue,colors.white,function(aF,aG,aH,ac,ad)local bm=self:validate()if bm~=0 then aA(aB,bm,\"error\")else bb.nation_name=aI.nation_field:getLine(1)bb.nation_tag=aI.tag_field:getLine(1)bb.currency_name=aI.ecoField:getLine(1)bb.balance=aI.balanceField:getLine(1)for m=1,aI.roles_list:getItemCount()do local bd=aI.roles_list:getItem(m)bb.roles[m]={bd.text,bd.args[1]}end;ax[3]:build()ay()end end)end,validate=function(self)local aI=self.ui;if#aI.nation_field:getLine(1)==0 or#aI.nation_field:getLine(1)>ai.settings.rules.maxNationLength then return\"Nation name must be 1-\"..ai.settings.rules.maxNationLength..\" characters!\"end;if#aI.tag_field:getLine(1)~=3 then return\"Tag must be 3 characters!\"end;local bn=ai.settings.server.formulas.roleLimit(ai.settings.rules.ethics[self.data.selectedEthic].values.stability)-aI.roles_list:getItemCount()if bn<0 then return\"Exceeding role capacity! \"..bn end;if#aI.ecoField:getLine(1)==0 or#aI.ecoField:getLine(1)>ai.settings.rules.maxCurrencyLength then return\"Currency name must be 1-\"..ai.settings.rules.maxCurrencyLength..\" characters!\"end;local bo=tonumber(aI.balanceField:getLine(1))if not bo or bo<0 then return\"Invalid starting balance: \"..aI.balanceField:getLine(1)end;return 0 end}local bp=textutils.unserializeJSON(http.get(\"https://raw.githubusercontent.com/GoldeneToilette/GuardLink/main/server/config/themes.json\").readAll())ax[3]={data={},ui={},frame=av(),build=function(self)local function bq(br)local b9=bp[br]if b9 then local bs={}for aY,bt in ipairs(b9)do bs[bt[1]]=bt[2]end;term.setPaletteColor(colors.orange,tonumber(bs.primary))term.setPaletteColor(colors.magenta,tonumber(bs.secondary))term.setPaletteColor(colors.lightBlue,tonumber(bs.tertiary))term.setPaletteColor(colors.yellow,tonumber(bs.highlight))term.setPaletteColor(colors.lime,tonumber(bs.subtle))term.setPaletteColor(colors.cyan,tonumber(bs.accent))end end;local bb,aI,aB=self.data,self.ui,self.frame;aI.title_label=ai.uiHelper.newLabel(aB,\"Server Settings\",3,3,17,1,colors.lightGray,colors.gray)aI.pane=ai.uiHelper.newPane(aB,2,2,21,13,colors.lightGray)aI.theme_label=ai.uiHelper.newLabel(aB,\"Theme:\",3,5,6,1,colors.lightGray,colors.gray)aI.theme_dropdown=aB:addDropdown():setForeground(colors.white):setBackground(colors.gray):setPosition(10,5)aI.primary=ai.uiHelper.newPane(aB,3,7,3,1,colors.orange)aI.secondary=ai.uiHelper.newPane(aB,6,7,3,1,colors.magenta)aI.tertiary=ai.uiHelper.newPane(aB,9,7,3,1,colors.lightBlue)aI.highlight=ai.uiHelper.newPane(aB,12,7,3,1,colors.yellow)aI.subtle=ai.uiHelper.newPane(aB,15,7,3,1,colors.lime)aI.accent=ai.uiHelper.newPane(aB,18,7,3,1,colors.cyan)local bc=\"\"for aj,ak in pairs(bp)do if bc==\"\"then bc=aj end;if aj==\"default\"then bc=aj end;aI.theme_dropdown:addItem(aj,colors.gray,colors.white)end;if not bb.theme then bb.theme=bc end;for m=1,aI.theme_dropdown:getItemCount()do if aI.theme_dropdown:getItem(m).text==bb.theme then aI.theme_dropdown:selectItem(m)end end;bq(bb.theme)aI.theme_dropdown:onChange(function(aF,aG,bd)bq(bd.text)bb.theme=bd.text end)aI.debug_label=ai.uiHelper.newLabel(aB,\"Debug logs:\",3,9,11,1,colors.lightGray,colors.gray)aI.debug_check=aB:addCheckbox():setPosition(15,9):setBackground(colors.gray):setForeground(colors.white):setValue(bb.debug):onChange(function(aF,aG,bl)bb.debug=bl end)bb.diskManager=ai.disk.new(nil,nil,ai.fileUtils)bb.diskManager:scan()aI.pane2=ai.uiHelper.newPane(aB,24,2,27,13,colors.lightGray)aI.disksTitle=ai.uiHelper.newLabel(aB,\"Disks\",25,3,5,1,colors.lightGray,colors.gray)aI.detected=ai.uiHelper.newLabel(aB,\"Detected: \"..bb.diskManager:diskCount(),25,5,13,1,colors.lightGray,colors.gray)aI.capacity=ai.uiHelper.newLabel(aB,\"Space: \"..bb.diskManager.capacity/1000000 ..\"MB\",25,6,13,1,colors.lightGray,colors.gray)aI.list=aB:addList():setBackground(colors.white):setForeground(colors.gray):setPosition(39,3):setSize(10,11):setSelectionColor(nil,colors.black):setScrollable(true)local bu=bb.diskManager:getDiskLabels()for m,ak in ipairs(bu)do aI.list:addItem(ak)end;aI.detect=ai.uiHelper.newButton(aB,\"Detect\",25,11,8,3,colors.blue,colors.white,function(aF,aG,aH,ac,ad)bb.diskManager:scan()aI.detected:setText(\"Detected: \"..bb.diskManager:diskCount())aI.capacity:setText(\"Space: \"..bb.diskManager.capacity/1000000 ..\"MB\")for m=aI.list:getItemCount(),1,-1 do aI.list:removeItem(m)end;local bu=bb.diskManager:getDiskLabels()for m,ak in ipairs(bu)do aI.list:addItem(ak)end end)aI.back_button=ai.uiHelper.newButton(aB,\"Back\",38,16,6,3,colors.blue,colors.white,function(aF,aG,aH,ac,ad)ax[2]:build()az()end)aI.back_button:setBorder(colors.white,\"bottom\")aI.next_button=ai.uiHelper.newButton(aB,\"Next\",45,16,6,3,colors.blue,colors.white,function(aF,aG,aH,ac,ad)local bm=self:validate()if bm~=0 then aA(aB,bm,\"error\")else ax[4]:build()ay()end end)aI.next_button:setBorder(colors.white,\"bottom\")end,validate=function(self)self.data.diskManager:scan()if self.data.diskManager.capacity<1250000 then return\"Not enough space! Minimum: 1.25MB, Recommended: 2,5MB (~20 disks)\"end;return 0 end}ax[4]={data={},ui={},frame=av(),build=function(self)local bb,aI,aB=self.data,self.ui,self.frame;aI.title=aB:addProgram():setPosition(1,2):setSize(51,15)aI.title:execute(function()term.setBackgroundColor(colors.white)term.setTextColor(colors.blue)term.clear()local bv=\"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789!@#$%^&*><=\\96\\192\\201\\205\\188\\221\\254\\247\\93{}\\191\\223\"local bw=\"Thanks for using\"local bx=\"GuardLink! \\3\"if not bb.finished then bb.finished=true;local function by()local bz=math.random(#bv)return bv:sub(bz,bz)end;local function bA(b9)local aF=\"\"for m=1,#b9 do aF=aF..by()end;return aF end;local function bB(bC,m,bD)return bC:sub(1,m-1)..bD..bC:sub(m+1)end;local bC=bA(bw)local bE=bA(bx)term.setCursorPos(2,2)b.bigPrint(bC)term.setCursorPos(2,8)b.bigPrint(bE)for m=1,#bw do local bF=math.random(1,3)while bF>0 do bC=bB(bC,m,by())term.setCursorPos(2,2)b.bigPrint(bC)os.sleep(0.0004)bF=bF-1 end;bC=bB(bC,m,bw:sub(m,m))term.setCursorPos(2,2)b.bigPrint(bC)end;os.sleep(0.0004)term.setCursorPos(2,8)for m=1,#bx do local bF=math.random(1,3)while bF>0 do bE=bB(bE,m,by())term.setCursorPos(2,8)b.bigPrint(bE)os.sleep(0.0004)bF=bF-1 end;bE=bB(bE,m,bx:sub(m,m))term.setCursorPos(2,8)b.bigPrint(bE)end else term.setCursorPos(2,2)b.bigPrint(bw)term.setCursorPos(2,8)b.bigPrint(bx)end end)aI.back_button=ai.uiHelper.newButton(aB,\"Back\",36,16,6,3,colors.blue,colors.white,function(aF,aG,aH,ac,ad)ax[3]:build()az()end)aI.back_button:setBorder(colors.white,\"bottom\")aI.next_button=ai.uiHelper.newButton(aB,\"Finish\",43,16,8,3,colors.blue,colors.white,function(aF,aG,aH,ac,ad)al=false end)aI.next_button:setBorder(colors.white,\"bottom\")end,validate=function(self)end}ap()ax[1]:build()ay()term.setPaletteColor(colors.red,0xff0000)term.setPaletteColor(colors.blue,0x2563EB)term.setPaletteColor(colors.pink,0xF7F8F8)term.setPaletteColor(colors.white,0xf2f8fb)term.setPaletteColor(colors.gray,0x767e7c)term.setPaletteColor(colors.lightGray,0xd1d2de)term.setPaletteColor(colors.green,0x4CAF50)term.setPaletteColor(colors.black,0x2B2F36)term.setPaletteColor(colors.orange,0xFFFFFF)term.setPaletteColor(colors.magenta,0xFFFFFF)term.setPaletteColor(colors.lightBlue,0xFFFFFF)term.setPaletteColor(colors.yellow,0xFFFFFF)term.setPaletteColor(colors.lime,0xFFFFFF)term.setPaletteColor(colors.cyan,0xFFFFFF)am()\
",
    ["server/modules/taskManager.lua"] = "local a={}a.tasks={}function a.add(b,c)local d=os.epoch(\"utc\")/1000;table.insert(a.tasks,{callback=b,interval=c,lastRun=d})end;function a.remove(b)for e,f in ipairs(a.tasks)do if f.callback==b then table.remove(a.tasks,e)break end end end;function a.clear()a.tasks={}end;function a.run()while true do if#a.tasks>0 then local d=os.epoch(\"utc\")/1000;for g,f in ipairs(a.tasks)do if d-f.lastRun>=f.interval then local h,i=pcall(f.callback)if not h then _G.logger:error(\"[taskManager] Task error: \"..tostring(i))end;f.lastRun=d end end end;os.sleep(0.1)end end;return a\
",
    ["server/lib/utils.lua"] = "local a={}local b={generic=\"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789\",base32=\"ABCDEFGHIJKLMNOPQRSTUVWXYZ234567\",numbers=\"0123456789\"}function a.randomString(c,d)if b[d]then d=b[d]end;local e=\"\"for f=1,c do local g=math.random(1,#d)e=e..d:sub(g,g)end;return e end;function a.generateUUID()local h=\"xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx\"return string.gsub(h,\"[xy]\",function(i)local j=i==\"x\"and math.random(0,0xf)or math.random(8,0xb)return string.format(\"%x\",j)end)end;function a.tryCatch(k,l)local function m(n)local o=debug.traceback(n)if l then l(n,o)else _G.logger:fatal(\"Caught error: \"..tostring(n)..\"\\nStack Trace:\\n\"..o)end end;local p=xpcall(k,m)if not p then _G.logger:fatal(\"Error handling failed.\")end end;function a.isInteger(q)return math.floor(q)==q end;function a.formatNumber(r)if r>=1e15 then return string.format(\"%.1fQ\",r/1e15)elseif r>=1e12 then return string.format(\"%.1fT\",r/1e12)elseif r>=1e9 then return string.format(\"%.1fB\",r/1e9)elseif r>=1e6 then return string.format(\"%.1fM\",r/1e6)else return string.format(\"%d\",r)end end;function a.stringToNumber(e)local s=0;for f=1,#e do s=(s*31+string.byte(e,f))%2^42 end;return s end;function a.deepCopy(t)if type(t)~=\"table\"then return t end;local u={}for v,j in pairs(t)do u[v]=a.deepCopy(j)end;return u end;return a\
",
    ["server/startup.lua"] = "local a=require(\"modules.disk\").new()a:scan()a:partition({whitelist={\"GLB_1\",\"GLB_2\",\"GLB_3\",\"GLB_4\"},layout={{name=\"accounts\",percentage=10},{name=\"logs\",percentage=60},{name=\"cache\",percentage=20},{name=\"wallets\",percentage=10}}})_G.vfs=require(\"modules.virtualFilesystem\").new(a)local b=require\"lib.logger\"_G.utils=require\"lib.utils\"_G.logger=b.new(\"latest\",\"logs\")_G.logger:clearLog()_G.shutdown=require(\"modules.shutdown\")local c={session={discoveryChannel=65535,keyPath=\"/GuardLink/server/\"},clients={maxClients=120,throttleLimit=7200,max_idle=60,heartbeat_interval=30,channelRotation=20,clientIDLength=5},queue={queueSize=40,throttle=1},theme=\"default\",debugMode=false}_G.theme=require(\"lib.themes\")_G.theme.init()_G.theme.setTheme(c.theme)local d=require(\"network.networkSession\").new(c)local e=require(\"modules.uiState\").new()local f=require(\"modules.taskManager\")f.add(function()d.clientManager:updateChannels()end,d.clientManager.channelRotation)f.add(function()d.clientManager:heartbeats()end,d.clientManager.heartbeat_interval)_G.utils.tryCatch(function()parallel.waitForAll(function()d:listen()end,function()d.requestQueue:processQueue()end,f.run,function()e:run()end)end,function(g,h)_G.logger:fatal(\"[startup] Server crashed :(\")_G.logger:error(\"[startup] Error:\"..tostring(g))os.shutdown()end)\
",
    ["server/lib/logger.lua"] = "local a={}a.__index=a;function a.new(b,c)local self=setmetatable({},a)local d=os.date(\"%Y-%m-%d\")self.name=b or d;self.dir=c;self.path=self.dir..\"/\"..(b or d)..\".log\"self.debugPath=self.dir..\"/\"..\"debug\"..\".log\"_G.vfs:makeDir(self.dir)_G.vfs:newFile(self.path)_G.vfs:newFile(self.debugPath)return self end;function a:log(e,f)f=f or\"info\"local g=os.date(\"%Y-%m-%d %H:%M:%S\")local h=string.format(\"[%s] [%s] %s\\n\",g,f,e)if f==\"debug\"then _G.vfs:appendFile(self.debugPath,h)else _G.vfs:appendFile(self.path,h)end end;function a:info(e)self:log(e,\"info\")end;function a:error(e)self:log(e,\"error\")end;function a:debug(e)self:log(e,\"debug\")end;function a:fatal(e,i)i=i or debug.traceback()self:log(e..\"\\n\"..i,\"fatal\")end;function a:clearLog()_G.vfs:writeFile(self.path,\"\")_G.vfs:writeFile(self.debugPath,\"\")end;return a\
",
    ["server/dispatchers/network.lua"] = "local a=require\"lib.errors\"local b=require\"network.message\"local c={}function c.handshake(d,e,f,g,h)local i=b.create(\"network\",{action=\"handshake\",key=h.publicKey})i.id=f;h:send(h.discovery,textutils.serialize({plaintext=true,message=i}))return 0 end;function c.heartbeat()return 0 end;local function j(i,e,f,g,h)if not c[i.payload.action]then return a.MALFORMED_MESSAGE end;return c[i.payload.action](i.payload,e,f,g,h)end;return j\
",
    ["server/ui/someUI.lua"] = "local a;local b;local function c()local d=a.mainframe:addFrame():setSize(\"parent.w\",\"parent.h - 1\"):setPosition(1,2):setVisible(true):setZIndex(1)b=d;local e=a.uiHelper.newLabel(b,\"This works! :D\",3,4,nil,1,colors.black,colors.orange,1)end;local function f()b:setVisible(false)b:remove()end;local function g(h)a=h end;return{displayName=\"Some UI?\",add=c,remove=f,setContext=g}\
",
    ["server/modules/account.lua"] = "local a=require\"lib.sha256\"local b=require\"lib.errors\"if not _G.vfs:existsDir(\"accounts\")then _G.logger:fatal(\"[AccountManager] Failed to load accountManager: malformed partitions?\")error(\"Failed to load accountManager: malformed partitions?\")end;local c={}local d={name=\"\",uuid=\"\",role=\"\",creationDate=\"\",creationTime=\"\",twofactor=false,ban={active=false,startTime=nil,duration=0,reason=\"\"},password=\"\",salt=\"\",wallets={}}function c.isValidAccountName(e)if not e then return b.ACCOUNT_NAME_EMPTY end;e=e:match(\"^%s*(.-)%s*$\")if e==\"\"then return b.ACCOUNT_NAME_EMPTY end;if e:find(\"[/\\\\:*?\\\"<>|]\")then return b.ACCOUNT_INVALID_CHAR end;if#e>20 then return b.ACCOUNT_NAME_TOO_LONG end;if#e<3 then return b.ACCOUNT_NAME_TOO_SHORT end;if _G.vfs:existsFile(\"accounts/\"..e..\".json\")then return b.ACCOUNT_EXISTS end;return 0 end;function c.getTemplate()return _G.utils.deepCopy(d)end;function c.exists(e)return _G.vfs:existsFile(\"accounts/\"..e..\".json\")end;function c.createAccount(e,f)local g=c.isValidAccountName(e)if g~=0 then _G.logger:error(g.log)return g end;if not f or f==\"\"then _G.logger:error(b.ACCOUNT_PASSWORD_EMPTY.log)return b.ACCOUNT_PASSWORD_EMPTY end;local h=\"accounts/\"..e..\".json\"local i=c.getTemplate()i.name=e;i.uuid=_G.utils.generateUUID()i.creationDate=os.date(\"%Y-%m-%d\")i.creationTime=os.date(\"%H:%M:%S\")local j=_G.utils.randomString(16,\"generic\")i.salt=j;i.password=a.digest(j..f):toHex()_G.vfs:newFile(h)_G.vfs:writeFile(h,textutils.serializeJSON(i))return 0 end;function c.deleteAccount(e)_G.vfs:deleteFile(\"accounts/\"..e..\".json\")end;function c.getAccountData(e)if e and c.exists(e)then return textutils.unserializeJSON(_G.vfs:readFile(\"accounts/\"..e..\".json\"))else return nil end end;function c.setAccountValue(e,k,l)local m=c.getAccountData(e)m[k]=l;_G.vfs:writeFile(\"accounts/\"..e..\".json\",textutils.serializeJSON(m))end;function c.getAccountValue(e,k)local m=c.getAccountData(e)if not m then return nil end;return m[k]end;function c.listAccounts()local n={}local o=_G.vfs:listDir(\"accounts/\")or{}for p,q in ipairs(o)do if q:sub(-5)==\".json\"then table.insert(n,q:sub(1,-6))end end;return n end;function c.getSanitizedAccountValues(e)local r=c.getAccountData(e)if r then return{name=r.name,uuid=r.uuid,creationDate=r.creationDate,creationTime=r.creationTime,ban=r.ban,role=r.role,wallets=r.wallets}else return nil end end;function c.authenticateUser(s,f)local t=c.getAccountData(s)if not t then return b.ACCOUNT_NOT_FOUND end;if s==\"\"then return b.ACCOUNT_NAME_EMPTY end;if f==\"\"then return b.ACCOUNT_PASSWORD_EMPTY end;local j=t.salt;local u=t.password;local v=j..f;local w=a.digest(v):toHex()if w==u then return 0 else return b.INVALID_CREDENTIALS end end;function c.banAccount(e,x,y)local t=c.getAccountData(e)if not t then return false end;local z=0;for A,B in pairs(x)do if B<1 then return false end;if A==\"seconds\"then z=z+B elseif A==\"minutes\"then z=z+B*60 elseif A==\"hours\"then z=z+B*3600 elseif A==\"days\"then z=z+B*86400 elseif A==\"permanent\"then z=-1 end end;t.ban={active=true,startTime=os.epoch(\"utc\"),duration=z==-1 and-1 or z*1000,reason=y or\"\"}c.setAccountValue(e,\"ban\",t.ban)return true end;function c.pardon(e)local t=c.getAccountData(e)if not t then return false end;t.ban={active=false,startTime=nil,duration=0,reason=\"\"}c.setAccountValue(e,\"ban\",t.ban)return true end;function c.isBanned(e)local t=c.getAccountData(e)if not t then return false end;local C=t.ban;if not C.active then return false end;if C.duration==-1 then return true,C.reason end;if not C.startTime then return false end;local D=os.epoch(\"utc\")if t.ban.duration==-1 then return true,t.ban.reason end;if D-t.ban.startTime>=t.ban.duration then t.ban={active=false,startTime=nil,duration=0,reason=\"\"}c.setAccountValue(e,\"ban\",t.ban)return false end;return true,t.ban.reason end;return c\
",
    ["server/lib/sha256.lua"] = "local a=2^32;local b=bit32 and bit32.band or bit.band;local c=bit32 and bit32.bnot or bit.bnot;local d=bit32 and bit32.bxor or bit.bxor;local e=bit32 and bit32.lshift or bit.blshift;local f=unpack;local function g(h,i)local j=h/2^i;local k=j%1;return j-k+k*a end;local function l(m,n)local j=m/2^n;return j-j%1 end;local o={0x6a09e667,0xbb67ae85,0x3c6ef372,0xa54ff53a,0x510e527f,0x9b05688c,0x1f83d9ab,0x5be0cd19}local p={0x428a2f98,0x71374491,0xb5c0fbcf,0xe9b5dba5,0x3956c25b,0x59f111f1,0x923f82a4,0xab1c5ed5,0xd807aa98,0x12835b01,0x243185be,0x550c7dc3,0x72be5d74,0x80deb1fe,0x9bdc06a7,0xc19bf174,0xe49b69c1,0xefbe4786,0x0fc19dc6,0x240ca1cc,0x2de92c6f,0x4a7484aa,0x5cb0a9dc,0x76f988da,0x983e5152,0xa831c66d,0xb00327c8,0xbf597fc7,0xc6e00bf3,0xd5a79147,0x06ca6351,0x14292967,0x27b70a85,0x2e1b2138,0x4d2c6dfc,0x53380d13,0x650a7354,0x766a0abb,0x81c2c92e,0x92722c85,0xa2bfe8a1,0xa81a664b,0xc24b8b70,0xc76c51a3,0xd192e819,0xd6990624,0xf40e3585,0x106aa070,0x19a4c116,0x1e376c08,0x2748774c,0x34b0bcb5,0x391c0cb3,0x4ed8aa4a,0x5b9cca4f,0x682e6ff3,0x748f82ee,0x78a5636f,0x84c87814,0x8cc70208,0x90befffa,0xa4506ceb,0xbef9a3f7,0xc67178f2}local function q(r)local s,t=0,0;if 0xFFFFFFFF-s<r then t=t+1;s=r-(0xFFFFFFFF-s)-1 else s=s+r end;return t,s end;local function u(v,w)return e(v[w]or 0,24)+e(v[w+1]or 0,16)+e(v[w+2]or 0,8)+(v[w+3]or 0)end;local function x(y)local z=#y;local A={}y[#y+1]=0x80;while#y%64~=56 do y[#y+1]=0 end;local B=math.ceil(#y/64)for w=1,B do A[w]={}for C=1,16 do A[w][C]=u(y,1+(w-1)*64+(C-1)*4)end end;A[B][15],A[B][16]=q(z*8)return A end;local function D(E,F)for C=17,64 do local G=E[C-15]local H=d(g(E[C-15],7),g(E[C-15],18),l(E[C-15],3))local I=d(g(E[C-2],17),g(E[C-2],19),l(E[C-2],10))E[C]=(E[C-16]+H+E[C-7]+I)%a end;local J,i,K,L,M,k,N,O=f(F)for C=1,64 do local P=d(g(M,6),g(M,11),g(M,25))local Q=d(b(M,k),b(c(M),N))local R=(O+P+Q+p[C]+E[C])%a;local S=d(g(J,2),g(J,13),g(J,22))local T=d(d(b(J,i),b(J,K)),b(i,K))local U=(S+T)%a;O,N,k,M,L,K,i,J=N,k,M,(L+R)%a,K,i,J,(R+U)%a end;F[1]=(F[1]+J)%a;F[2]=(F[2]+i)%a;F[3]=(F[3]+K)%a;F[4]=(F[4]+L)%a;F[5]=(F[5]+M)%a;F[6]=(F[6]+k)%a;F[7]=(F[7]+N)%a;F[8]=(F[8]+O)%a;return F end;local V={__tostring=function(J)return string.char(unpack(J))end,__index={toHex=function(self,j)return(\"%02x\"):rep(#self):format(unpack(self))end,isEqual=function(self,W)if type(W)~=\"table\"then return false end;if#self~=#W then return false end;local X=0;for w=1,#self do X=bit32.bor(X,d(self[w],W[w]))end;return X==0 end,sub=function(self,J,i)local z=#self+1;local Y=J%z;local Z=(i or z-1)%z;local X={}local w=1;for C=Y,Z,Y<Z and 1 or-1 do X[w]=self[C]w=w+1 end;return setmetatable(X,byteArray_mt)end}}local function _(W,h)local i={}for w=1,h do i[(w-1)*4+1]=b(l(W[w],24),0xFF)i[(w-1)*4+2]=b(l(W[w],16),0xFF)i[(w-1)*4+3]=b(l(W[w],8),0xFF)i[(w-1)*4+4]=b(W[w],0xFF)end;return setmetatable(i,V)end;local function a0(y)local y=y or\"\"y=type(y)==\"table\"and{f(y)}or{tostring(y):byte(1,-1)}y=x(y)local F={f(o)}for w=1,#y do F=D(y[w],F)end;return _(F,8)end;local function a1(y,a2)local y=type(y)==\"table\"and{f(y)}or{tostring(y):byte(1,-1)}local a2=type(a2)==\"table\"and{f(a2)}or{tostring(a2):byte(1,-1)}local a3=64;a2=#a2>a3 and a0(a2)or a2;local a4={}local a5={}local a6={}for w=1,a3 do a4[w]=d(0x36,a2[w]or 0)a5[w]=d(0x5C,a2[w]or 0)end;for w=1,#y do a4[a3+w]=y[w]end;a4=a0(a4)for w=1,a3 do a6[w]=a5[w]a6[a3+w]=a4[w]end;return a0(a6)end;local function a7(a8,a9,aa,ab)local a9=type(a9)==\"table\"and a9 or{tostring(a9):byte(1,-1)}local ac=32;local ab=ab or 32;local ad=1;local ae={}while ab>0 do local af={}local ag={f(a9)}local ah=ab>ac and ac or ab;ag[#ag+1]=b(l(ad,24),0xFF)ag[#ag+1]=b(l(ad,16),0xFF)ag[#ag+1]=b(l(ad,8),0xFF)ag[#ag+1]=b(ad,0xFF)for C=1,aa do ag=a1(ag,a8)for ai=1,ah do af[ai]=d(ag[ai],af[ai]or 0)end;if C%200==0 then os.queueEvent(\"PBKDF2\",C)coroutine.yield(\"PBKDF2\")end end;ab=ab-ah;ad=ad+1;for ai=1,ah do ae[#ae+1]=af[ai]end end;return setmetatable(ae,V)end;return{digest=a0,hmac=a1,pbkdf2=a7}\
",
    ["server/commands/account.lua"] = "local a=require(\"modules.account\")local b={}b[\"view\"]={desc=\"View someones account information\",func=function(c)local d=a.getSanitizedAccountValues(tostring(c[2]))if d then term.setTextColor(colors.lightGray)print(\"Name: \"..d.name)print(\"UUID: \"..d.uuid)print(\"Created: \"..d.creationDate..\" \"..d.creationTime)print(\"Banned: \"..tostring(d.ban.active))if d.ban.active then print(\"Duration: \"..d.ban.duration)print(\"Reason: \"..d.ban.reason)end;print(\"Role: \"..d.role)print(\"Wallets: \"..table.concat(d.wallets,\", \"))else error(\"Failed to retrieve account information for \"..c[2])end end}b[\"unban\"]={desc=\"Unban an account\",func=function(c)if a.exists(c[2])then if not a.isBanned(c[2])then error(\"Failed to unban \"..c[2]..\", account is not banned!\")end;a.pardon(c[2])term.setTextColor(colors.green)print(c[2]..\" has been unbanned!\")term.setTextColor(colors.lightGray)else error(\"Failed to unban \"..c[2]..\", account not found!\")end end}b[\"pardon\"]={desc=b[\"unban\"].desc,func=b[\"unban\"].func}b[\"delete\"]={desc=\"Permanently delete an account\",func=function(c)if a.exists(c[2])then a.deleteAccount(c[2])term.setTextColor(colors.green)print(c[2]..\" has been deleted!\")term.setTextColor(colors.lightGray)else error(\"Failed to delete \"..c[2]..\", account not found!\")end end}b[\"ban\"]={desc=\"Ban an account. Usage: account ban <name> <duration> <time unit> <reason> \\n Example: account ban player1 50 hours cheating\",func=function(c)if a.exists(c[2])then local e={}e[c[4]]=tonumber(c[3])local f=a.banAccount(c[2],e,c[5])if not f then error(\"Failed to ban \"..c[2]..\", unknown error!\")end;term.setTextColor(colors.green)print(c[2]..\" has been banned successfully for: \"..c[5]..\"\")term.setTextColor(colors.lightGray)else error(\"Failed to ban \"..c[2]..\", account not found!\")end end}b[\"create\"]={desc=\"Create a new account. Usage: account create <name> <password>\",func=function(c)local g=a.createAccount(c[2],c[3])if g~=0 then error(g[1])else term.setTextColor(colors.green)print(\"Successfully created account \"..c[2]..\"!\")term.setTextColor(colors.lightGray)end end}b[\"help\"]={func=function(c)print(\"Account commands -------------------------\")for h,i in pairs(b)do if i.desc then print(h,\": \"..i.desc)end end;print(\"Account commands -------------------------\")end}local function j(c)if not b[c[1]]then error(\"Unknown argument: \"..c[1])end;b[c[1]].func(c)end;return{name=\"account\",run=j}\
",
    ["server/lib/simpleXML.lua"] = "local a={}function a.newParser()local b={}function b:ToXmlString(c)c=string.gsub(c,\"&\",\"&amp;\")c=string.gsub(c,\"<\",\"&lt;\")c=string.gsub(c,\">\",\"&gt;\")c=string.gsub(c,\"\\\"\",\"&quot;\")c=string.gsub(c,\"([^%w%&%;%p%\\t% ])\",function(d)return string.format(\"&#x%X;\",string.byte(d))end)return c end;function b:FromXmlString(c)c=string.gsub(c,\"&#x([%x]+)%;\",function(e)return string.char(tonumber(e,16))end)c=string.gsub(c,\"&#([0-9]+)%;\",function(e)return string.char(tonumber(e,10))end)c=string.gsub(c,\"&quot;\",\"\\\"\")c=string.gsub(c,\"&apos;\",\"'\")c=string.gsub(c,\"&gt;\",\">\")c=string.gsub(c,\"&lt;\",\"<\")c=string.gsub(c,\"&amp;\",\"&\")return c end;function b:ParseArgs(f,g)string.gsub(g,\"(%w+)=([\\\"'])(.-)%2\",function(h,i,j)f:addProperty(h,self:FromXmlString(j))end)end;function b:ParseXmlText(k)local l={}local m=newNode()table.insert(l,m)local n,d,o,p,q;local r,s=1,1;while true do n,s,d,o,p,q=string.find(k,\"<(%/?)([%w_:]+)(.-)(%/?)>\",r)if not n then break end;local t=string.sub(k,r,n-1)if not string.find(t,\"^%s*$\")then local u=(m:value()or\"\")..self:FromXmlString(t)l[#l]:setValue(u)end;if q==\"/\"then local v=newNode(o)self:ParseArgs(v,p)m:addChild(v)elseif d==\"\"then local v=newNode(o)self:ParseArgs(v,p)table.insert(l,v)m=v else local w=table.remove(l)m=l[#l]if#l<1 then error(\"XmlParser: nothing to close with \"..o)end;if w:name()~=o then error(\"XmlParser: trying to close \"..w:name()..\" with \"..o)end;m:addChild(w)end;r=s+1 end;local t=string.sub(k,r)if#l>1 then error(\"XmlParser: unclosed \"..l[#l]:name())end;return m end;function b:loadFile(x)local y=fs.open(x,\"r\")if not y then return nil,\"Error opening file: \"..x end;local k=y.readAll()y.close()return self:ParseXmlText(k),nil end;return b end;function newNode(z)local f={}f.___value=nil;f.___name=z;f.___children={}f.___props={}function f:value()return self.___value end;function f:setValue(A)self.___value=A end;function f:name()return self.___name end;function f:setName(z)self.___name=z end;function f:children()return self.___children end;function f:numChildren()return#self.___children end;function f:addChild(B)if self[B:name()]~=nil then if type(self[B:name()].name)==\"function\"then local C={}table.insert(C,self[B:name()])self[B:name()]=C end;table.insert(self[B:name()],B)else self[B:name()]=B end;table.insert(self.___children,B)end;function f:properties()return self.___props end;function f:numProperties()return#self.___props end;function f:addProperty(z,c)local D=\"@\"..z;if self[D]~=nil then if type(self[D])==\"string\"then local C={}table.insert(C,self[D])self[D]=C end;table.insert(self[D],c)else self[D]=c end;table.insert(self.___props,{name=z,value=self[D]})end;return f end;return a\
",
    ["server/network/networkSession.lua"] = "local a=require\"lib.errors\"local b=require\"lib.fileUtils\"local c=require\"lib.rsa-keygen\"local d={}d.__index=d;local e=\"/GuardLink/server/\"function d.new(f)local self=setmetatable({},d)self.clientManager=require(\"network.clientManager\").new(self,f)self.requestQueue=require(\"network.requestQueue\").new(self,f)self.discovery=f.discoveryChannel or 65535;self.channels={}self.privateKey=nil;self.publicKey=nil;self:initModem()self:initKeys(f.keyPath)self.shutdown=false;return self end;function d:shutdown(g,h)self.shutdown=true;self.shutdownReason=g or\"unknown\"self.exitCode=h or 0 end;function d:initModem()self.modem=peripheral.find(\"modem\")or _G.logger:fatal(\"[networkSession] Failed to launch server: No modems found!\")if not self.modem.isWireless()then _G.logger:fatal(\"[networkSession] Failed to launch server: Modem is not wireless!\")end end;function d:initKeys(i)local j=(i or e)..\"private.key\"local k=(i or e)..\"public.key\"if not b.read(j)then local l=os.clock()_G.logger:info(\"[networkSession] Couldnt find keypair, generating... \")local m,n=c.generateKeyPair()self.privateKey,self.publicKey=m,n;b.newFile(j)b.newFile(k)b.write(j,textutils.serialize(m))b.write(k,textutils.serialize(n))_G.logger:info(\"[networkSession] Finished generating keypair: Took \"..math.ceil(os.clock()-l)..\" seconds.\")_G.logger:info(\"[networkSession] Keys saved to \"..j..\" and \"..k)else self.privateKey=textutils.unserialize(b.read(j))self.publicKey=textutils.unserialize(b.read(k))end end;function d:channelCount()local o=0;for p in pairs(self.channels)do o=o+1 end;return o end;function d:open(q)if self.modem.isOpen(q)then return a.CHANNEL_ALREADY_OPEN end;if self:channelCount()+1>=128 then return a.CHANNEL_CAPACITY_REACHED end;self.modem.open(q)self.channels[q]=true;return 0 end;function d:close(q)if not self.modem.isOpen(q)then return a.CHANNEL_ALREADY_CLOSED end;self.modem.close(q)self.channels[q]=nil;return 0 end;function d:closeAll()for r,p in pairs(self.channels)do self.modem.close(r)end;self.channels={}end;function d:send(q,s)self.modem.transmit(q,0,s)end;function d:listen()while not self.shutdown do local t,u,q,v,s,w=os.pullEvent(\"modem_message\")if self.channels[q]then local x=self.requestQueue:addRequest(s)if x~=0 then _G.logger:error(x[2])end end end;return self.exitCode or 0 end;function d:start()_G.utils.tryCatch(function()_G.logger:info(\"[networkSession] Launching Server with discovery channel: \"..self.discovery)self:open(self.discovery)local h=self:listen()_G.logger:info(\"[networkSession] Server shut down! Reason: \"..(self.shutdownReason or\"unknown\"))if h~=0 then _G.logger:error(\"[networkSession] Exit code: \"..h)end;self:closeAll()end,function(y,z)_G.logger:fatal(\"[networkSession] Server crashed :(\")_G.logger:error(\"[networkSession] Error:\"..y)os.shutdown()end)end;return d\
",
  },
  ["blacklist"] = {
    ["1"] = "server/lib/basalt.lua",
  },
}