string data = "`data";

int ip = 0;
int inst;
int work = 1;
string Reg ="\0\0\0\0\0\0\0\0";
int flag_E = 0;
int flag_G = 0;
int flag_L = 0;
int var1;
int var2;

int imm;
int modrm;
int disp;
int modrml;
int modrmr;
int stack_var;

int read = 0;
int read_adr;
int read_data;

int write = 0;
int write_adr;
int write_data;

int out_string = 0;

int save_stack = 0;
int pop_stack = 0;
int push_stack = 0;

int save_inst = 0;
int proc_inst = 0;
int decode_inst = 0;

int save_imm = 0;
int read_imm = 0;

int save_modrm = 0;
int read_modrm = 0;

int save_modrml = 0;
int read_disp = 0;
int read_modrml_with_disp = 0;
int read_modrml_disp = 0;
int save_disp = 0;
int write_modrml = 0;
int write_modrmr = 0;

#define stop 255
#define i_out 254
#define i_in 253

#define add 0
#define addr 1
#define sub 2
#define subr 3
#define mov 4
#define movr 5

#define cmp 6
#define cmpr 7

#define jmp 8
#define je 9
#define jne 10
#define jl 11
#define jnl 12
#define jg 13
#define jng 14

#define push 15
#define pop 16
#define call 17
#define ret 18

#define shl 19
#define shlr 20
#define shr 21
#define shrr 22

#define and 23
#define andr 24
#define xor 25
#define xorr 26
#define or 27
#define orr 28
#define not 29


while(work){
    if (read){
        read = 0;
        read_data = data[read_adr];
    }elif(out_string){
        if(read_data){
            out read_data;
            read = 1;
            read_adr += 1;
        }else{
            out_string = 0;
            var1 = "\n";
            out var1;
        }
    }elif(write){
        write = 0;
        case(write_adr){
            255: {
                out_string = 1;
                read = 1;
                read_adr = write_data;
            }
        }
        data[write_adr] = write_data;

    }elif(save_inst){
        save_inst = 0;
        inst = read_data;
        ip += 1;
    }elif(save_modrm) {
		save_modrm = 0;
		modrm = read_data;
		var1 = modrm;
		var1 %= 8;
		modrmr = Reg[var1];

        var1 = modrm;
        var1 /= 8;
		var1 %= 8;
		modrml = Reg[var1];

        var1 = modrm;
        var1 /= 64;
		case(var1){
			0: {
				# modrml = modrml;
			}
			1: {
				read = 1;
				read_adr = modrml;
				save_modrml = 1;
			}
			2: {
				read_disp = 1;
				# modrml = modrml;
				read_modrml_with_disp = 1;
			}
			3: {
				read_disp = 1;
				read_modrml_disp = 1;
			}
		}
	}elif(save_disp){
		save_disp = 0;
		disp = read_data;
	}elif(read_disp){
		read_disp = 0;
		read = 1;
		read_adr = ip;
		save_disp = 1;
		ip += 1;
	}elif(read_modrml_with_disp){
		read_modrml_with_disp = 0;
		read = 1;
		read_adr = modrml;
		read_adr += disp;
		save_modrml = 1;
	}elif(read_modrml_disp){
		read_modrml_disp = 0;
		modrml = disp;
	}elif(save_modrml){
		save_modrml = 0;
		modrml = read_data;
	}elif(read_modrm){
		read_modrm = 0;
		save_modrm = 1;
		read = 1;
		read_adr = ip;
		ip += 1;
	}elif(save_imm){
        save_imm = 0;
        imm = read_data;
        ip += 1;

    }elif(read_imm){
        read_imm = 0;
        read = 1;
        save_imm = 1;
        read_adr = ip;
    }elif(save_stack){
        save_stack = 0;
        stack_var = read_data;
    }elif(pop_stack){
		pop_stack = 0;
		save_stack = 1;
		read = 1;
		Reg[7] -= 1;
		read_adr = Reg[7];
    }elif(proc_inst){
        proc_inst = 0;
        case(inst){
            i_out:{
                out modrml;
            }
            i_in:{
                in modrml;
            }
            cmp, cmpr:{
                case(inst){
                    cmpr:{
                        var1 = modrml;
                        modrml = modrmr;
                        modrmr = var1;
                    }
                }
                var1 = 1;
                while (var1){
                    if(modrmr){
                    }else{
                        var1 = 0;
                    }
                    if(modrml){
                    }else{
                        var1 = 0;
                    }
                    modrml, modrmr -= 1;
                }
                modrml, modrmr += 1;
                if(modrml){
                    flag_G = 1;
                    flag_E = 0;
                    flag_L = 0;
                }elif(modrmr){
                    flag_G = 0;
                    flag_E = 0;
                    flag_L = 1;
                }else{
                    flag_G = 0;
                    flag_E = 1;
                    flag_L = 0;
                }
            }
            jmp:{
                ip = imm;
            }
            je:{
                if(flag_E){
                    ip = imm;
                }
            }
            jne:{
                if(flag_E){
                }else{
                    ip = imm;
                }
            }
            jl:{
                if(flag_L){
                    ip = imm;
                }
            }
            jnl:{
                if(flag_L){
                }else{
                    ip = imm;
                }
            }
            jg:{
                if(flag_G){
                    ip = imm;
                }
            }
            jng:{
                if(flag_G){
                }else{
                    ip = imm;
                }
            }

            add:   {modrml += modrmr;}
            addr:  {modrmr += modrml;}
            sub:   {modrml -= modrmr;}
            subr:  {modrmr -= modrml;}
            mov:   {modrml = modrmr;}
            movr:  {modrmr = modrml;}

            shl:   {modrml <<= modrmr;}
            shlr:  {modrmr <<= modrml;}
            shr:   {modrml >>= modrmr;}
            shrr:  {modrmr >>= modrml;}

            push:  {stack_var = modrml;}
            pop:   {modrml = stack_var;}

            call: {
                stack_var = ip;
                ip = imm;
            }
            ret: {
                ip = stack_var;
            }
            not: {
                var2 = 0;

                var1 = modrml;
                var1 %= 2;
                if (var1){}else{
                    var2 += 1;
                }
                var1 = modrml;
                var1 /= 2;
                var1 %= 2;
                if (var1){}else{
                    var2 += 2;
                }
                var1 = modrml;
                var1 /= 4;
                var1 %= 2;
                if (var1){}else{
                    var2 += 4;
                }
                var1 = modrml;
                var1 /= 8;
                var1 %= 2;
                if (var1){}else{
                    var2 += 8;
                }
                var1 = modrml;
                var1 /= 16;
                var1 %= 2;
                if (var1){}else{
                    var2 += 16;
                }
                var1 = modrml;
                var1 /= 32;
                var1 %= 2;
                if (var1){}else{
                    var2 += 32;
                }
                var1 = modrml;
                var1 /= 64;
                var1 %= 2;
                if (var1){}else{
                    var2 += 64;
                }
                var1 = modrml;
                var1 /= 128;
                var1 %= 2;
                if (var1){}else{
                    var2 += 128;
                }
                modrml = var2;
            }
        }
    }elif(push_stack){
		push_stack = 0;
		write = 1;
		write_adr = Reg[7];
		write_data = stack_var;
		Reg[7] += 1;
    }elif(decode_inst){
        decode_inst = 0;
        proc_inst = 1;
        case(inst){
            i_out:{
                read_modrm = 1;
            }
            i_in:{
                read_modrm = 1;
                write_modrml = 1;
            }
            stop:{
                work = 0;
            }

            cmp, cmpr:{
                read_modrm = 1;
            }

            jmp, je, jne, jl, jnl, jg, jng:{
                read_imm = 1;
            }

            add, sub, mov, shl, shr, and, xor, or, not:{
                read_modrm = 1;
				write_modrml = 1;
            }
            addr, subr, movr, shlr, shrr, andr, xorr, orr:{
                read_modrm = 1;
				write_modrmr = 1;
            }
            push: {
				read_modrm = 1;
				push_stack = 1;
			}
			pop: {
				read_modrm = 1;
				pop_stack = 1;
				write_modrml = 1;
			}
			call: {
				read_imm = 1;
				push_stack = 1;
			}
			ret: {
				pop_stack = 1;
			}
			not: {
			    read_modrm = 1;
				write_modrml = 1;
			}
        }
    }elif(write_modrml){
        write_modrml = 0;
        var2 = modrm;
        var2 /= 64;
        case(var2){
            0:{
                var1 = modrm;
                var1 /= 8;
                var1 %= 8;
                Reg[var1] = modrml;
            }
            1:{
                write = 1;
                write_data = modrml;
                var1 = modrm;
                var1 /= 8;
                var1 %= 8;
                write_adr = Reg[var1];
            }
            2:{
                write = 1;
                write_data = modrml;
                var1 = modrm;
                var1 /= 8;
                var1 %= 8;
                write_adr = Reg[var1];
                write_adr += disp;
            }
            3:{}
        }
    }elif(write_modrmr){
        write_modrmr = 0;
        var1 = modrm;
        var1 %= 8;
        Reg[var1] = modrmr;
    }else{
        save_inst = 1;
        decode_inst = 1;
        read = 1;
        read_adr = ip;
    }
}
