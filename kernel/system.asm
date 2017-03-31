
kernel/system:     file format elf32-i386


Disassembly of section .text:

f0100000 <entry>:
.global entry
_start = RELOC(entry)

.text
entry:
	movw	$0x1234,0x472			# warm boot
f0100000:	66 c7 05 72 04 00 00 	movw   $0x1234,0x472
f0100007:	34 12 
	# physical addresses [0, 4MB).  This 4MB region will be
	# sufficient until we set up our real page table in mem_init.

	# Load the physical address of entry_pgdir into cr3.  entry_pgdir
	# is defined in entrypgdir.c.
	movl	$(RELOC(entry_pgdir)), %eax
f0100009:	b8 00 40 10 00       	mov    $0x104000,%eax
	movl	%eax, %cr3
f010000e:	0f 22 d8             	mov    %eax,%cr3
	# Turn on paging.
	movl	%cr0, %eax
f0100011:	0f 20 c0             	mov    %cr0,%eax
	orl	$(CR0_PE|CR0_PG|CR0_WP), %eax
f0100014:	0d 01 00 01 80       	or     $0x80010001,%eax
	movl	%eax, %cr0
f0100019:	0f 22 c0             	mov    %eax,%cr0

	# Now paging is enabled, but we're still running at a low EIP
	# (why is this okay?).  Jump up above KERNBASE before entering
	# C code.
	mov	$relocated, %eax
f010001c:	b8 23 00 10 f0       	mov    $0xf0100023,%eax
	jmp	*%eax
f0100021:	ff e0                	jmp    *%eax

f0100023 <relocated>:

relocated:

    # Setup new gdt
    lgdt    kgdtdesc
f0100023:	0f 01 15 54 00 10 f0 	lgdtl  0xf0100054

	# Setup kernel stack
	movl $0, %ebp
f010002a:	bd 00 00 00 00       	mov    $0x0,%ebp
	movl $(bootstacktop), %esp
f010002f:	bc 00 e0 10 f0       	mov    $0xf010e000,%esp

	call kernel_main
f0100034:	e8 23 00 00 00       	call   f010005c <kernel_main>

f0100039 <die>:
die:
	jmp die
f0100039:	eb fe                	jmp    f0100039 <die>
f010003b:	90                   	nop

f010003c <kgdt>:
	...
f0100044:	ff                   	(bad)  
f0100045:	ff 00                	incl   (%eax)
f0100047:	00 00                	add    %al,(%eax)
f0100049:	9a cf 00 ff ff 00 00 	lcall  $0x0,$0xffff00cf
f0100050:	00 92 cf 00 17 00    	add    %dl,0x1700cf(%edx)

f0100054 <kgdtdesc>:
f0100054:	17                   	pop    %ss
f0100055:	00 3c 00             	add    %bh,(%eax,%eax,1)
f0100058:	10 f0                	adc    %dh,%al
	...

f010005c <kernel_main>:
#include <kernel/trap.h>
#include <kernel/picirq.h>

extern void init_video(void);
void kernel_main(void)
{
f010005c:	83 ec 0c             	sub    $0xc,%esp
    int *ptr;
	init_video();
f010005f:	e8 ab 04 00 00       	call   f010050f <init_video>

	pic_init();
f0100064:	e8 43 00 00 00       	call   f01000ac <pic_init>
  /* TODO: You should uncomment them
   */
	 kbd_init();
f0100069:	e8 60 02 00 00       	call   f01002ce <kbd_init>
	 timer_init();
f010006e:	e8 5c 0f 00 00       	call   f0100fcf <timer_init>
	 trap_init();
f0100073:	e8 cb 06 00 00       	call   f0100743 <trap_init>
     mem_init();
f0100078:	e8 0b 0b 00 00       	call   f0100b88 <mem_init>

	/* Enable interrupt */
    __asm __volatile("sti");
f010007d:	fb                   	sti    
    /* Test for page fault handler */
    ptr = (int*)(0x12345678);
    //*ptr = 1;

	shell();
}
f010007e:	83 c4 0c             	add    $0xc,%esp

    /* Test for page fault handler */
    ptr = (int*)(0x12345678);
    //*ptr = 1;

	shell();
f0100081:	e9 0f 0e 00 00       	jmp    f0100e95 <shell>
	...

f0100088 <irq_setmask_8259A>:
		irq_setmask_8259A(irq_mask_8259A);
}

void
irq_setmask_8259A(uint16_t mask)
{
f0100088:	8b 54 24 04          	mov    0x4(%esp),%edx
	int i;
	irq_mask_8259A = mask;
	if (!didinit)
f010008c:	80 3d 00 e0 10 f0 00 	cmpb   $0x0,0xf010e000
		irq_setmask_8259A(irq_mask_8259A);
}

void
irq_setmask_8259A(uint16_t mask)
{
f0100093:	89 d0                	mov    %edx,%eax
	int i;
	irq_mask_8259A = mask;
f0100095:	66 89 15 00 30 10 f0 	mov    %dx,0xf0103000
	if (!didinit)
f010009c:	74 0d                	je     f01000ab <irq_setmask_8259A+0x23>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010009e:	ba 21 00 00 00       	mov    $0x21,%edx
f01000a3:	ee                   	out    %al,(%dx)
		return;
	outb(IO_PIC1+1, (char)mask);
	outb(IO_PIC2+1, (char)(mask >> 8));
f01000a4:	66 c1 e8 08          	shr    $0x8,%ax
f01000a8:	b2 a1                	mov    $0xa1,%dl
f01000aa:	ee                   	out    %al,(%dx)
f01000ab:	c3                   	ret    

f01000ac <pic_init>:
static bool didinit;

/* Initialize the 8259A interrupt controllers. */
void
pic_init(void)
{
f01000ac:	57                   	push   %edi
f01000ad:	b9 21 00 00 00       	mov    $0x21,%ecx
f01000b2:	56                   	push   %esi
f01000b3:	b0 ff                	mov    $0xff,%al
f01000b5:	53                   	push   %ebx
f01000b6:	89 ca                	mov    %ecx,%edx
f01000b8:	ee                   	out    %al,(%dx)
f01000b9:	be a1 00 00 00       	mov    $0xa1,%esi
f01000be:	89 f2                	mov    %esi,%edx
f01000c0:	ee                   	out    %al,(%dx)
f01000c1:	bf 11 00 00 00       	mov    $0x11,%edi
f01000c6:	bb 20 00 00 00       	mov    $0x20,%ebx
f01000cb:	89 f8                	mov    %edi,%eax
f01000cd:	89 da                	mov    %ebx,%edx
f01000cf:	ee                   	out    %al,(%dx)
f01000d0:	b0 20                	mov    $0x20,%al
f01000d2:	89 ca                	mov    %ecx,%edx
f01000d4:	ee                   	out    %al,(%dx)
f01000d5:	b0 04                	mov    $0x4,%al
f01000d7:	ee                   	out    %al,(%dx)
f01000d8:	b0 03                	mov    $0x3,%al
f01000da:	ee                   	out    %al,(%dx)
f01000db:	b1 a0                	mov    $0xa0,%cl
f01000dd:	89 f8                	mov    %edi,%eax
f01000df:	89 ca                	mov    %ecx,%edx
f01000e1:	ee                   	out    %al,(%dx)
f01000e2:	b0 28                	mov    $0x28,%al
f01000e4:	89 f2                	mov    %esi,%edx
f01000e6:	ee                   	out    %al,(%dx)
f01000e7:	b0 02                	mov    $0x2,%al
f01000e9:	ee                   	out    %al,(%dx)
f01000ea:	b0 01                	mov    $0x1,%al
f01000ec:	ee                   	out    %al,(%dx)
f01000ed:	bf 68 00 00 00       	mov    $0x68,%edi
f01000f2:	89 da                	mov    %ebx,%edx
f01000f4:	89 f8                	mov    %edi,%eax
f01000f6:	ee                   	out    %al,(%dx)
f01000f7:	be 0a 00 00 00       	mov    $0xa,%esi
f01000fc:	89 f0                	mov    %esi,%eax
f01000fe:	ee                   	out    %al,(%dx)
f01000ff:	89 f8                	mov    %edi,%eax
f0100101:	89 ca                	mov    %ecx,%edx
f0100103:	ee                   	out    %al,(%dx)
f0100104:	89 f0                	mov    %esi,%eax
f0100106:	ee                   	out    %al,(%dx)
	outb(IO_PIC1, 0x0a);             /* read IRR by default */

	outb(IO_PIC2, 0x68);               /* OCW3 */
	outb(IO_PIC2, 0x0a);               /* OCW3 */

	if (irq_mask_8259A != 0xFFFF)
f0100107:	66 a1 00 30 10 f0    	mov    0xf0103000,%ax

/* Initialize the 8259A interrupt controllers. */
void
pic_init(void)
{
	didinit = 1;
f010010d:	c6 05 00 e0 10 f0 01 	movb   $0x1,0xf010e000
	outb(IO_PIC1, 0x0a);             /* read IRR by default */

	outb(IO_PIC2, 0x68);               /* OCW3 */
	outb(IO_PIC2, 0x0a);               /* OCW3 */

	if (irq_mask_8259A != 0xFFFF)
f0100114:	66 83 f8 ff          	cmp    $0xffffffff,%ax
f0100118:	74 0a                	je     f0100124 <pic_init+0x78>
		irq_setmask_8259A(irq_mask_8259A);
f010011a:	0f b7 c0             	movzwl %ax,%eax
f010011d:	50                   	push   %eax
f010011e:	e8 65 ff ff ff       	call   f0100088 <irq_setmask_8259A>
f0100123:	58                   	pop    %eax
}
f0100124:	5b                   	pop    %ebx
f0100125:	5e                   	pop    %esi
f0100126:	5f                   	pop    %edi
f0100127:	c3                   	ret    

f0100128 <kbd_proc_data>:
 * Get data from the keyboard.  If we finish a character, return it.  Else 0.
 * Return -1 if no data.
 */
static int
kbd_proc_data(void)
{
f0100128:	83 ec 1c             	sub    $0x1c,%esp

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010012b:	ba 64 00 00 00       	mov    $0x64,%edx
f0100130:	ec                   	in     (%dx),%al
f0100131:	88 c2                	mov    %al,%dl
	volatile int c;
	volatile uint8_t data;
	static uint32_t shift;

	if ((inb(KBSTATP) & KBS_DIB) == 0)
		return -1;
f0100133:	83 c8 ff             	or     $0xffffffff,%eax
{
	volatile int c;
	volatile uint8_t data;
	static uint32_t shift;

	if ((inb(KBSTATP) & KBS_DIB) == 0)
f0100136:	80 e2 01             	and    $0x1,%dl
f0100139:	0f 84 28 01 00 00    	je     f0100267 <kbd_proc_data+0x13f>
f010013f:	ba 60 00 00 00       	mov    $0x60,%edx
f0100144:	ec                   	in     (%dx),%al
		return -1;

	data = inb(KBDATAP);
f0100145:	88 44 24 0f          	mov    %al,0xf(%esp)

	if (data == 0xE0) {
f0100149:	8a 44 24 0f          	mov    0xf(%esp),%al
f010014d:	3c e0                	cmp    $0xe0,%al
f010014f:	75 09                	jne    f010015a <kbd_proc_data+0x32>
		// E0 escape character
		shift |= E0ESC;
f0100151:	83 0d 0c e2 10 f0 40 	orl    $0x40,0xf010e20c
f0100158:	eb 40                	jmp    f010019a <kbd_proc_data+0x72>
		return 0;
	} else if (data & 0x80) {
f010015a:	8a 44 24 0f          	mov    0xf(%esp),%al
f010015e:	8b 15 0c e2 10 f0    	mov    0xf010e20c,%edx
f0100164:	84 c0                	test   %al,%al
f0100166:	79 39                	jns    f01001a1 <kbd_proc_data+0x79>
		// Key released
		data = (shift & E0ESC ? data : data & 0x7F);
f0100168:	f6 c2 40             	test   $0x40,%dl
f010016b:	74 06                	je     f0100173 <kbd_proc_data+0x4b>
f010016d:	8a 44 24 0f          	mov    0xf(%esp),%al
f0100171:	eb 07                	jmp    f010017a <kbd_proc_data+0x52>
f0100173:	8a 44 24 0f          	mov    0xf(%esp),%al
f0100177:	83 e0 7f             	and    $0x7f,%eax
f010017a:	88 44 24 0f          	mov    %al,0xf(%esp)
		shift &= ~(shiftcode[data] | E0ESC);
f010017e:	8a 44 24 0f          	mov    0xf(%esp),%al
f0100182:	0f b6 c0             	movzbl %al,%eax
f0100185:	8a 80 cc 1d 10 f0    	mov    -0xfefe234(%eax),%al
f010018b:	83 c8 40             	or     $0x40,%eax
f010018e:	0f b6 c0             	movzbl %al,%eax
f0100191:	f7 d0                	not    %eax
f0100193:	21 d0                	and    %edx,%eax
f0100195:	a3 0c e2 10 f0       	mov    %eax,0xf010e20c
		return 0;
f010019a:	31 c0                	xor    %eax,%eax
f010019c:	e9 c6 00 00 00       	jmp    f0100267 <kbd_proc_data+0x13f>
	} else if (shift & E0ESC) {
f01001a1:	f6 c2 40             	test   $0x40,%dl
f01001a4:	74 14                	je     f01001ba <kbd_proc_data+0x92>
		// Last character was an E0 escape; or with 0x80
		data |= 0x80;
f01001a6:	8a 44 24 0f          	mov    0xf(%esp),%al
		shift &= ~E0ESC;
f01001aa:	83 e2 bf             	and    $0xffffffbf,%edx
f01001ad:	89 15 0c e2 10 f0    	mov    %edx,0xf010e20c
		data = (shift & E0ESC ? data : data & 0x7F);
		shift &= ~(shiftcode[data] | E0ESC);
		return 0;
	} else if (shift & E0ESC) {
		// Last character was an E0 escape; or with 0x80
		data |= 0x80;
f01001b3:	83 c8 80             	or     $0xffffff80,%eax
f01001b6:	88 44 24 0f          	mov    %al,0xf(%esp)
		shift &= ~E0ESC;
	}

	shift |= shiftcode[data];
f01001ba:	8a 44 24 0f          	mov    0xf(%esp),%al
	shift ^= togglecode[data];
f01001be:	8a 54 24 0f          	mov    0xf(%esp),%dl
		// Last character was an E0 escape; or with 0x80
		data |= 0x80;
		shift &= ~E0ESC;
	}

	shift |= shiftcode[data];
f01001c2:	0f b6 c0             	movzbl %al,%eax
	shift ^= togglecode[data];
f01001c5:	0f b6 d2             	movzbl %dl,%edx
		// Last character was an E0 escape; or with 0x80
		data |= 0x80;
		shift &= ~E0ESC;
	}

	shift |= shiftcode[data];
f01001c8:	0f b6 80 cc 1d 10 f0 	movzbl -0xfefe234(%eax),%eax
	shift ^= togglecode[data];
f01001cf:	0f b6 92 cc 1e 10 f0 	movzbl -0xfefe134(%edx),%edx
		// Last character was an E0 escape; or with 0x80
		data |= 0x80;
		shift &= ~E0ESC;
	}

	shift |= shiftcode[data];
f01001d6:	0b 05 0c e2 10 f0    	or     0xf010e20c,%eax
	shift ^= togglecode[data];
f01001dc:	31 d0                	xor    %edx,%eax

	c = charcode[shift & (CTL | SHIFT)][data];
f01001de:	8a 54 24 0f          	mov    0xf(%esp),%dl
f01001e2:	89 c1                	mov    %eax,%ecx
f01001e4:	83 e1 03             	and    $0x3,%ecx
	if (shift & CAPSLOCK) {
f01001e7:	a8 08                	test   $0x8,%al
	}

	shift |= shiftcode[data];
	shift ^= togglecode[data];

	c = charcode[shift & (CTL | SHIFT)][data];
f01001e9:	8b 0c 8d cc 1f 10 f0 	mov    -0xfefe034(,%ecx,4),%ecx
f01001f0:	0f b6 d2             	movzbl %dl,%edx
		data |= 0x80;
		shift &= ~E0ESC;
	}

	shift |= shiftcode[data];
	shift ^= togglecode[data];
f01001f3:	a3 0c e2 10 f0       	mov    %eax,0xf010e20c

	c = charcode[shift & (CTL | SHIFT)][data];
f01001f8:	0f b6 14 11          	movzbl (%ecx,%edx,1),%edx
f01001fc:	89 54 24 08          	mov    %edx,0x8(%esp)
	if (shift & CAPSLOCK) {
f0100200:	74 38                	je     f010023a <kbd_proc_data+0x112>
		if ('a' <= c && c <= 'z')
f0100202:	8b 54 24 08          	mov    0x8(%esp),%edx
f0100206:	83 fa 60             	cmp    $0x60,%edx
f0100209:	7e 12                	jle    f010021d <kbd_proc_data+0xf5>
f010020b:	8b 54 24 08          	mov    0x8(%esp),%edx
f010020f:	83 fa 7a             	cmp    $0x7a,%edx
f0100212:	7f 09                	jg     f010021d <kbd_proc_data+0xf5>
			c += 'A' - 'a';
f0100214:	8b 54 24 08          	mov    0x8(%esp),%edx
f0100218:	83 ea 20             	sub    $0x20,%edx
f010021b:	eb 19                	jmp    f0100236 <kbd_proc_data+0x10e>
		else if ('A' <= c && c <= 'Z')
f010021d:	8b 54 24 08          	mov    0x8(%esp),%edx
f0100221:	83 fa 40             	cmp    $0x40,%edx
f0100224:	7e 14                	jle    f010023a <kbd_proc_data+0x112>
f0100226:	8b 54 24 08          	mov    0x8(%esp),%edx
f010022a:	83 fa 5a             	cmp    $0x5a,%edx
f010022d:	7f 0b                	jg     f010023a <kbd_proc_data+0x112>
			c += 'a' - 'A';
f010022f:	8b 54 24 08          	mov    0x8(%esp),%edx
f0100233:	83 c2 20             	add    $0x20,%edx
f0100236:	89 54 24 08          	mov    %edx,0x8(%esp)
	}

	// Process special keys
	// Ctrl-Alt-Del: reboot
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
f010023a:	f7 d0                	not    %eax
f010023c:	a8 06                	test   $0x6,%al
f010023e:	75 23                	jne    f0100263 <kbd_proc_data+0x13b>
f0100240:	8b 44 24 08          	mov    0x8(%esp),%eax
f0100244:	3d e9 00 00 00       	cmp    $0xe9,%eax
f0100249:	75 18                	jne    f0100263 <kbd_proc_data+0x13b>
		cprintf("Rebooting!\n");
f010024b:	83 ec 0c             	sub    $0xc,%esp
f010024e:	68 c0 1d 10 f0       	push   $0xf0101dc0
f0100253:	e8 46 05 00 00       	call   f010079e <cprintf>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100258:	ba 92 00 00 00       	mov    $0x92,%edx
f010025d:	b0 03                	mov    $0x3,%al
f010025f:	ee                   	out    %al,(%dx)
f0100260:	83 c4 10             	add    $0x10,%esp
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
f0100263:	8b 44 24 08          	mov    0x8(%esp),%eax
}
f0100267:	83 c4 1c             	add    $0x1c,%esp
f010026a:	c3                   	ret    

f010026b <cons_getc>:
	// so that this function works even when interrupts are disabled
	// (e.g., when called from the kernel monitor).
	//kbd_intr();

	// grab the next character from the input buffer.
	if (cons.rpos != cons.wpos) {
f010026b:	8b 15 04 e2 10 f0    	mov    0xf010e204,%edx
		c = cons.buf[cons.rpos++];
		if (cons.rpos == CONSBUFSIZE)
			cons.rpos = 0;
		return c;
	}
	return 0;
f0100271:	31 c0                	xor    %eax,%eax
	// so that this function works even when interrupts are disabled
	// (e.g., when called from the kernel monitor).
	//kbd_intr();

	// grab the next character from the input buffer.
	if (cons.rpos != cons.wpos) {
f0100273:	3b 15 08 e2 10 f0    	cmp    0xf010e208,%edx
f0100279:	74 1b                	je     f0100296 <cons_getc+0x2b>
		c = cons.buf[cons.rpos++];
f010027b:	8d 4a 01             	lea    0x1(%edx),%ecx
f010027e:	0f b6 82 04 e0 10 f0 	movzbl -0xfef1ffc(%edx),%eax
		if (cons.rpos == CONSBUFSIZE)
			cons.rpos = 0;
f0100285:	31 d2                	xor    %edx,%edx
f0100287:	81 f9 00 02 00 00    	cmp    $0x200,%ecx
f010028d:	0f 45 d1             	cmovne %ecx,%edx
f0100290:	89 15 04 e2 10 f0    	mov    %edx,0xf010e204
		return c;
	}
	return 0;
}
f0100296:	c3                   	ret    

f0100297 <kbd_intr>:
/* 
 *  Note: The interrupt handler
 */
void
kbd_intr(void)
{
f0100297:	53                   	push   %ebx
	while ((c = (*proc)()) != -1) {
		if (c == 0)
			continue;
		cons.buf[cons.wpos++] = c;
		if (cons.wpos == CONSBUFSIZE)
			cons.wpos = 0;
f0100298:	31 db                	xor    %ebx,%ebx
/* 
 *  Note: The interrupt handler
 */
void
kbd_intr(void)
{
f010029a:	83 ec 08             	sub    $0x8,%esp
f010029d:	eb 20                	jmp    f01002bf <kbd_intr+0x28>
cons_intr(int (*proc)(void))
{
	int c;

	while ((c = (*proc)()) != -1) {
		if (c == 0)
f010029f:	85 c0                	test   %eax,%eax
f01002a1:	74 1c                	je     f01002bf <kbd_intr+0x28>
			continue;
		cons.buf[cons.wpos++] = c;
f01002a3:	8b 15 08 e2 10 f0    	mov    0xf010e208,%edx
f01002a9:	88 82 04 e0 10 f0    	mov    %al,-0xfef1ffc(%edx)
f01002af:	8d 42 01             	lea    0x1(%edx),%eax
		if (cons.wpos == CONSBUFSIZE)
			cons.wpos = 0;
f01002b2:	3d 00 02 00 00       	cmp    $0x200,%eax
f01002b7:	0f 44 c3             	cmove  %ebx,%eax
f01002ba:	a3 08 e2 10 f0       	mov    %eax,0xf010e208
static void
cons_intr(int (*proc)(void))
{
	int c;

	while ((c = (*proc)()) != -1) {
f01002bf:	e8 64 fe ff ff       	call   f0100128 <kbd_proc_data>
f01002c4:	83 f8 ff             	cmp    $0xffffffff,%eax
f01002c7:	75 d6                	jne    f010029f <kbd_intr+0x8>
 */
void
kbd_intr(void)
{
	cons_intr(kbd_proc_data);
}
f01002c9:	83 c4 08             	add    $0x8,%esp
f01002cc:	5b                   	pop    %ebx
f01002cd:	c3                   	ret    

f01002ce <kbd_init>:

void kbd_init(void)
{
f01002ce:	83 ec 0c             	sub    $0xc,%esp
	// Drain the kbd buffer so that Bochs generates interrupts.
    cons.rpos = 0;
f01002d1:	c7 05 04 e2 10 f0 00 	movl   $0x0,0xf010e204
f01002d8:	00 00 00 
    cons.wpos = 0;
f01002db:	c7 05 08 e2 10 f0 00 	movl   $0x0,0xf010e208
f01002e2:	00 00 00 
	kbd_intr();
f01002e5:	e8 ad ff ff ff       	call   f0100297 <kbd_intr>
	irq_setmask_8259A(irq_mask_8259A & ~(1<<IRQ_KBD));
f01002ea:	0f b7 05 00 30 10 f0 	movzwl 0xf0103000,%eax
f01002f1:	83 ec 0c             	sub    $0xc,%esp
f01002f4:	25 fd ff 00 00       	and    $0xfffd,%eax
f01002f9:	50                   	push   %eax
f01002fa:	e8 89 fd ff ff       	call   f0100088 <irq_setmask_8259A>
}
f01002ff:	83 c4 1c             	add    $0x1c,%esp
f0100302:	c3                   	ret    

f0100303 <getc>:
/* high-level console I/O */
int getc(void)
{
	int c;

	while ((c = cons_getc()) == 0)
f0100303:	e8 63 ff ff ff       	call   f010026b <cons_getc>
f0100308:	85 c0                	test   %eax,%eax
f010030a:	74 f7                	je     f0100303 <getc>
		/* do nothing */;
	return c;
}
f010030c:	c3                   	ret    
f010030d:	00 00                	add    %al,(%eax)
	...

f0100310 <scroll>:
int attrib = 0x0F;
int csr_x = 0, csr_y = 0;

/* Scrolls the screen */
void scroll(void)
{
f0100310:	56                   	push   %esi
f0100311:	53                   	push   %ebx
f0100312:	83 ec 04             	sub    $0x4,%esp
    /* A blank is defined as a space... we need to give it
    *  backcolor too */
    blank = 0x0 | (attrib << 8);

    /* Row 25 is the end, this means we need to scroll up */
    if(csr_y >= 25)
f0100315:	8b 1d 14 e2 10 f0    	mov    0xf010e214,%ebx
{
    unsigned short blank, temp;

    /* A blank is defined as a space... we need to give it
    *  backcolor too */
    blank = 0x0 | (attrib << 8);
f010031b:	8b 35 04 33 10 f0    	mov    0xf0103304,%esi

    /* Row 25 is the end, this means we need to scroll up */
    if(csr_y >= 25)
f0100321:	83 fb 18             	cmp    $0x18,%ebx
f0100324:	7e 58                	jle    f010037e <scroll+0x6e>
    {
        /* Move the current text chunk that makes up the screen
        *  back in the buffer by a line */
        temp = csr_y - 25 + 1;
f0100326:	83 eb 18             	sub    $0x18,%ebx
        memcpy (textmemptr, textmemptr + temp * 80, (25 - temp) * 80 * 2);
f0100329:	a1 40 e6 10 f0       	mov    0xf010e640,%eax
f010032e:	0f b7 db             	movzwl %bx,%ebx
f0100331:	52                   	push   %edx
f0100332:	69 d3 60 ff ff ff    	imul   $0xffffff60,%ebx,%edx
{
    unsigned short blank, temp;

    /* A blank is defined as a space... we need to give it
    *  backcolor too */
    blank = 0x0 | (attrib << 8);
f0100338:	c1 e6 08             	shl    $0x8,%esi
        temp = csr_y - 25 + 1;
        memcpy (textmemptr, textmemptr + temp * 80, (25 - temp) * 80 * 2);

        /* Finally, we set the chunk of memory that occupies
        *  the last line of text to our 'blank' character */
        memset (textmemptr + (25 - temp) * 80, blank, 80);
f010033b:	0f b7 f6             	movzwl %si,%esi
    if(csr_y >= 25)
    {
        /* Move the current text chunk that makes up the screen
        *  back in the buffer by a line */
        temp = csr_y - 25 + 1;
        memcpy (textmemptr, textmemptr + temp * 80, (25 - temp) * 80 * 2);
f010033e:	81 c2 a0 0f 00 00    	add    $0xfa0,%edx
f0100344:	52                   	push   %edx
f0100345:	69 d3 a0 00 00 00    	imul   $0xa0,%ebx,%edx

        /* Finally, we set the chunk of memory that occupies
        *  the last line of text to our 'blank' character */
        memset (textmemptr + (25 - temp) * 80, blank, 80);
f010034b:	6b db b0             	imul   $0xffffffb0,%ebx,%ebx
    if(csr_y >= 25)
    {
        /* Move the current text chunk that makes up the screen
        *  back in the buffer by a line */
        temp = csr_y - 25 + 1;
        memcpy (textmemptr, textmemptr + temp * 80, (25 - temp) * 80 * 2);
f010034e:	8d 14 10             	lea    (%eax,%edx,1),%edx
f0100351:	52                   	push   %edx
f0100352:	50                   	push   %eax
f0100353:	e8 61 16 00 00       	call   f01019b9 <memcpy>

        /* Finally, we set the chunk of memory that occupies
        *  the last line of text to our 'blank' character */
        memset (textmemptr + (25 - temp) * 80, blank, 80);
f0100358:	83 c4 0c             	add    $0xc,%esp
f010035b:	8d 84 1b a0 0f 00 00 	lea    0xfa0(%ebx,%ebx,1),%eax
f0100362:	03 05 40 e6 10 f0    	add    0xf010e640,%eax
f0100368:	6a 50                	push   $0x50
f010036a:	56                   	push   %esi
f010036b:	50                   	push   %eax
f010036c:	e8 6e 15 00 00       	call   f01018df <memset>
        csr_y = 25 - 1;
f0100371:	83 c4 10             	add    $0x10,%esp
f0100374:	c7 05 14 e2 10 f0 18 	movl   $0x18,0xf010e214
f010037b:	00 00 00 
    }
}
f010037e:	83 c4 04             	add    $0x4,%esp
f0100381:	5b                   	pop    %ebx
f0100382:	5e                   	pop    %esi
f0100383:	c3                   	ret    

f0100384 <move_csr>:
    unsigned short temp;

    /* The equation for finding the index in a linear
    *  chunk of memory can be represented by:
    *  Index = [(y * width) + x] */
    temp = csr_y * 80 + csr_x;
f0100384:	66 6b 0d 14 e2 10 f0 	imul   $0x50,0xf010e214,%cx
f010038b:	50 
f010038c:	ba d4 03 00 00       	mov    $0x3d4,%edx
f0100391:	03 0d 10 e2 10 f0    	add    0xf010e210,%ecx
f0100397:	b0 0e                	mov    $0xe,%al
f0100399:	ee                   	out    %al,(%dx)
    *  where the hardware cursor is to be 'blinking'. To
    *  learn more, you should look up some VGA specific
    *  programming documents. A great start to graphics:
    *  http://www.brackeen.com/home/vga */
    outb(0x3D4, 14);
    outb(0x3D5, temp >> 8);
f010039a:	89 c8                	mov    %ecx,%eax
f010039c:	b2 d5                	mov    $0xd5,%dl
f010039e:	66 c1 e8 08          	shr    $0x8,%ax
f01003a2:	ee                   	out    %al,(%dx)
f01003a3:	b0 0f                	mov    $0xf,%al
f01003a5:	b2 d4                	mov    $0xd4,%dl
f01003a7:	ee                   	out    %al,(%dx)
f01003a8:	b2 d5                	mov    $0xd5,%dl
f01003aa:	88 c8                	mov    %cl,%al
f01003ac:	ee                   	out    %al,(%dx)
    outb(0x3D4, 15);
    outb(0x3D5, temp);
}
f01003ad:	c3                   	ret    

f01003ae <cls>:

/* Clears the screen */
void cls()
{
f01003ae:	56                   	push   %esi
f01003af:	53                   	push   %ebx
    unsigned short blank;
    int i;

    /* Again, we need the 'short' that will be used to
    *  represent a space with color */
    blank = 0x0 | (attrib << 8);
f01003b0:	31 db                	xor    %ebx,%ebx
    outb(0x3D5, temp);
}

/* Clears the screen */
void cls()
{
f01003b2:	83 ec 04             	sub    $0x4,%esp
    unsigned short blank;
    int i;

    /* Again, we need the 'short' that will be used to
    *  represent a space with color */
    blank = 0x0 | (attrib << 8);
f01003b5:	8b 35 04 33 10 f0    	mov    0xf0103304,%esi
f01003bb:	c1 e6 08             	shl    $0x8,%esi

    /* Sets the entire screen to spaces in our current
    *  color */
    for(i = 0; i < 25; i++)
        memset (textmemptr + i * 80, blank, 80);
f01003be:	0f b7 f6             	movzwl %si,%esi
f01003c1:	a1 40 e6 10 f0       	mov    0xf010e640,%eax
f01003c6:	51                   	push   %ecx
f01003c7:	6a 50                	push   $0x50
f01003c9:	56                   	push   %esi
f01003ca:	01 d8                	add    %ebx,%eax
f01003cc:	81 c3 a0 00 00 00    	add    $0xa0,%ebx
f01003d2:	50                   	push   %eax
f01003d3:	e8 07 15 00 00       	call   f01018df <memset>
    *  represent a space with color */
    blank = 0x0 | (attrib << 8);

    /* Sets the entire screen to spaces in our current
    *  color */
    for(i = 0; i < 25; i++)
f01003d8:	83 c4 10             	add    $0x10,%esp
f01003db:	81 fb a0 0f 00 00    	cmp    $0xfa0,%ebx
f01003e1:	75 de                	jne    f01003c1 <cls+0x13>
        memset (textmemptr + i * 80, blank, 80);

    /* Update out virtual cursor, and then move the
    *  hardware cursor */
    csr_x = 0;
f01003e3:	c7 05 10 e2 10 f0 00 	movl   $0x0,0xf010e210
f01003ea:	00 00 00 
    csr_y = 0;
f01003ed:	c7 05 14 e2 10 f0 00 	movl   $0x0,0xf010e214
f01003f4:	00 00 00 
    move_csr();
}
f01003f7:	83 c4 04             	add    $0x4,%esp
f01003fa:	5b                   	pop    %ebx
f01003fb:	5e                   	pop    %esi

    /* Update out virtual cursor, and then move the
    *  hardware cursor */
    csr_x = 0;
    csr_y = 0;
    move_csr();
f01003fc:	e9 83 ff ff ff       	jmp    f0100384 <move_csr>

f0100401 <putch>:
}

/* Puts a single character on the screen */
void putch(unsigned char c)
{
f0100401:	53                   	push   %ebx
f0100402:	83 ec 08             	sub    $0x8,%esp
    unsigned short *where;
    unsigned short att = attrib << 8;
f0100405:	8b 0d 04 33 10 f0    	mov    0xf0103304,%ecx
    move_csr();
}

/* Puts a single character on the screen */
void putch(unsigned char c)
{
f010040b:	8a 44 24 10          	mov    0x10(%esp),%al
    unsigned short *where;
    unsigned short att = attrib << 8;
f010040f:	c1 e1 08             	shl    $0x8,%ecx

    /* Handle a backspace, by moving the cursor back one space */
    if(c == 0x08)
f0100412:	3c 08                	cmp    $0x8,%al
f0100414:	75 21                	jne    f0100437 <putch+0x36>
    {
        if(csr_x != 0) {
f0100416:	a1 10 e2 10 f0       	mov    0xf010e210,%eax
f010041b:	85 c0                	test   %eax,%eax
f010041d:	74 7d                	je     f010049c <putch+0x9b>
          where = (textmemptr-1) + (csr_y * 80 + csr_x);
f010041f:	6b 15 14 e2 10 f0 50 	imul   $0x50,0xf010e214,%edx
f0100426:	8d 5c 10 ff          	lea    -0x1(%eax,%edx,1),%ebx
          *where = 0x0 | att;	/* Character AND attributes: color */
f010042a:	8b 15 40 e6 10 f0    	mov    0xf010e640,%edx
          csr_x--;
f0100430:	48                   	dec    %eax
    /* Handle a backspace, by moving the cursor back one space */
    if(c == 0x08)
    {
        if(csr_x != 0) {
          where = (textmemptr-1) + (csr_y * 80 + csr_x);
          *where = 0x0 | att;	/* Character AND attributes: color */
f0100431:	66 89 0c 5a          	mov    %cx,(%edx,%ebx,2)
f0100435:	eb 0f                	jmp    f0100446 <putch+0x45>
          csr_x--;
        }
    }
    /* Handles a tab by incrementing the cursor's x, but only
    *  to a point that will make it divisible by 8 */
    else if(c == 0x09)
f0100437:	3c 09                	cmp    $0x9,%al
f0100439:	75 12                	jne    f010044d <putch+0x4c>
    {
        csr_x = (csr_x + 8) & ~(8 - 1);
f010043b:	a1 10 e2 10 f0       	mov    0xf010e210,%eax
f0100440:	83 c0 08             	add    $0x8,%eax
f0100443:	83 e0 f8             	and    $0xfffffff8,%eax
f0100446:	a3 10 e2 10 f0       	mov    %eax,0xf010e210
f010044b:	eb 4f                	jmp    f010049c <putch+0x9b>
    }
    /* Handles a 'Carriage Return', which simply brings the
    *  cursor back to the margin */
    else if(c == '\r')
f010044d:	3c 0d                	cmp    $0xd,%al
f010044f:	75 0c                	jne    f010045d <putch+0x5c>
    {
        csr_x = 0;
f0100451:	c7 05 10 e2 10 f0 00 	movl   $0x0,0xf010e210
f0100458:	00 00 00 
f010045b:	eb 3f                	jmp    f010049c <putch+0x9b>
    }
    /* We handle our newlines the way DOS and the BIOS do: we
    *  treat it as if a 'CR' was also there, so we bring the
    *  cursor to the margin and we increment the 'y' value */
    else if(c == '\n')
f010045d:	3c 0a                	cmp    $0xa,%al
f010045f:	75 12                	jne    f0100473 <putch+0x72>
    {
        csr_x = 0;
f0100461:	c7 05 10 e2 10 f0 00 	movl   $0x0,0xf010e210
f0100468:	00 00 00 
        csr_y++;
f010046b:	ff 05 14 e2 10 f0    	incl   0xf010e214
f0100471:	eb 29                	jmp    f010049c <putch+0x9b>
    }
    /* Any character greater than and including a space, is a
    *  printable character. The equation for finding the index
    *  in a linear chunk of memory can be represented by:
    *  Index = [(y * width) + x] */
    else if(c >= ' ')
f0100473:	3c 1f                	cmp    $0x1f,%al
f0100475:	76 25                	jbe    f010049c <putch+0x9b>
    {
        where = textmemptr + (csr_y * 80 + csr_x);
f0100477:	8b 15 10 e2 10 f0    	mov    0xf010e210,%edx
        *where = c | att;	/* Character AND attributes: color */
f010047d:	0f b6 c0             	movzbl %al,%eax
    *  printable character. The equation for finding the index
    *  in a linear chunk of memory can be represented by:
    *  Index = [(y * width) + x] */
    else if(c >= ' ')
    {
        where = textmemptr + (csr_y * 80 + csr_x);
f0100480:	6b 1d 14 e2 10 f0 50 	imul   $0x50,0xf010e214,%ebx
        *where = c | att;	/* Character AND attributes: color */
f0100487:	09 c8                	or     %ecx,%eax
f0100489:	8b 0d 40 e6 10 f0    	mov    0xf010e640,%ecx
    *  printable character. The equation for finding the index
    *  in a linear chunk of memory can be represented by:
    *  Index = [(y * width) + x] */
    else if(c >= ' ')
    {
        where = textmemptr + (csr_y * 80 + csr_x);
f010048f:	01 d3                	add    %edx,%ebx
        *where = c | att;	/* Character AND attributes: color */
        csr_x++;
f0100491:	42                   	inc    %edx
    *  in a linear chunk of memory can be represented by:
    *  Index = [(y * width) + x] */
    else if(c >= ' ')
    {
        where = textmemptr + (csr_y * 80 + csr_x);
        *where = c | att;	/* Character AND attributes: color */
f0100492:	66 89 04 59          	mov    %ax,(%ecx,%ebx,2)
        csr_x++;
f0100496:	89 15 10 e2 10 f0    	mov    %edx,0xf010e210
    }

    /* If the cursor has reached the edge of the screen's width, we
    *  insert a new line in there */
    if(csr_x >= 80)
f010049c:	83 3d 10 e2 10 f0 4f 	cmpl   $0x4f,0xf010e210
f01004a3:	7e 10                	jle    f01004b5 <putch+0xb4>
    {
        csr_x = 0;
        csr_y++;
f01004a5:	ff 05 14 e2 10 f0    	incl   0xf010e214

    /* If the cursor has reached the edge of the screen's width, we
    *  insert a new line in there */
    if(csr_x >= 80)
    {
        csr_x = 0;
f01004ab:	c7 05 10 e2 10 f0 00 	movl   $0x0,0xf010e210
f01004b2:	00 00 00 
        csr_y++;
    }

    /* Scroll the screen if needed, and finally move the cursor */
    scroll();
f01004b5:	e8 56 fe ff ff       	call   f0100310 <scroll>
    move_csr();
}
f01004ba:	83 c4 08             	add    $0x8,%esp
f01004bd:	5b                   	pop    %ebx
        csr_y++;
    }

    /* Scroll the screen if needed, and finally move the cursor */
    scroll();
    move_csr();
f01004be:	e9 c1 fe ff ff       	jmp    f0100384 <move_csr>

f01004c3 <puts>:
}

/* Uses the above routine to output a string... */
void puts(unsigned char *text)
{
f01004c3:	56                   	push   %esi
f01004c4:	53                   	push   %ebx
    int i;

    for (i = 0; i < strlen(text); i++)
f01004c5:	31 db                	xor    %ebx,%ebx
    move_csr();
}

/* Uses the above routine to output a string... */
void puts(unsigned char *text)
{
f01004c7:	83 ec 04             	sub    $0x4,%esp
f01004ca:	8b 74 24 10          	mov    0x10(%esp),%esi
    int i;

    for (i = 0; i < strlen(text); i++)
f01004ce:	eb 11                	jmp    f01004e1 <puts+0x1e>
    {
        putch(text[i]);
f01004d0:	0f b6 04 1e          	movzbl (%esi,%ebx,1),%eax
f01004d4:	83 ec 0c             	sub    $0xc,%esp
/* Uses the above routine to output a string... */
void puts(unsigned char *text)
{
    int i;

    for (i = 0; i < strlen(text); i++)
f01004d7:	43                   	inc    %ebx
    {
        putch(text[i]);
f01004d8:	50                   	push   %eax
f01004d9:	e8 23 ff ff ff       	call   f0100401 <putch>
/* Uses the above routine to output a string... */
void puts(unsigned char *text)
{
    int i;

    for (i = 0; i < strlen(text); i++)
f01004de:	83 c4 10             	add    $0x10,%esp
f01004e1:	83 ec 0c             	sub    $0xc,%esp
f01004e4:	56                   	push   %esi
f01004e5:	e8 26 12 00 00       	call   f0101710 <strlen>
f01004ea:	83 c4 10             	add    $0x10,%esp
f01004ed:	39 c3                	cmp    %eax,%ebx
f01004ef:	7c df                	jl     f01004d0 <puts+0xd>
    {
        putch(text[i]);
    }
}
f01004f1:	83 c4 04             	add    $0x4,%esp
f01004f4:	5b                   	pop    %ebx
f01004f5:	5e                   	pop    %esi
f01004f6:	c3                   	ret    

f01004f7 <settextcolor>:
void settextcolor(unsigned char forecolor, unsigned char backcolor)
{
    /* Lab3: Use this function */
    /* Top 4 bit are the background, bottom 4 bytes
    *  are the foreground color */
    attrib = (backcolor << 4) | (forecolor & 0x0F);
f01004f7:	0f b6 44 24 08       	movzbl 0x8(%esp),%eax
f01004fc:	0f b6 54 24 04       	movzbl 0x4(%esp),%edx
f0100501:	c1 e0 04             	shl    $0x4,%eax
f0100504:	83 e2 0f             	and    $0xf,%edx
f0100507:	09 d0                	or     %edx,%eax
f0100509:	a3 04 33 10 f0       	mov    %eax,0xf0103304
}
f010050e:	c3                   	ret    

f010050f <init_video>:

/* Sets our text-mode VGA pointer, then clears the screen for us */
void init_video(void)
{
f010050f:	83 ec 0c             	sub    $0xc,%esp
    textmemptr = (unsigned short *)0xB8000;
f0100512:	c7 05 40 e6 10 f0 00 	movl   $0xb8000,0xf010e640
f0100519:	80 0b 00 
    cls();
}
f010051c:	83 c4 0c             	add    $0xc,%esp

/* Sets our text-mode VGA pointer, then clears the screen for us */
void init_video(void)
{
    textmemptr = (unsigned short *)0xB8000;
    cls();
f010051f:	e9 8a fe ff ff       	jmp    f01003ae <cls>

f0100524 <print_regs>:
}

/* For debugging */
void
print_regs(struct PushRegs *regs)
{
f0100524:	53                   	push   %ebx
f0100525:	83 ec 10             	sub    $0x10,%esp
f0100528:	8b 5c 24 18          	mov    0x18(%esp),%ebx
	cprintf("  edi  0x%08x\n", regs->reg_edi);
f010052c:	ff 33                	pushl  (%ebx)
f010052e:	68 dc 1f 10 f0       	push   $0xf0101fdc
f0100533:	e8 66 02 00 00       	call   f010079e <cprintf>
	cprintf("  esi  0x%08x\n", regs->reg_esi);
f0100538:	58                   	pop    %eax
f0100539:	5a                   	pop    %edx
f010053a:	ff 73 04             	pushl  0x4(%ebx)
f010053d:	68 eb 1f 10 f0       	push   $0xf0101feb
f0100542:	e8 57 02 00 00       	call   f010079e <cprintf>
	cprintf("  ebp  0x%08x\n", regs->reg_ebp);
f0100547:	5a                   	pop    %edx
f0100548:	59                   	pop    %ecx
f0100549:	ff 73 08             	pushl  0x8(%ebx)
f010054c:	68 fa 1f 10 f0       	push   $0xf0101ffa
f0100551:	e8 48 02 00 00       	call   f010079e <cprintf>
	cprintf("  oesp 0x%08x\n", regs->reg_oesp);
f0100556:	59                   	pop    %ecx
f0100557:	58                   	pop    %eax
f0100558:	ff 73 0c             	pushl  0xc(%ebx)
f010055b:	68 09 20 10 f0       	push   $0xf0102009
f0100560:	e8 39 02 00 00       	call   f010079e <cprintf>
	cprintf("  ebx  0x%08x\n", regs->reg_ebx);
f0100565:	58                   	pop    %eax
f0100566:	5a                   	pop    %edx
f0100567:	ff 73 10             	pushl  0x10(%ebx)
f010056a:	68 18 20 10 f0       	push   $0xf0102018
f010056f:	e8 2a 02 00 00       	call   f010079e <cprintf>
	cprintf("  edx  0x%08x\n", regs->reg_edx);
f0100574:	5a                   	pop    %edx
f0100575:	59                   	pop    %ecx
f0100576:	ff 73 14             	pushl  0x14(%ebx)
f0100579:	68 27 20 10 f0       	push   $0xf0102027
f010057e:	e8 1b 02 00 00       	call   f010079e <cprintf>
	cprintf("  ecx  0x%08x\n", regs->reg_ecx);
f0100583:	59                   	pop    %ecx
f0100584:	58                   	pop    %eax
f0100585:	ff 73 18             	pushl  0x18(%ebx)
f0100588:	68 36 20 10 f0       	push   $0xf0102036
f010058d:	e8 0c 02 00 00       	call   f010079e <cprintf>
	cprintf("  eax  0x%08x\n", regs->reg_eax);
f0100592:	58                   	pop    %eax
f0100593:	5a                   	pop    %edx
f0100594:	ff 73 1c             	pushl  0x1c(%ebx)
f0100597:	68 45 20 10 f0       	push   $0xf0102045
f010059c:	e8 fd 01 00 00       	call   f010079e <cprintf>
}
f01005a1:	83 c4 18             	add    $0x18,%esp
f01005a4:	5b                   	pop    %ebx
f01005a5:	c3                   	ret    

f01005a6 <print_trapframe>:
}

/* For debugging */
void
print_trapframe(struct Trapframe *tf)
{
f01005a6:	56                   	push   %esi
f01005a7:	53                   	push   %ebx
f01005a8:	83 ec 10             	sub    $0x10,%esp
f01005ab:	8b 5c 24 1c          	mov    0x1c(%esp),%ebx
	cprintf("TRAP frame at %p \n");
f01005af:	68 a9 20 10 f0       	push   $0xf01020a9
f01005b4:	e8 e5 01 00 00       	call   f010079e <cprintf>
	print_regs(&tf->tf_regs);
f01005b9:	89 1c 24             	mov    %ebx,(%esp)
f01005bc:	e8 63 ff ff ff       	call   f0100524 <print_regs>
	cprintf("  es   0x----%04x\n", tf->tf_es);
f01005c1:	0f b7 43 20          	movzwl 0x20(%ebx),%eax
f01005c5:	5a                   	pop    %edx
f01005c6:	59                   	pop    %ecx
f01005c7:	50                   	push   %eax
f01005c8:	68 bc 20 10 f0       	push   $0xf01020bc
f01005cd:	e8 cc 01 00 00       	call   f010079e <cprintf>
	cprintf("  ds   0x----%04x\n", tf->tf_ds);
f01005d2:	5e                   	pop    %esi
f01005d3:	58                   	pop    %eax
f01005d4:	0f b7 43 24          	movzwl 0x24(%ebx),%eax
f01005d8:	50                   	push   %eax
f01005d9:	68 cf 20 10 f0       	push   $0xf01020cf
f01005de:	e8 bb 01 00 00       	call   f010079e <cprintf>
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f01005e3:	8b 43 28             	mov    0x28(%ebx),%eax
		"Alignment Check",
		"Machine-Check",
		"SIMD Floating-Point Exception"
	};

	if (trapno < sizeof(excnames)/sizeof(excnames[0]))
f01005e6:	83 c4 10             	add    $0x10,%esp
f01005e9:	83 f8 13             	cmp    $0x13,%eax
f01005ec:	77 09                	ja     f01005f7 <print_trapframe+0x51>
		return excnames[trapno];
f01005ee:	8b 14 85 b8 22 10 f0 	mov    -0xfefdd48(,%eax,4),%edx
f01005f5:	eb 1d                	jmp    f0100614 <print_trapframe+0x6e>
	if (trapno == T_SYSCALL)
f01005f7:	83 f8 30             	cmp    $0x30,%eax
		return "System call";
f01005fa:	ba 54 20 10 f0       	mov    $0xf0102054,%edx
		"SIMD Floating-Point Exception"
	};

	if (trapno < sizeof(excnames)/sizeof(excnames[0]))
		return excnames[trapno];
	if (trapno == T_SYSCALL)
f01005ff:	74 13                	je     f0100614 <print_trapframe+0x6e>
		return "System call";
	if (trapno >= IRQ_OFFSET && trapno < IRQ_OFFSET + 16)
f0100601:	8d 48 e0             	lea    -0x20(%eax),%ecx
		return "Hardware Interrupt";
f0100604:	ba 60 20 10 f0       	mov    $0xf0102060,%edx
f0100609:	83 f9 0f             	cmp    $0xf,%ecx
f010060c:	b9 73 20 10 f0       	mov    $0xf0102073,%ecx
f0100611:	0f 47 d1             	cmova  %ecx,%edx
{
	cprintf("TRAP frame at %p \n");
	print_regs(&tf->tf_regs);
	cprintf("  es   0x----%04x\n", tf->tf_es);
	cprintf("  ds   0x----%04x\n", tf->tf_ds);
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f0100614:	51                   	push   %ecx
f0100615:	52                   	push   %edx
f0100616:	50                   	push   %eax
f0100617:	68 e2 20 10 f0       	push   $0xf01020e2
f010061c:	e8 7d 01 00 00       	call   f010079e <cprintf>
	// If this trap was a page fault that just happened
	// (so %cr2 is meaningful), print the faulting linear address.
	if (tf == last_tf && tf->tf_trapno == T_PGFLT)
f0100621:	83 c4 10             	add    $0x10,%esp
f0100624:	3b 1d 18 e2 10 f0    	cmp    0xf010e218,%ebx
f010062a:	75 19                	jne    f0100645 <print_trapframe+0x9f>
f010062c:	83 7b 28 0e          	cmpl   $0xe,0x28(%ebx)
f0100630:	75 13                	jne    f0100645 <print_trapframe+0x9f>

static __inline uint32_t
rcr2(void)
{
	uint32_t val;
	__asm __volatile("movl %%cr2,%0" : "=r" (val));
f0100632:	0f 20 d0             	mov    %cr2,%eax
		cprintf("  cr2  0x%08x\n", rcr2());
f0100635:	52                   	push   %edx
f0100636:	52                   	push   %edx
f0100637:	50                   	push   %eax
f0100638:	68 f4 20 10 f0       	push   $0xf01020f4
f010063d:	e8 5c 01 00 00       	call   f010079e <cprintf>
f0100642:	83 c4 10             	add    $0x10,%esp
	cprintf("  err  0x%08x", tf->tf_err);
f0100645:	56                   	push   %esi
f0100646:	56                   	push   %esi
f0100647:	ff 73 2c             	pushl  0x2c(%ebx)
f010064a:	68 03 21 10 f0       	push   $0xf0102103
f010064f:	e8 4a 01 00 00       	call   f010079e <cprintf>
	// For page faults, print decoded fault error code:
	// U/K=fault occurred in user/kernel mode
	// W/R=a write/read caused the fault
	// PR=a protection violation caused the fault (NP=page not present).
	if (tf->tf_trapno == T_PGFLT)
f0100654:	83 c4 10             	add    $0x10,%esp
f0100657:	83 7b 28 0e          	cmpl   $0xe,0x28(%ebx)
f010065b:	75 43                	jne    f01006a0 <print_trapframe+0xfa>
		cprintf(" [%s, %s, %s]\n",
			tf->tf_err & 4 ? "user" : "kernel",
			tf->tf_err & 2 ? "write" : "read",
			tf->tf_err & 1 ? "protection" : "not-present");
f010065d:	8b 73 2c             	mov    0x2c(%ebx),%esi
	// For page faults, print decoded fault error code:
	// U/K=fault occurred in user/kernel mode
	// W/R=a write/read caused the fault
	// PR=a protection violation caused the fault (NP=page not present).
	if (tf->tf_trapno == T_PGFLT)
		cprintf(" [%s, %s, %s]\n",
f0100660:	b8 8d 20 10 f0       	mov    $0xf010208d,%eax
f0100665:	b9 82 20 10 f0       	mov    $0xf0102082,%ecx
f010066a:	ba 99 20 10 f0       	mov    $0xf0102099,%edx
f010066f:	f7 c6 01 00 00 00    	test   $0x1,%esi
f0100675:	0f 44 c8             	cmove  %eax,%ecx
f0100678:	f7 c6 02 00 00 00    	test   $0x2,%esi
f010067e:	b8 9f 20 10 f0       	mov    $0xf010209f,%eax
f0100683:	0f 44 d0             	cmove  %eax,%edx
f0100686:	83 e6 04             	and    $0x4,%esi
f0100689:	51                   	push   %ecx
f010068a:	b8 a4 20 10 f0       	mov    $0xf01020a4,%eax
f010068f:	be 50 26 10 f0       	mov    $0xf0102650,%esi
f0100694:	52                   	push   %edx
f0100695:	0f 44 c6             	cmove  %esi,%eax
f0100698:	50                   	push   %eax
f0100699:	68 11 21 10 f0       	push   $0xf0102111
f010069e:	eb 08                	jmp    f01006a8 <print_trapframe+0x102>
			tf->tf_err & 4 ? "user" : "kernel",
			tf->tf_err & 2 ? "write" : "read",
			tf->tf_err & 1 ? "protection" : "not-present");
	else
		cprintf("\n");
f01006a0:	83 ec 0c             	sub    $0xc,%esp
f01006a3:	68 ba 20 10 f0       	push   $0xf01020ba
f01006a8:	e8 f1 00 00 00       	call   f010079e <cprintf>
f01006ad:	5a                   	pop    %edx
f01006ae:	59                   	pop    %ecx
	cprintf("  eip  0x%08x\n", tf->tf_eip);
f01006af:	ff 73 30             	pushl  0x30(%ebx)
f01006b2:	68 20 21 10 f0       	push   $0xf0102120
f01006b7:	e8 e2 00 00 00       	call   f010079e <cprintf>
	cprintf("  cs   0x----%04x\n", tf->tf_cs);
f01006bc:	5e                   	pop    %esi
f01006bd:	58                   	pop    %eax
f01006be:	0f b7 43 34          	movzwl 0x34(%ebx),%eax
f01006c2:	50                   	push   %eax
f01006c3:	68 2f 21 10 f0       	push   $0xf010212f
f01006c8:	e8 d1 00 00 00       	call   f010079e <cprintf>
	cprintf("  flag 0x%08x\n", tf->tf_eflags);
f01006cd:	5a                   	pop    %edx
f01006ce:	59                   	pop    %ecx
f01006cf:	ff 73 38             	pushl  0x38(%ebx)
f01006d2:	68 42 21 10 f0       	push   $0xf0102142
f01006d7:	e8 c2 00 00 00       	call   f010079e <cprintf>
	if ((tf->tf_cs & 3) != 0) {
f01006dc:	83 c4 10             	add    $0x10,%esp
f01006df:	f6 43 34 03          	testb  $0x3,0x34(%ebx)
f01006e3:	74 23                	je     f0100708 <print_trapframe+0x162>
		cprintf("  esp  0x%08x\n", tf->tf_esp);
f01006e5:	50                   	push   %eax
f01006e6:	50                   	push   %eax
f01006e7:	ff 73 3c             	pushl  0x3c(%ebx)
f01006ea:	68 51 21 10 f0       	push   $0xf0102151
f01006ef:	e8 aa 00 00 00       	call   f010079e <cprintf>
		cprintf("  ss   0x----%04x\n", tf->tf_ss);
f01006f4:	0f b7 43 40          	movzwl 0x40(%ebx),%eax
f01006f8:	59                   	pop    %ecx
f01006f9:	5e                   	pop    %esi
f01006fa:	50                   	push   %eax
f01006fb:	68 60 21 10 f0       	push   $0xf0102160
f0100700:	e8 99 00 00 00       	call   f010079e <cprintf>
f0100705:	83 c4 10             	add    $0x10,%esp
	}
}
f0100708:	83 c4 04             	add    $0x4,%esp
f010070b:	5b                   	pop    %ebx
f010070c:	5e                   	pop    %esi
f010070d:	c3                   	ret    

f010070e <default_trap_handler>:

/* 
 * Note: This is the called for every interrupt.
 */
void default_trap_handler(struct Trapframe *tf)
{
f010070e:	83 ec 0c             	sub    $0xc,%esp
f0100711:	8b 44 24 10          	mov    0x10(%esp),%eax
}

static void
trap_dispatch(struct Trapframe *tf)
{
    if(tf->tf_trapno == IRQ_OFFSET + IRQ_KBD)
f0100715:	8b 50 28             	mov    0x28(%eax),%edx
 */
void default_trap_handler(struct Trapframe *tf)
{
	// Record that tf is the last real trapframe so
	// print_trapframe can print some additional information.
	last_tf = tf;
f0100718:	a3 18 e2 10 f0       	mov    %eax,0xf010e218
}

static void
trap_dispatch(struct Trapframe *tf)
{
    if(tf->tf_trapno == IRQ_OFFSET + IRQ_KBD)
f010071d:	83 fa 21             	cmp    $0x21,%edx
f0100720:	75 08                	jne    f010072a <default_trap_handler+0x1c>
	// print_trapframe can print some additional information.
	last_tf = tf;

	// Dispatch based on what type of trap occurred
	trap_dispatch(tf);
}
f0100722:	83 c4 0c             	add    $0xc,%esp
static void
trap_dispatch(struct Trapframe *tf)
{
    if(tf->tf_trapno == IRQ_OFFSET + IRQ_KBD)
    {
        kbd_intr();
f0100725:	e9 6d fb ff ff       	jmp    f0100297 <kbd_intr>
        return;
    }
    if(tf->tf_trapno == IRQ_OFFSET + IRQ_TIMER)
f010072a:	83 fa 20             	cmp    $0x20,%edx
f010072d:	75 08                	jne    f0100737 <default_trap_handler+0x29>
	// print_trapframe can print some additional information.
	last_tf = tf;

	// Dispatch based on what type of trap occurred
	trap_dispatch(tf);
}
f010072f:	83 c4 0c             	add    $0xc,%esp
        kbd_intr();
        return;
    }
    if(tf->tf_trapno == IRQ_OFFSET + IRQ_TIMER)
    {
        timer_handler();
f0100732:	e9 8b 08 00 00       	jmp    f0100fc2 <timer_handler>
   *       We prepared the keyboard handler and timer handler for you
   *       already. Please reference in kernel/kbd.c and kernel/timer.c
   */

	// Unexpected trap: The user process or the kernel has a bug.
	print_trapframe(tf);
f0100737:	89 44 24 10          	mov    %eax,0x10(%esp)
	// print_trapframe can print some additional information.
	last_tf = tf;

	// Dispatch based on what type of trap occurred
	trap_dispatch(tf);
}
f010073b:	83 c4 0c             	add    $0xc,%esp
   *       We prepared the keyboard handler and timer handler for you
   *       already. Please reference in kernel/kbd.c and kernel/timer.c
   */

	// Unexpected trap: The user process or the kernel has a bug.
	print_trapframe(tf);
f010073e:	e9 63 fe ff ff       	jmp    f01005a6 <print_trapframe>

f0100743 <trap_init>:
}

static __inline void
lidt(void *p)
{
	__asm __volatile("lidt (%0)" : : "r" (p));
f0100743:	b8 08 33 10 f0       	mov    $0xf0103308,%eax
f0100748:	0f 01 18             	lidtl  (%eax)

	/* Keyboard interrupt setup */
	/* Timer Trap setup */
  /* Load IDT */

}
f010074b:	c3                   	ret    

f010074c <timer>:
	pushl $(num);							\
	jmp _alltraps


.text
    TRAPHANDLER_NOEC(timer,IRQ_OFFSET + IRQ_TIMER)
f010074c:	6a 00                	push   $0x0
f010074e:	6a 20                	push   $0x20
f0100750:	eb 06                	jmp    f0100758 <_alltraps>

f0100752 <kbd>:
    TRAPHANDLER_NOEC(kbd,IRQ_OFFSET + IRQ_KBD)   
f0100752:	6a 00                	push   $0x0
f0100754:	6a 21                	push   $0x21
f0100756:	eb 00                	jmp    f0100758 <_alltraps>

f0100758 <_alltraps>:
   *       CPU.
   *       You may want to leverage the "pusha" instructions to reduce your work of
   *       pushing all the general purpose registers into the stack.
	 */
/*because  in kernel stack ,we need to reverse the push order trapno ->     ds - > es -> pusha*/
    pushl %ds
f0100758:	1e                   	push   %ds
    pushl %es
f0100759:	06                   	push   %es
    pusha          #  push AX CX BX SP BP SI DI
f010075a:	60                   	pusha  

    /*load kernel segment */
    movw $(GD_KT), %ax
f010075b:	66 b8 08 00          	mov    $0x8,%ax
    movw %ax , %ds
f010075f:	8e d8                	mov    %eax,%ds
    movw %ax , %es
f0100761:	8e c0                	mov    %eax,%es

	pushl %esp # Pass a pointer which points to the Trapframe as an argument to default_trap_handler()
f0100763:	54                   	push   %esp
	call default_trap_handler
f0100764:	e8 a5 ff ff ff       	call   f010070e <default_trap_handler>
    popl %esp
f0100769:	5c                   	pop    %esp
    popa
f010076a:	61                   	popa   
    popl %es
f010076b:	07                   	pop    %es
    popl %ds
f010076c:	1f                   	pop    %ds

	add $8, %esp # Cleans up the pushed error code and pushed ISR number
f010076d:	83 c4 08             	add    $0x8,%esp
	iret # pops 5 things at once: CS, EIP, EFLAGS, SS, and ESP!
f0100770:	cf                   	iret   
f0100771:	00 00                	add    %al,(%eax)
	...

f0100774 <vcprintf>:
#include <inc/stdio.h>


int
vcprintf(const char *fmt, va_list ap)
{
f0100774:	83 ec 1c             	sub    $0x1c,%esp
	int cnt = 0;
f0100777:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
f010077e:	00 

	vprintfmt((void*)putch, &cnt, fmt, ap);
f010077f:	ff 74 24 24          	pushl  0x24(%esp)
f0100783:	ff 74 24 24          	pushl  0x24(%esp)
f0100787:	8d 44 24 14          	lea    0x14(%esp),%eax
f010078b:	50                   	push   %eax
f010078c:	68 01 04 10 f0       	push   $0xf0100401
f0100791:	e8 d9 09 00 00       	call   f010116f <vprintfmt>
	return cnt;
}
f0100796:	8b 44 24 1c          	mov    0x1c(%esp),%eax
f010079a:	83 c4 2c             	add    $0x2c,%esp
f010079d:	c3                   	ret    

f010079e <cprintf>:

int
cprintf(const char *fmt, ...)
{
f010079e:	83 ec 0c             	sub    $0xc,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
f01007a1:	8d 44 24 14          	lea    0x14(%esp),%eax
	cnt = vcprintf(fmt, ap);
f01007a5:	52                   	push   %edx
f01007a6:	52                   	push   %edx
f01007a7:	50                   	push   %eax
f01007a8:	ff 74 24 1c          	pushl  0x1c(%esp)
f01007ac:	e8 c3 ff ff ff       	call   f0100774 <vcprintf>
	va_end(ap);

	return cnt;
}
f01007b1:	83 c4 1c             	add    $0x1c,%esp
f01007b4:	c3                   	ret    
f01007b5:	00 00                	add    %al,(%eax)
	...

f01007b8 <page2pa>:
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01007b8:	2b 05 4c ee 10 f0    	sub    0xf010ee4c,%eax
f01007be:	c1 f8 03             	sar    $0x3,%eax
f01007c1:	c1 e0 0c             	shl    $0xc,%eax
}
f01007c4:	c3                   	ret    

f01007c5 <boot_alloc>:
	// Initialize nextfree if this is the first time.
	// 'end' is a magic symbol automatically generated by the linker,#end is behind on bss
	// which points to the end of the kernel's bss segment:
	// the first virtual address that the linker did *not* assign
	// to any kernel code or global variables.
	if (!nextfree) {
f01007c5:	83 3d 24 e2 10 f0 00 	cmpl   $0x0,0xf010e224
// This function may ONLY be used during initialization,
// before the page_free_list list has been set up.
// boot_alloc return the address which can be used
static void *
boot_alloc(uint32_t n)
{
f01007cc:	89 c2                	mov    %eax,%edx
	// Initialize nextfree if this is the first time.
	// 'end' is a magic symbol automatically generated by the linker,#end is behind on bss
	// which points to the end of the kernel's bss segment:
	// the first virtual address that the linker did *not* assign
	// to any kernel code or global variables.
	if (!nextfree) {
f01007ce:	75 11                	jne    f01007e1 <boot_alloc+0x1c>
		extern char end[];
		nextfree = ROUNDUP((char *) end, PGSIZE);
f01007d0:	b9 53 fe 10 f0       	mov    $0xf010fe53,%ecx
f01007d5:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
f01007db:	89 0d 24 e2 10 f0    	mov    %ecx,0xf010e224

	//!! Allocate a chunk large enough to hold 'n' bytes, then update
	//!! nextfree.  Make sure nextfree is kept aligned
	//!!! to a multiple of PGSIZE.
    //if n is zero return the address currently, else return the address can be div by page
    if (n == 0)
f01007e1:	85 d2                	test   %edx,%edx
f01007e3:	a1 24 e2 10 f0       	mov    0xf010e224,%eax
f01007e8:	74 15                	je     f01007ff <boot_alloc+0x3a>
        return nextfree;
    else if (n > 0)
    {
        result = nextfree;
        nextfree += ROUNDUP(n, PGSIZE);//find the nearest address which is nearest to address is be div by pagesize
f01007ea:	81 c2 ff 0f 00 00    	add    $0xfff,%edx
f01007f0:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f01007f6:	8d 14 10             	lea    (%eax,%edx,1),%edx
f01007f9:	89 15 24 e2 10 f0    	mov    %edx,0xf010e224
    }

	return result;
}
f01007ff:	c3                   	ret    

f0100800 <nvram_read>:
// Detect machine's physical memory setup.
// --------------------------------------------------------------

static int
nvram_read(int r)
{
f0100800:	56                   	push   %esi
f0100801:	53                   	push   %ebx
f0100802:	89 c3                	mov    %eax,%ebx
f0100804:	83 ec 10             	sub    $0x10,%esp
	return mc146818_read(r) | (mc146818_read(r + 1) << 8);
f0100807:	43                   	inc    %ebx
f0100808:	50                   	push   %eax
f0100809:	e8 42 05 00 00       	call   f0100d50 <mc146818_read>
f010080e:	89 1c 24             	mov    %ebx,(%esp)
f0100811:	89 c6                	mov    %eax,%esi
f0100813:	e8 38 05 00 00       	call   f0100d50 <mc146818_read>
}
f0100818:	83 c4 14             	add    $0x14,%esp
f010081b:	5b                   	pop    %ebx
// --------------------------------------------------------------

static int
nvram_read(int r)
{
	return mc146818_read(r) | (mc146818_read(r + 1) << 8);
f010081c:	c1 e0 08             	shl    $0x8,%eax
f010081f:	09 f0                	or     %esi,%eax
}
f0100821:	5e                   	pop    %esi
f0100822:	c3                   	ret    

f0100823 <_kaddr>:
 * virtual address.  It panics if you pass an invalid physical address. */
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
f0100823:	53                   	push   %ebx
	if (PGNUM(pa) >= npages)
f0100824:	89 cb                	mov    %ecx,%ebx
 * virtual address.  It panics if you pass an invalid physical address. */
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
f0100826:	83 ec 08             	sub    $0x8,%esp
	if (PGNUM(pa) >= npages)
f0100829:	c1 eb 0c             	shr    $0xc,%ebx
f010082c:	3b 1d 44 ee 10 f0    	cmp    0xf010ee44,%ebx
f0100832:	72 0d                	jb     f0100841 <_kaddr+0x1e>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100834:	51                   	push   %ecx
f0100835:	68 08 23 10 f0       	push   $0xf0102308
f010083a:	52                   	push   %edx
f010083b:	50                   	push   %eax
f010083c:	e8 8b 04 00 00       	call   f0100ccc <_panic>
	return (void *)(pa + KERNBASE);
f0100841:	8d 81 00 00 00 f0    	lea    -0x10000000(%ecx),%eax
}
f0100847:	83 c4 08             	add    $0x8,%esp
f010084a:	5b                   	pop    %ebx
f010084b:	c3                   	ret    

f010084c <page2kva>:
	return &pages[PGNUM(pa)];
}

static inline void*
page2kva(struct PageInfo *pp)
{
f010084c:	83 ec 0c             	sub    $0xc,%esp
	return KADDR(page2pa(pp));
f010084f:	e8 64 ff ff ff       	call   f01007b8 <page2pa>
f0100854:	ba 4d 00 00 00       	mov    $0x4d,%edx
}
f0100859:	83 c4 0c             	add    $0xc,%esp
}

static inline void*
page2kva(struct PageInfo *pp)
{
	return KADDR(page2pa(pp));
f010085c:	89 c1                	mov    %eax,%ecx
f010085e:	b8 2b 23 10 f0       	mov    $0xf010232b,%eax
f0100863:	eb be                	jmp    f0100823 <_kaddr>

f0100865 <check_va2pa>:
// this functionality for us!  We define our own version to help check
// the check_kern_pgdir() function; it shouldn't be used elsewhere.

static physaddr_t
check_va2pa(pde_t *pgdir, uintptr_t va)
{
f0100865:	56                   	push   %esi
f0100866:	89 d6                	mov    %edx,%esi
f0100868:	53                   	push   %ebx
	pte_t *p;

	pgdir = &pgdir[PDX(va)];
	if (!(*pgdir & PTE_P))
		return ~0;
f0100869:	83 cb ff             	or     $0xffffffff,%ebx
static physaddr_t
check_va2pa(pde_t *pgdir, uintptr_t va)
{
	pte_t *p;

	pgdir = &pgdir[PDX(va)];
f010086c:	c1 ea 16             	shr    $0x16,%edx
// this functionality for us!  We define our own version to help check
// the check_kern_pgdir() function; it shouldn't be used elsewhere.

static physaddr_t
check_va2pa(pde_t *pgdir, uintptr_t va)
{
f010086f:	83 ec 04             	sub    $0x4,%esp
	pte_t *p;

	pgdir = &pgdir[PDX(va)];
	if (!(*pgdir & PTE_P))
f0100872:	8b 0c 90             	mov    (%eax,%edx,4),%ecx
f0100875:	f6 c1 01             	test   $0x1,%cl
f0100878:	74 2e                	je     f01008a8 <check_va2pa+0x43>
		return ~0;
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
f010087a:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
f0100880:	ba a1 02 00 00       	mov    $0x2a1,%edx
f0100885:	b8 3a 23 10 f0       	mov    $0xf010233a,%eax
f010088a:	e8 94 ff ff ff       	call   f0100823 <_kaddr>
	if (!(p[PTX(va)] & PTE_P))
f010088f:	c1 ee 0c             	shr    $0xc,%esi
f0100892:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
f0100898:	8b 04 b0             	mov    (%eax,%esi,4),%eax
		return ~0;
	return PTE_ADDR(p[PTX(va)]);
f010089b:	89 c2                	mov    %eax,%edx
f010089d:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f01008a3:	a8 01                	test   $0x1,%al
f01008a5:	0f 45 da             	cmovne %edx,%ebx
}
f01008a8:	89 d8                	mov    %ebx,%eax
f01008aa:	83 c4 04             	add    $0x4,%esp
f01008ad:	5b                   	pop    %ebx
f01008ae:	5e                   	pop    %esi
f01008af:	c3                   	ret    

f01008b0 <check_page_free_list>:
//
// Check that the pages on the page_free_list are reasonable.
//
static void
check_page_free_list(bool only_low_memory)
{
f01008b0:	55                   	push   %ebp
f01008b1:	57                   	push   %edi
f01008b2:	56                   	push   %esi
f01008b3:	53                   	push   %ebx
f01008b4:	83 ec 1c             	sub    $0x1c,%esp
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
	int nfree_basemem = 0, nfree_extmem = 0;
	char *first_free_page;

	if (!page_free_list)
f01008b7:	8b 1d 20 e2 10 f0    	mov    0xf010e220,%ebx
//
static void
check_page_free_list(bool only_low_memory)
{
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f01008bd:	3c 01                	cmp    $0x1,%al
f01008bf:	19 f6                	sbb    %esi,%esi
f01008c1:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
f01008c7:	46                   	inc    %esi
	int nfree_basemem = 0, nfree_extmem = 0;
	char *first_free_page;

	if (!page_free_list)
f01008c8:	85 db                	test   %ebx,%ebx
f01008ca:	75 10                	jne    f01008dc <check_page_free_list+0x2c>
		panic("'page_free_list' is a null pointer!");
f01008cc:	51                   	push   %ecx
f01008cd:	68 47 23 10 f0       	push   $0xf0102347
f01008d2:	68 df 01 00 00       	push   $0x1df
f01008d7:	e9 b6 00 00 00       	jmp    f0100992 <check_page_free_list+0xe2>

	if (only_low_memory) {
f01008dc:	84 c0                	test   %al,%al
f01008de:	74 4b                	je     f010092b <check_page_free_list+0x7b>
		// Move pages with lower addresses first in the free
		// list, since entry_pgdir does not map all pages.
		struct PageInfo *pp1, *pp2;
		struct PageInfo **tp[2] = { &pp1, &pp2 };
f01008e0:	8d 44 24 0c          	lea    0xc(%esp),%eax
f01008e4:	89 04 24             	mov    %eax,(%esp)
f01008e7:	8d 44 24 08          	lea    0x8(%esp),%eax
f01008eb:	89 44 24 04          	mov    %eax,0x4(%esp)
		for (pp = page_free_list; pp; pp = pp->pp_link) {
			int pagetype = PDX(page2pa(pp)) >= pdx_limit;
f01008ef:	89 d8                	mov    %ebx,%eax
f01008f1:	e8 c2 fe ff ff       	call   f01007b8 <page2pa>
f01008f6:	c1 e8 16             	shr    $0x16,%eax
f01008f9:	39 f0                	cmp    %esi,%eax
f01008fb:	0f 93 c0             	setae  %al
f01008fe:	0f b6 c0             	movzbl %al,%eax
			*tp[pagetype] = pp;
f0100901:	8b 14 84             	mov    (%esp,%eax,4),%edx
f0100904:	89 1a                	mov    %ebx,(%edx)
			tp[pagetype] = &pp->pp_link;
f0100906:	89 1c 84             	mov    %ebx,(%esp,%eax,4)
	if (only_low_memory) {
		// Move pages with lower addresses first in the free
		// list, since entry_pgdir does not map all pages.
		struct PageInfo *pp1, *pp2;
		struct PageInfo **tp[2] = { &pp1, &pp2 };
		for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100909:	8b 1b                	mov    (%ebx),%ebx
f010090b:	85 db                	test   %ebx,%ebx
f010090d:	75 e0                	jne    f01008ef <check_page_free_list+0x3f>
			int pagetype = PDX(page2pa(pp)) >= pdx_limit;
			*tp[pagetype] = pp;
			tp[pagetype] = &pp->pp_link;
		}
		*tp[1] = 0;
f010090f:	8b 44 24 04          	mov    0x4(%esp),%eax
f0100913:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		*tp[0] = pp2;
f0100919:	8b 04 24             	mov    (%esp),%eax
f010091c:	8b 54 24 08          	mov    0x8(%esp),%edx
f0100920:	89 10                	mov    %edx,(%eax)
		page_free_list = pp1;
f0100922:	8b 44 24 0c          	mov    0xc(%esp),%eax
f0100926:	a3 20 e2 10 f0       	mov    %eax,0xf010e220
	}

	// if there's a page that shouldn't be on the free list,
	// try to make sure it eventually causes trouble.
	for (pp = page_free_list; pp; pp = pp->pp_link)
f010092b:	8b 1d 20 e2 10 f0    	mov    0xf010e220,%ebx
f0100931:	eb 2b                	jmp    f010095e <check_page_free_list+0xae>
		if (PDX(page2pa(pp)) < pdx_limit)
f0100933:	89 d8                	mov    %ebx,%eax
f0100935:	e8 7e fe ff ff       	call   f01007b8 <page2pa>
f010093a:	c1 e8 16             	shr    $0x16,%eax
f010093d:	39 f0                	cmp    %esi,%eax
f010093f:	73 1b                	jae    f010095c <check_page_free_list+0xac>
			memset(page2kva(pp), 0x97, 128);
f0100941:	89 d8                	mov    %ebx,%eax
f0100943:	e8 04 ff ff ff       	call   f010084c <page2kva>
f0100948:	52                   	push   %edx
f0100949:	68 80 00 00 00       	push   $0x80
f010094e:	68 97 00 00 00       	push   $0x97
f0100953:	50                   	push   %eax
f0100954:	e8 86 0f 00 00       	call   f01018df <memset>
f0100959:	83 c4 10             	add    $0x10,%esp
		page_free_list = pp1;
	}

	// if there's a page that shouldn't be on the free list,
	// try to make sure it eventually causes trouble.
	for (pp = page_free_list; pp; pp = pp->pp_link)
f010095c:	8b 1b                	mov    (%ebx),%ebx
f010095e:	85 db                	test   %ebx,%ebx
f0100960:	75 d1                	jne    f0100933 <check_page_free_list+0x83>
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
f0100962:	31 c0                	xor    %eax,%eax
static void
check_page_free_list(bool only_low_memory)
{
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
	int nfree_basemem = 0, nfree_extmem = 0;
f0100964:	31 f6                	xor    %esi,%esi
	// try to make sure it eventually causes trouble.
	for (pp = page_free_list; pp; pp = pp->pp_link)
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
f0100966:	e8 5a fe ff ff       	call   f01007c5 <boot_alloc>
static void
check_page_free_list(bool only_low_memory)
{
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
	int nfree_basemem = 0, nfree_extmem = 0;
f010096b:	31 ff                	xor    %edi,%edi
	for (pp = page_free_list; pp; pp = pp->pp_link)
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f010096d:	8b 1d 20 e2 10 f0    	mov    0xf010e220,%ebx
	// try to make sure it eventually causes trouble.
	for (pp = page_free_list; pp; pp = pp->pp_link)
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
f0100973:	89 c5                	mov    %eax,%ebp
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100975:	e9 ff 00 00 00       	jmp    f0100a79 <check_page_free_list+0x1c9>
		// check that we didn't corrupt the free list itself
		assert(pp >= pages);
f010097a:	a1 4c ee 10 f0       	mov    0xf010ee4c,%eax
f010097f:	39 c3                	cmp    %eax,%ebx
f0100981:	73 19                	jae    f010099c <check_page_free_list+0xec>
f0100983:	68 6b 23 10 f0       	push   $0xf010236b
f0100988:	68 77 23 10 f0       	push   $0xf0102377
f010098d:	68 f9 01 00 00       	push   $0x1f9
f0100992:	68 3a 23 10 f0       	push   $0xf010233a
f0100997:	e8 30 03 00 00       	call   f0100ccc <_panic>
		assert(pp < pages + npages);
f010099c:	8b 15 44 ee 10 f0    	mov    0xf010ee44,%edx
f01009a2:	8d 14 d0             	lea    (%eax,%edx,8),%edx
f01009a5:	39 d3                	cmp    %edx,%ebx
f01009a7:	72 11                	jb     f01009ba <check_page_free_list+0x10a>
f01009a9:	68 8c 23 10 f0       	push   $0xf010238c
f01009ae:	68 77 23 10 f0       	push   $0xf0102377
f01009b3:	68 fa 01 00 00       	push   $0x1fa
f01009b8:	eb d8                	jmp    f0100992 <check_page_free_list+0xe2>
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f01009ba:	89 da                	mov    %ebx,%edx
f01009bc:	29 c2                	sub    %eax,%edx
f01009be:	89 d0                	mov    %edx,%eax
f01009c0:	a8 07                	test   $0x7,%al
f01009c2:	74 11                	je     f01009d5 <check_page_free_list+0x125>
f01009c4:	68 a0 23 10 f0       	push   $0xf01023a0
f01009c9:	68 77 23 10 f0       	push   $0xf0102377
f01009ce:	68 fb 01 00 00       	push   $0x1fb
f01009d3:	eb bd                	jmp    f0100992 <check_page_free_list+0xe2>

		// check a few pages that shouldn't be on the free list
		assert(page2pa(pp) != 0);
f01009d5:	89 d8                	mov    %ebx,%eax
f01009d7:	e8 dc fd ff ff       	call   f01007b8 <page2pa>
f01009dc:	85 c0                	test   %eax,%eax
f01009de:	75 11                	jne    f01009f1 <check_page_free_list+0x141>
f01009e0:	68 d2 23 10 f0       	push   $0xf01023d2
f01009e5:	68 77 23 10 f0       	push   $0xf0102377
f01009ea:	68 fe 01 00 00       	push   $0x1fe
f01009ef:	eb a1                	jmp    f0100992 <check_page_free_list+0xe2>
		assert(page2pa(pp) != IOPHYSMEM);
f01009f1:	3d 00 00 0a 00       	cmp    $0xa0000,%eax
f01009f6:	75 11                	jne    f0100a09 <check_page_free_list+0x159>
f01009f8:	68 e3 23 10 f0       	push   $0xf01023e3
f01009fd:	68 77 23 10 f0       	push   $0xf0102377
f0100a02:	68 ff 01 00 00       	push   $0x1ff
f0100a07:	eb 89                	jmp    f0100992 <check_page_free_list+0xe2>
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
f0100a09:	3d 00 f0 0f 00       	cmp    $0xff000,%eax
f0100a0e:	75 14                	jne    f0100a24 <check_page_free_list+0x174>
f0100a10:	68 fc 23 10 f0       	push   $0xf01023fc
f0100a15:	68 77 23 10 f0       	push   $0xf0102377
f0100a1a:	68 00 02 00 00       	push   $0x200
f0100a1f:	e9 6e ff ff ff       	jmp    f0100992 <check_page_free_list+0xe2>
		assert(page2pa(pp) != EXTPHYSMEM);
f0100a24:	3d 00 00 10 00       	cmp    $0x100000,%eax
f0100a29:	75 14                	jne    f0100a3f <check_page_free_list+0x18f>
f0100a2b:	68 1f 24 10 f0       	push   $0xf010241f
f0100a30:	68 77 23 10 f0       	push   $0xf0102377
f0100a35:	68 01 02 00 00       	push   $0x201
f0100a3a:	e9 53 ff ff ff       	jmp    f0100992 <check_page_free_list+0xe2>
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
f0100a3f:	3d ff ff 0f 00       	cmp    $0xfffff,%eax
f0100a44:	76 1f                	jbe    f0100a65 <check_page_free_list+0x1b5>
f0100a46:	89 d8                	mov    %ebx,%eax
f0100a48:	e8 ff fd ff ff       	call   f010084c <page2kva>
f0100a4d:	39 e8                	cmp    %ebp,%eax
f0100a4f:	73 14                	jae    f0100a65 <check_page_free_list+0x1b5>
f0100a51:	68 39 24 10 f0       	push   $0xf0102439
f0100a56:	68 77 23 10 f0       	push   $0xf0102377
f0100a5b:	68 02 02 00 00       	push   $0x202
f0100a60:	e9 2d ff ff ff       	jmp    f0100992 <check_page_free_list+0xe2>

		if (page2pa(pp) < EXTPHYSMEM)
f0100a65:	89 d8                	mov    %ebx,%eax
f0100a67:	e8 4c fd ff ff       	call   f01007b8 <page2pa>
f0100a6c:	3d ff ff 0f 00       	cmp    $0xfffff,%eax
f0100a71:	77 03                	ja     f0100a76 <check_page_free_list+0x1c6>
			++nfree_basemem;
f0100a73:	47                   	inc    %edi
f0100a74:	eb 01                	jmp    f0100a77 <check_page_free_list+0x1c7>
		else
			++nfree_extmem;
f0100a76:	46                   	inc    %esi
	for (pp = page_free_list; pp; pp = pp->pp_link)
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100a77:	8b 1b                	mov    (%ebx),%ebx
f0100a79:	85 db                	test   %ebx,%ebx
f0100a7b:	0f 85 f9 fe ff ff    	jne    f010097a <check_page_free_list+0xca>
			++nfree_basemem;
		else
			++nfree_extmem;
	}

	assert(nfree_basemem > 0);
f0100a81:	85 ff                	test   %edi,%edi
f0100a83:	75 14                	jne    f0100a99 <check_page_free_list+0x1e9>
f0100a85:	68 7e 24 10 f0       	push   $0xf010247e
f0100a8a:	68 77 23 10 f0       	push   $0xf0102377
f0100a8f:	68 0a 02 00 00       	push   $0x20a
f0100a94:	e9 f9 fe ff ff       	jmp    f0100992 <check_page_free_list+0xe2>
	assert(nfree_extmem > 0);
f0100a99:	85 f6                	test   %esi,%esi
f0100a9b:	75 14                	jne    f0100ab1 <check_page_free_list+0x201>
f0100a9d:	68 90 24 10 f0       	push   $0xf0102490
f0100aa2:	68 77 23 10 f0       	push   $0xf0102377
f0100aa7:	68 0b 02 00 00       	push   $0x20b
f0100aac:	e9 e1 fe ff ff       	jmp    f0100992 <check_page_free_list+0xe2>
	cprintf("check_page_free_list() succeeded!\n");
f0100ab1:	83 ec 0c             	sub    $0xc,%esp
f0100ab4:	68 a1 24 10 f0       	push   $0xf01024a1
f0100ab9:	e8 e0 fc ff ff       	call   f010079e <cprintf>
}
f0100abe:	83 c4 2c             	add    $0x2c,%esp
f0100ac1:	5b                   	pop    %ebx
f0100ac2:	5e                   	pop    %esi
f0100ac3:	5f                   	pop    %edi
f0100ac4:	5d                   	pop    %ebp
f0100ac5:	c3                   	ret    

f0100ac6 <_paddr.clone.1>:
 * non-kernel virtual address.
 */
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
f0100ac6:	83 ec 0c             	sub    $0xc,%esp
{
	if ((uint32_t)kva < KERNBASE)
f0100ac9:	81 fa ff ff ff ef    	cmp    $0xefffffff,%edx
f0100acf:	77 11                	ja     f0100ae2 <_paddr.clone.1+0x1c>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0100ad1:	52                   	push   %edx
f0100ad2:	68 c4 24 10 f0       	push   $0xf01024c4
f0100ad7:	50                   	push   %eax
f0100ad8:	68 3a 23 10 f0       	push   $0xf010233a
f0100add:	e8 ea 01 00 00       	call   f0100ccc <_panic>
	return (physaddr_t)kva - KERNBASE;
f0100ae2:	8d 82 00 00 00 10    	lea    0x10000000(%edx),%eax
}
f0100ae8:	83 c4 0c             	add    $0xc,%esp
f0100aeb:	c3                   	ret    

f0100aec <page_init>:
// allocator functions below to allocate and deallocate physical
// memory via the page_free_list.
//
void
page_init(void)
{
f0100aec:	56                   	push   %esi
	// NB: DO NOT actually touch the physical memory corresponding to
	// free pages!
	
    /* TODO */
    size_t i;
	for (i = 0; i < npages; i++) {
f0100aed:	31 f6                	xor    %esi,%esi
// allocator functions below to allocate and deallocate physical
// memory via the page_free_list.
//
void
page_init(void)
{
f0100aef:	53                   	push   %ebx
	// NB: DO NOT actually touch the physical memory corresponding to
	// free pages!
	
    /* TODO */
    size_t i;
	for (i = 0; i < npages; i++) {
f0100af0:	31 db                	xor    %ebx,%ebx
f0100af2:	e9 82 00 00 00       	jmp    f0100b79 <page_init+0x8d>
        if(i ==0)
f0100af7:	85 db                	test   %ebx,%ebx
f0100af9:	75 11                	jne    f0100b0c <page_init+0x20>
        {
            pages[i].pp_ref = 1; //from the hint tell us the 0 page is taken
f0100afb:	a1 4c ee 10 f0       	mov    0xf010ee4c,%eax
f0100b00:	66 c7 40 04 01 00    	movw   $0x1,0x4(%eax)
            pages[i].pp_link=NULL;
f0100b06:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
        }
        if(i<npages_basemem)
f0100b0c:	3b 1d 1c e2 10 f0    	cmp    0xf010e21c,%ebx
f0100b12:	73 1a                	jae    f0100b2e <page_init+0x42>
        {
            pages[i].pp_ref = 0;//free
f0100b14:	a1 4c ee 10 f0       	mov    0xf010ee4c,%eax
            pages[i].pp_link = page_free_list;
f0100b19:	8b 15 20 e2 10 f0    	mov    0xf010e220,%edx
            pages[i].pp_ref = 1; //from the hint tell us the 0 page is taken
            pages[i].pp_link=NULL;
        }
        if(i<npages_basemem)
        {
            pages[i].pp_ref = 0;//free
f0100b1f:	01 f0                	add    %esi,%eax
f0100b21:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)
            pages[i].pp_link = page_free_list;
f0100b27:	89 10                	mov    %edx,(%eax)
            page_free_list = &pages[i];
f0100b29:	a3 20 e2 10 f0       	mov    %eax,0xf010e220
        }
        //(ext-io)/pg is number of io , the other is number of part of ext(kernel)
        if(i < ((EXTPHYSMEM-IOPHYSMEM)/PGSIZE) || i < ((uint32_t)boot_alloc(0)- KERNBASE)/PGSIZE)
f0100b2e:	83 fb 5f             	cmp    $0x5f,%ebx
f0100b31:	76 13                	jbe    f0100b46 <page_init+0x5a>
f0100b33:	31 c0                	xor    %eax,%eax
f0100b35:	e8 8b fc ff ff       	call   f01007c5 <boot_alloc>
f0100b3a:	05 00 00 00 10       	add    $0x10000000,%eax
f0100b3f:	c1 e8 0c             	shr    $0xc,%eax
f0100b42:	39 c3                	cmp    %eax,%ebx
f0100b44:	73 15                	jae    f0100b5b <page_init+0x6f>
        {
            pages[i].pp_ref = 1; //from the hint tell us the 0 page is taken
f0100b46:	a1 4c ee 10 f0       	mov    0xf010ee4c,%eax
f0100b4b:	01 f0                	add    %esi,%eax
f0100b4d:	66 c7 40 04 01 00    	movw   $0x1,0x4(%eax)
            pages[i].pp_link=NULL;
f0100b53:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
f0100b59:	eb 1a                	jmp    f0100b75 <page_init+0x89>
        }
        else
        {
            pages[i].pp_ref = 0;
f0100b5b:	a1 4c ee 10 f0       	mov    0xf010ee4c,%eax
            pages[i].pp_link = page_free_list;
f0100b60:	8b 15 20 e2 10 f0    	mov    0xf010e220,%edx
            pages[i].pp_ref = 1; //from the hint tell us the 0 page is taken
            pages[i].pp_link=NULL;
        }
        else
        {
            pages[i].pp_ref = 0;
f0100b66:	01 f0                	add    %esi,%eax
f0100b68:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)
            pages[i].pp_link = page_free_list;
f0100b6e:	89 10                	mov    %edx,(%eax)
            page_free_list = &pages[i];
f0100b70:	a3 20 e2 10 f0       	mov    %eax,0xf010e220
	// NB: DO NOT actually touch the physical memory corresponding to
	// free pages!
	
    /* TODO */
    size_t i;
	for (i = 0; i < npages; i++) {
f0100b75:	43                   	inc    %ebx
f0100b76:	83 c6 08             	add    $0x8,%esi
f0100b79:	3b 1d 44 ee 10 f0    	cmp    0xf010ee44,%ebx
f0100b7f:	0f 82 72 ff ff ff    	jb     f0100af7 <page_init+0xb>
            pages[i].pp_ref = 0;
            pages[i].pp_link = page_free_list;
            page_free_list = &pages[i];
        }
    }
}
f0100b85:	5b                   	pop    %ebx
f0100b86:	5e                   	pop    %esi
f0100b87:	c3                   	ret    

f0100b88 <mem_init>:
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
{
f0100b88:	53                   	push   %ebx
{
	size_t npages_extmem;

	// Use CMOS calls to measure available base & extended memory.
	// (CMOS calls return results in kilobytes.)
	npages_basemem = (nvram_read(NVRAM_BASELO) * 1024) / PGSIZE;
f0100b89:	b8 15 00 00 00       	mov    $0x15,%eax
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
{
f0100b8e:	83 ec 08             	sub    $0x8,%esp
{
	size_t npages_extmem;

	// Use CMOS calls to measure available base & extended memory.
	// (CMOS calls return results in kilobytes.)
	npages_basemem = (nvram_read(NVRAM_BASELO) * 1024) / PGSIZE;
f0100b91:	bb 04 00 00 00       	mov    $0x4,%ebx
// Above ULIM the user cannot read or write.
void
mem_init(void)
{
	uint32_t cr0;
    nextfree = 0;
f0100b96:	c7 05 24 e2 10 f0 00 	movl   $0x0,0xf010e224
f0100b9d:	00 00 00 
    page_free_list = 0;
f0100ba0:	c7 05 20 e2 10 f0 00 	movl   $0x0,0xf010e220
f0100ba7:	00 00 00 
{
	size_t npages_extmem;

	// Use CMOS calls to measure available base & extended memory.
	// (CMOS calls return results in kilobytes.)
	npages_basemem = (nvram_read(NVRAM_BASELO) * 1024) / PGSIZE;
f0100baa:	e8 51 fc ff ff       	call   f0100800 <nvram_read>
f0100baf:	99                   	cltd   
f0100bb0:	f7 fb                	idiv   %ebx
f0100bb2:	a3 1c e2 10 f0       	mov    %eax,0xf010e21c
	npages_extmem = (nvram_read(NVRAM_EXTLO) * 1024) / PGSIZE;
f0100bb7:	b8 17 00 00 00       	mov    $0x17,%eax
f0100bbc:	e8 3f fc ff ff       	call   f0100800 <nvram_read>
f0100bc1:	99                   	cltd   
f0100bc2:	f7 fb                	idiv   %ebx

	// Calculate the number of physical pages available in both base
	// and extended memory.
	if (npages_extmem)
f0100bc4:	85 c0                	test   %eax,%eax
		npages = (EXTPHYSMEM / PGSIZE) + npages_extmem;
f0100bc6:	8d 90 00 01 00 00    	lea    0x100(%eax),%edx
	npages_basemem = (nvram_read(NVRAM_BASELO) * 1024) / PGSIZE;
	npages_extmem = (nvram_read(NVRAM_EXTLO) * 1024) / PGSIZE;

	// Calculate the number of physical pages available in both base
	// and extended memory.
	if (npages_extmem)
f0100bcc:	75 06                	jne    f0100bd4 <mem_init+0x4c>
		npages = (EXTPHYSMEM / PGSIZE) + npages_extmem;
	else
		npages = npages_basemem;
f0100bce:	8b 15 1c e2 10 f0    	mov    0xf010e21c,%edx

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
		npages * PGSIZE / 1024,
		npages_basemem * PGSIZE / 1024,
		npages_extmem * PGSIZE / 1024);
f0100bd4:	c1 e0 0c             	shl    $0xc,%eax
	if (npages_extmem)
		npages = (EXTPHYSMEM / PGSIZE) + npages_extmem;
	else
		npages = npages_basemem;

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f0100bd7:	c1 e8 0a             	shr    $0xa,%eax
f0100bda:	50                   	push   %eax
		npages * PGSIZE / 1024,
		npages_basemem * PGSIZE / 1024,
f0100bdb:	a1 1c e2 10 f0       	mov    0xf010e21c,%eax
	// Calculate the number of physical pages available in both base
	// and extended memory.
	if (npages_extmem)
		npages = (EXTPHYSMEM / PGSIZE) + npages_extmem;
	else
		npages = npages_basemem;
f0100be0:	89 15 44 ee 10 f0    	mov    %edx,0xf010ee44

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
		npages * PGSIZE / 1024,
		npages_basemem * PGSIZE / 1024,
f0100be6:	c1 e0 0c             	shl    $0xc,%eax
	if (npages_extmem)
		npages = (EXTPHYSMEM / PGSIZE) + npages_extmem;
	else
		npages = npages_basemem;

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f0100be9:	c1 e8 0a             	shr    $0xa,%eax
f0100bec:	50                   	push   %eax
		npages * PGSIZE / 1024,
f0100bed:	a1 44 ee 10 f0       	mov    0xf010ee44,%eax
f0100bf2:	c1 e0 0c             	shl    $0xc,%eax
	if (npages_extmem)
		npages = (EXTPHYSMEM / PGSIZE) + npages_extmem;
	else
		npages = npages_basemem;

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f0100bf5:	c1 e8 0a             	shr    $0xa,%eax
f0100bf8:	50                   	push   %eax
f0100bf9:	68 e8 24 10 f0       	push   $0xf01024e8
f0100bfe:	e8 9b fb ff ff       	call   f010079e <cprintf>
	// Find out how much memory the machine has (npages & npages_basemem).
	i386_detect_memory();//get the number of membase page(can be used) ,io hole page(not) ,extmem page(ok)

	//////////////////////////////////////////////////////////////////////
	//!!! create initial page directory.
	kern_pgdir = (pde_t *) boot_alloc(PGSIZE);//in inc/mmu.h PGSIZE is 4096b = 4KB
f0100c03:	b8 00 10 00 00       	mov    $0x1000,%eax
f0100c08:	e8 b8 fb ff ff       	call   f01007c5 <boot_alloc>
	memset(kern_pgdir, 0, PGSIZE);//memset(start addr , content, size)
f0100c0d:	83 c4 0c             	add    $0xc,%esp
f0100c10:	68 00 10 00 00       	push   $0x1000
f0100c15:	6a 00                	push   $0x0
f0100c17:	50                   	push   %eax
	// Find out how much memory the machine has (npages & npages_basemem).
	i386_detect_memory();//get the number of membase page(can be used) ,io hole page(not) ,extmem page(ok)

	//////////////////////////////////////////////////////////////////////
	//!!! create initial page directory.
	kern_pgdir = (pde_t *) boot_alloc(PGSIZE);//in inc/mmu.h PGSIZE is 4096b = 4KB
f0100c18:	a3 48 ee 10 f0       	mov    %eax,0xf010ee48
	memset(kern_pgdir, 0, PGSIZE);//memset(start addr , content, size)
f0100c1d:	e8 bd 0c 00 00       	call   f01018df <memset>
	// (For now, you don't have understand the greater purpose of the
	// following line.)

	// Permissions: kernel R, user R
    // UVPT is a virtual address in memlayout.h , the address is map to the kern_pgdir(physcial addr)
	kern_pgdir[PDX(UVPT)] = PADDR(kern_pgdir) | PTE_U | PTE_P;
f0100c22:	8b 1d 48 ee 10 f0    	mov    0xf010ee48,%ebx
f0100c28:	b8 8f 00 00 00       	mov    $0x8f,%eax
f0100c2d:	89 da                	mov    %ebx,%edx
f0100c2f:	e8 92 fe ff ff       	call   f0100ac6 <_paddr.clone.1>
f0100c34:	83 c8 05             	or     $0x5,%eax
f0100c37:	89 83 f4 0e 00 00    	mov    %eax,0xef4(%ebx)
	// each physical page, there is a corresponding struct PageInfo in this
	// array.  'npages' is the number of physical pages in memory.  Use memset
	// to initialize all fields of each struct PageInfo to 0.
	// Your code goes here:
    /* TODO */
    pages = (struct PageInfo *)boot_alloc(sizeof(struct PageInfo)*npages);
f0100c3d:	a1 44 ee 10 f0       	mov    0xf010ee44,%eax
f0100c42:	c1 e0 03             	shl    $0x3,%eax
f0100c45:	e8 7b fb ff ff       	call   f01007c5 <boot_alloc>
    memset(pages,0,npages*(sizeof(struct PageInfo)));
f0100c4a:	8b 15 44 ee 10 f0    	mov    0xf010ee44,%edx
f0100c50:	83 c4 0c             	add    $0xc,%esp
f0100c53:	c1 e2 03             	shl    $0x3,%edx
f0100c56:	52                   	push   %edx
f0100c57:	6a 00                	push   $0x0
f0100c59:	50                   	push   %eax
	// each physical page, there is a corresponding struct PageInfo in this
	// array.  'npages' is the number of physical pages in memory.  Use memset
	// to initialize all fields of each struct PageInfo to 0.
	// Your code goes here:
    /* TODO */
    pages = (struct PageInfo *)boot_alloc(sizeof(struct PageInfo)*npages);
f0100c5a:	a3 4c ee 10 f0       	mov    %eax,0xf010ee4c
    memset(pages,0,npages*(sizeof(struct PageInfo)));
f0100c5f:	e8 7b 0c 00 00       	call   f01018df <memset>
	// Now that we've allocated the initial kernel data structures, we set
	// up the list of free physical pages. Once we've done so, all further
	// memory management will go through the page_* functions. In
	// particular, we can now map memory using boot_map_region
	// or page_insert
	page_init();
f0100c64:	e8 83 fe ff ff       	call   f0100aec <page_init>

	check_page_free_list(1);
f0100c69:	b8 01 00 00 00       	mov    $0x1,%eax
f0100c6e:	e8 3d fc ff ff       	call   f01008b0 <check_page_free_list>
	int nfree;
	struct PageInfo *fl;
	char *c;
	int i;

	if (!pages)
f0100c73:	83 c4 10             	add    $0x10,%esp
f0100c76:	83 3d 4c ee 10 f0 00 	cmpl   $0x0,0xf010ee4c
f0100c7d:	75 0d                	jne    f0100c8c <mem_init+0x104>
		panic("'pages' is a null pointer!");
f0100c7f:	53                   	push   %ebx
f0100c80:	68 24 25 10 f0       	push   $0xf0102524
f0100c85:	68 1d 02 00 00       	push   $0x21d
f0100c8a:	eb 1c                	jmp    f0100ca8 <mem_init+0x120>

	// check number of free pages
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f0100c8c:	a1 20 e2 10 f0       	mov    0xf010e220,%eax
f0100c91:	eb 02                	jmp    f0100c95 <mem_init+0x10d>
f0100c93:	8b 00                	mov    (%eax),%eax
f0100c95:	85 c0                	test   %eax,%eax
f0100c97:	75 fa                	jne    f0100c93 <mem_init+0x10b>
		++nfree;

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0100c99:	68 3f 25 10 f0       	push   $0xf010253f
f0100c9e:	68 77 23 10 f0       	push   $0xf0102377
f0100ca3:	68 25 02 00 00       	push   $0x225
f0100ca8:	68 3a 23 10 f0       	push   $0xf010233a
f0100cad:	e8 1a 00 00 00       	call   f0100ccc <_panic>

f0100cb2 <page_alloc>:
// Hint: use page2kva and memset
struct PageInfo *
page_alloc(int alloc_flags)
{
    /* TODO */
}
f0100cb2:	c3                   	ret    

f0100cb3 <page_free>:
{
	// Fill this function in
	// Hint: You may want to panic if pp->pp_ref is nonzero or
	// pp->pp_link is not NULL.
    /* TODO */
}
f0100cb3:	c3                   	ret    

f0100cb4 <page_decref>:
// Decrement the reference count on a page,
// freeing it if there are no more refs.
//
void
page_decref(struct PageInfo* pp)
{
f0100cb4:	8b 44 24 04          	mov    0x4(%esp),%eax
	if (--pp->pp_ref == 0)
f0100cb8:	66 ff 48 04          	decw   0x4(%eax)
		page_free(pp);
}
f0100cbc:	c3                   	ret    

f0100cbd <pgdir_walk>:
pte_t *
pgdir_walk(pde_t *pgdir, const void *va, int create)
{
	// Fill this function in
    /* TODO */
}
f0100cbd:	c3                   	ret    

f0100cbe <page_insert>:
//
int
page_insert(pde_t *pgdir, struct PageInfo *pp, void *va, int perm)
{
    /* TODO */
}
f0100cbe:	c3                   	ret    

f0100cbf <page_lookup>:
//
struct PageInfo *
page_lookup(pde_t *pgdir, void *va, pte_t **pte_store)
{
    /* TODO */
}
f0100cbf:	c3                   	ret    

f0100cc0 <page_remove>:
//
void
page_remove(pde_t *pgdir, void *va)
{
    /* TODO */
}
f0100cc0:	c3                   	ret    

f0100cc1 <tlb_invalidate>:
}

static __inline void
invlpg(void *addr)
{
	__asm __volatile("invlpg (%0)" : : "r" (addr) : "memory");
f0100cc1:	8b 44 24 08          	mov    0x8(%esp),%eax
f0100cc5:	0f 01 38             	invlpg (%eax)
tlb_invalidate(pde_t *pgdir, void *va)
{
	// Flush the entry only if we're modifying the current address space.
	// For now, there is only one address space, so always invalidate.
	invlpg(va);
}
f0100cc8:	c3                   	ret    
f0100cc9:	00 00                	add    %al,(%eax)
	...

f0100ccc <_panic>:
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: mesg", and then enters the kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt,...)
{
f0100ccc:	56                   	push   %esi
f0100ccd:	53                   	push   %ebx
f0100cce:	83 ec 04             	sub    $0x4,%esp
	va_list ap;

	if (panicstr)
f0100cd1:	83 3d 50 ee 10 f0 00 	cmpl   $0x0,0xf010ee50
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: mesg", and then enters the kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt,...)
{
f0100cd8:	8b 5c 24 18          	mov    0x18(%esp),%ebx
	va_list ap;

	if (panicstr)
f0100cdc:	75 37                	jne    f0100d15 <_panic+0x49>
		goto dead;
	panicstr = fmt;
f0100cde:	89 1d 50 ee 10 f0    	mov    %ebx,0xf010ee50

	// Be extra sure that the machine is in as reasonable state
	__asm __volatile("cli; cld");
f0100ce4:	fa                   	cli    
f0100ce5:	fc                   	cld    

	va_start(ap, fmt);
f0100ce6:	8d 74 24 1c          	lea    0x1c(%esp),%esi
	cprintf("kernel panic at %s:%d: ", file, line);
f0100cea:	51                   	push   %ecx
f0100ceb:	ff 74 24 18          	pushl  0x18(%esp)
f0100cef:	ff 74 24 18          	pushl  0x18(%esp)
f0100cf3:	68 55 25 10 f0       	push   $0xf0102555
f0100cf8:	e8 a1 fa ff ff       	call   f010079e <cprintf>
	vcprintf(fmt, ap);
f0100cfd:	58                   	pop    %eax
f0100cfe:	5a                   	pop    %edx
f0100cff:	56                   	push   %esi
f0100d00:	53                   	push   %ebx
f0100d01:	e8 6e fa ff ff       	call   f0100774 <vcprintf>
	cprintf("\n");
f0100d06:	c7 04 24 ba 20 10 f0 	movl   $0xf01020ba,(%esp)
f0100d0d:	e8 8c fa ff ff       	call   f010079e <cprintf>
	va_end(ap);
f0100d12:	83 c4 10             	add    $0x10,%esp
f0100d15:	eb fe                	jmp    f0100d15 <_panic+0x49>

f0100d17 <_warn>:
}

/* like panic, but don't */
void
_warn(const char *file, int line, const char *fmt,...)
{
f0100d17:	53                   	push   %ebx
f0100d18:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
f0100d1b:	8d 5c 24 1c          	lea    0x1c(%esp),%ebx
	cprintf("kernel warning at %s:%d: ", file, line);
f0100d1f:	51                   	push   %ecx
f0100d20:	ff 74 24 18          	pushl  0x18(%esp)
f0100d24:	ff 74 24 18          	pushl  0x18(%esp)
f0100d28:	68 6d 25 10 f0       	push   $0xf010256d
f0100d2d:	e8 6c fa ff ff       	call   f010079e <cprintf>
	vcprintf(fmt, ap);
f0100d32:	58                   	pop    %eax
f0100d33:	5a                   	pop    %edx
f0100d34:	53                   	push   %ebx
f0100d35:	ff 74 24 24          	pushl  0x24(%esp)
f0100d39:	e8 36 fa ff ff       	call   f0100774 <vcprintf>
	cprintf("\n");
f0100d3e:	c7 04 24 ba 20 10 f0 	movl   $0xf01020ba,(%esp)
f0100d45:	e8 54 fa ff ff       	call   f010079e <cprintf>
	va_end(ap);
}
f0100d4a:	83 c4 18             	add    $0x18,%esp
f0100d4d:	5b                   	pop    %ebx
f0100d4e:	c3                   	ret    
	...

f0100d50 <mc146818_read>:
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100d50:	8b 44 24 04          	mov    0x4(%esp),%eax
f0100d54:	ba 70 00 00 00       	mov    $0x70,%edx
f0100d59:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100d5a:	b2 71                	mov    $0x71,%dl
f0100d5c:	ec                   	in     (%dx),%al

unsigned
mc146818_read(unsigned reg)
{
	outb(IO_RTC, reg);
	return inb(IO_RTC+1);
f0100d5d:	0f b6 c0             	movzbl %al,%eax
}
f0100d60:	c3                   	ret    

f0100d61 <mc146818_write>:
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100d61:	ba 70 00 00 00       	mov    $0x70,%edx
f0100d66:	8b 44 24 04          	mov    0x4(%esp),%eax
f0100d6a:	ee                   	out    %al,(%dx)
f0100d6b:	b2 71                	mov    $0x71,%dl
f0100d6d:	8b 44 24 08          	mov    0x8(%esp),%eax
f0100d71:	ee                   	out    %al,(%dx)
void
mc146818_write(unsigned reg, unsigned datum)
{
	outb(IO_RTC, reg);
	outb(IO_RTC+1, datum);
}
f0100d72:	c3                   	ret    
	...

f0100d74 <mon_kerninfo>:
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
	return 0;
}

int mon_kerninfo(int argc, char **argv)
{
f0100d74:	53                   	push   %ebx
   */
    extern int etext;
    extern int data_start;
    extern int end;
    extern int kernel_load_addr;
    cprintf("Kernel code base start=0x%10x size = %ld\n",&kernel_load_addr,(int)&etext-(int)&kernel_load_addr);
f0100d75:	b8 a5 1d 10 f0       	mov    $0xf0101da5,%eax
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
	return 0;
}

int mon_kerninfo(int argc, char **argv)
{
f0100d7a:	83 ec 0c             	sub    $0xc,%esp
   */
    extern int etext;
    extern int data_start;
    extern int end;
    extern int kernel_load_addr;
    cprintf("Kernel code base start=0x%10x size = %ld\n",&kernel_load_addr,(int)&etext-(int)&kernel_load_addr);
f0100d7d:	2d 00 00 10 f0       	sub    $0xf0100000,%eax
f0100d82:	50                   	push   %eax
    cprintf("Kernel data base start=0x%10x size = %ld\n",&data_start,(int)&end-(int)&data_start);
f0100d83:	bb 54 ee 10 f0       	mov    $0xf010ee54,%ebx
   */
    extern int etext;
    extern int data_start;
    extern int end;
    extern int kernel_load_addr;
    cprintf("Kernel code base start=0x%10x size = %ld\n",&kernel_load_addr,(int)&etext-(int)&kernel_load_addr);
f0100d88:	68 00 00 10 f0       	push   $0xf0100000
f0100d8d:	68 87 25 10 f0       	push   $0xf0102587
f0100d92:	e8 07 fa ff ff       	call   f010079e <cprintf>
    cprintf("Kernel data base start=0x%10x size = %ld\n",&data_start,(int)&end-(int)&data_start);
f0100d97:	89 d8                	mov    %ebx,%eax
f0100d99:	83 c4 0c             	add    $0xc,%esp
f0100d9c:	2d 00 30 10 f0       	sub    $0xf0103000,%eax
f0100da1:	50                   	push   %eax
f0100da2:	68 00 30 10 f0       	push   $0xf0103000
f0100da7:	68 b1 25 10 f0       	push   $0xf01025b1
f0100dac:	e8 ed f9 ff ff       	call   f010079e <cprintf>
    cprintf("Kernel executable memory footprint: %ldKB\n",((int)&end-(int)&kernel_load_addr)/1024);
f0100db1:	b9 00 04 00 00       	mov    $0x400,%ecx
f0100db6:	58                   	pop    %eax
f0100db7:	89 d8                	mov    %ebx,%eax
f0100db9:	2d 00 00 10 f0       	sub    $0xf0100000,%eax
f0100dbe:	5a                   	pop    %edx
f0100dbf:	99                   	cltd   
f0100dc0:	f7 f9                	idiv   %ecx
f0100dc2:	50                   	push   %eax
f0100dc3:	68 db 25 10 f0       	push   $0xf01025db
f0100dc8:	e8 d1 f9 ff ff       	call   f010079e <cprintf>
	return 0;
}
f0100dcd:	31 c0                	xor    %eax,%eax
f0100dcf:	83 c4 18             	add    $0x18,%esp
f0100dd2:	5b                   	pop    %ebx
f0100dd3:	c3                   	ret    

f0100dd4 <mon_help>:
}
#define NCOMMANDS (sizeof(commands)/sizeof(commands[0]))


int mon_help(int argc, char **argv)
{
f0100dd4:	83 ec 10             	sub    $0x10,%esp
	int i;

	for (i = 0; i < NCOMMANDS; i++)
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
f0100dd7:	68 06 26 10 f0       	push   $0xf0102606
f0100ddc:	68 24 26 10 f0       	push   $0xf0102624
f0100de1:	68 29 26 10 f0       	push   $0xf0102629
f0100de6:	e8 b3 f9 ff ff       	call   f010079e <cprintf>
f0100deb:	83 c4 0c             	add    $0xc,%esp
f0100dee:	68 32 26 10 f0       	push   $0xf0102632
f0100df3:	68 57 26 10 f0       	push   $0xf0102657
f0100df8:	68 29 26 10 f0       	push   $0xf0102629
f0100dfd:	e8 9c f9 ff ff       	call   f010079e <cprintf>
f0100e02:	83 c4 0c             	add    $0xc,%esp
f0100e05:	68 60 26 10 f0       	push   $0xf0102660
f0100e0a:	68 74 26 10 f0       	push   $0xf0102674
f0100e0f:	68 29 26 10 f0       	push   $0xf0102629
f0100e14:	e8 85 f9 ff ff       	call   f010079e <cprintf>
f0100e19:	83 c4 0c             	add    $0xc,%esp
f0100e1c:	68 7f 26 10 f0       	push   $0xf010267f
f0100e21:	68 94 26 10 f0       	push   $0xf0102694
f0100e26:	68 29 26 10 f0       	push   $0xf0102629
f0100e2b:	e8 6e f9 ff ff       	call   f010079e <cprintf>
	return 0;
}
f0100e30:	31 c0                	xor    %eax,%eax
f0100e32:	83 c4 1c             	add    $0x1c,%esp
f0100e35:	c3                   	ret    

f0100e36 <print_tick>:
    cprintf("Kernel data base start=0x%10x size = %ld\n",&data_start,(int)&end-(int)&data_start);
    cprintf("Kernel executable memory footprint: %ldKB\n",((int)&end-(int)&kernel_load_addr)/1024);
	return 0;
}
int print_tick(int argc, char **argv)
{
f0100e36:	83 ec 0c             	sub    $0xc,%esp
	cprintf("Now tick = %d\n", get_tick());
f0100e39:	e8 8b 01 00 00       	call   f0100fc9 <get_tick>
f0100e3e:	c7 44 24 10 9d 26 10 	movl   $0xf010269d,0x10(%esp)
f0100e45:	f0 
f0100e46:	89 44 24 14          	mov    %eax,0x14(%esp)
}
f0100e4a:	83 c4 0c             	add    $0xc,%esp
    cprintf("Kernel executable memory footprint: %ldKB\n",((int)&end-(int)&kernel_load_addr)/1024);
	return 0;
}
int print_tick(int argc, char **argv)
{
	cprintf("Now tick = %d\n", get_tick());
f0100e4d:	e9 4c f9 ff ff       	jmp    f010079e <cprintf>

f0100e52 <chgcolor>:
	{ "help", "Display this list of commands", mon_help },
	{ "kerninfo", "Display information about the kernel", mon_kerninfo },
	{ "print_tick", "Display system tick", print_tick },
    { "chgcolor","change color of text", chgcolor }
};
int chgcolor(int argc, char *argv[]){
f0100e52:	53                   	push   %ebx
f0100e53:	83 ec 08             	sub    $0x8,%esp
    if(argc == 1)
f0100e56:	83 7c 24 10 01       	cmpl   $0x1,0x10(%esp)
	{ "help", "Display this list of commands", mon_help },
	{ "kerninfo", "Display information about the kernel", mon_kerninfo },
	{ "print_tick", "Display system tick", print_tick },
    { "chgcolor","change color of text", chgcolor }
};
int chgcolor(int argc, char *argv[]){
f0100e5b:	8b 5c 24 14          	mov    0x14(%esp),%ebx
    if(argc == 1)
f0100e5f:	75 0a                	jne    f0100e6b <chgcolor+0x19>
        cprintf("NO input text colors!\n");
f0100e61:	83 ec 0c             	sub    $0xc,%esp
f0100e64:	68 ac 26 10 f0       	push   $0xf01026ac
f0100e69:	eb 1e                	jmp    f0100e89 <chgcolor+0x37>
    else{
        settextcolor((unsigned char)(*argv[1]),0);
f0100e6b:	52                   	push   %edx
f0100e6c:	52                   	push   %edx
f0100e6d:	6a 00                	push   $0x0
f0100e6f:	8b 43 04             	mov    0x4(%ebx),%eax
f0100e72:	0f b6 00             	movzbl (%eax),%eax
f0100e75:	50                   	push   %eax
f0100e76:	e8 7c f6 ff ff       	call   f01004f7 <settextcolor>
        cprintf("Change color %c!\n",*argv[1]);
f0100e7b:	59                   	pop    %ecx
f0100e7c:	58                   	pop    %eax
f0100e7d:	8b 43 04             	mov    0x4(%ebx),%eax
f0100e80:	0f be 00             	movsbl (%eax),%eax
f0100e83:	50                   	push   %eax
f0100e84:	68 c3 26 10 f0       	push   $0xf01026c3
f0100e89:	e8 10 f9 ff ff       	call   f010079e <cprintf>
    }   
    return 0;
                            
}
f0100e8e:	31 c0                	xor    %eax,%eax
f0100e90:	83 c4 18             	add    $0x18,%esp
f0100e93:	5b                   	pop    %ebx
f0100e94:	c3                   	ret    

f0100e95 <shell>:
	}
	cprintf("Unknown command '%s'\n", argv[0]);
	return 0;
}
void shell()
{
f0100e95:	55                   	push   %ebp
f0100e96:	57                   	push   %edi
f0100e97:	56                   	push   %esi
f0100e98:	53                   	push   %ebx
f0100e99:	83 ec 58             	sub    $0x58,%esp
	char *buf;
	cprintf("Welcome to the OSDI course!\n");
f0100e9c:	68 d5 26 10 f0       	push   $0xf01026d5
f0100ea1:	e8 f8 f8 ff ff       	call   f010079e <cprintf>
	cprintf("Type 'help' for a list of commands.\n");
f0100ea6:	c7 04 24 f2 26 10 f0 	movl   $0xf01026f2,(%esp)
f0100ead:	e8 ec f8 ff ff       	call   f010079e <cprintf>
f0100eb2:	83 c4 10             	add    $0x10,%esp
	// Lookup and invoke the command
	if (argc == 0)
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
		if (strcmp(argv[0], commands[i].name) == 0)
			return commands[i].func(argc, argv);
f0100eb5:	89 e5                	mov    %esp,%ebp
	cprintf("Welcome to the OSDI course!\n");
	cprintf("Type 'help' for a list of commands.\n");

	while(1)
	{
		buf = readline("OSDI> ");
f0100eb7:	83 ec 0c             	sub    $0xc,%esp
f0100eba:	68 17 27 10 f0       	push   $0xf0102717
f0100ebf:	e8 9c 07 00 00       	call   f0101660 <readline>
		if (buf != NULL)
f0100ec4:	83 c4 10             	add    $0x10,%esp
f0100ec7:	85 c0                	test   %eax,%eax
	cprintf("Welcome to the OSDI course!\n");
	cprintf("Type 'help' for a list of commands.\n");

	while(1)
	{
		buf = readline("OSDI> ");
f0100ec9:	89 c3                	mov    %eax,%ebx
		if (buf != NULL)
f0100ecb:	74 ea                	je     f0100eb7 <shell+0x22>
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
f0100ecd:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
	int argc;
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
f0100ed4:	31 f6                	xor    %esi,%esi
f0100ed6:	eb 04                	jmp    f0100edc <shell+0x47>
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
			*buf++ = 0;
f0100ed8:	c6 03 00             	movb   $0x0,(%ebx)
f0100edb:	43                   	inc    %ebx
	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
f0100edc:	8a 03                	mov    (%ebx),%al
f0100ede:	84 c0                	test   %al,%al
f0100ee0:	74 17                	je     f0100ef9 <shell+0x64>
f0100ee2:	57                   	push   %edi
f0100ee3:	0f be c0             	movsbl %al,%eax
f0100ee6:	57                   	push   %edi
f0100ee7:	50                   	push   %eax
f0100ee8:	68 1e 27 10 f0       	push   $0xf010271e
f0100eed:	e8 8f 09 00 00       	call   f0101881 <strchr>
f0100ef2:	83 c4 10             	add    $0x10,%esp
f0100ef5:	85 c0                	test   %eax,%eax
f0100ef7:	75 df                	jne    f0100ed8 <shell+0x43>
			*buf++ = 0;
		if (*buf == 0)
f0100ef9:	80 3b 00             	cmpb   $0x0,(%ebx)
f0100efc:	74 36                	je     f0100f34 <shell+0x9f>
			break;

		// save and scan past next arg
		if (argc == MAXARGS-1) {
f0100efe:	83 fe 0f             	cmp    $0xf,%esi
f0100f01:	75 0b                	jne    f0100f0e <shell+0x79>
			cprintf("Too many arguments (max %d)\n", MAXARGS);
f0100f03:	51                   	push   %ecx
f0100f04:	51                   	push   %ecx
f0100f05:	6a 10                	push   $0x10
f0100f07:	68 23 27 10 f0       	push   $0xf0102723
f0100f0c:	eb 7d                	jmp    f0100f8b <shell+0xf6>
			return 0;
		}
		argv[argc++] = buf;
f0100f0e:	89 1c b4             	mov    %ebx,(%esp,%esi,4)
f0100f11:	46                   	inc    %esi
f0100f12:	eb 01                	jmp    f0100f15 <shell+0x80>
		while (*buf && !strchr(WHITESPACE, *buf))
			buf++;
f0100f14:	43                   	inc    %ebx
		if (argc == MAXARGS-1) {
			cprintf("Too many arguments (max %d)\n", MAXARGS);
			return 0;
		}
		argv[argc++] = buf;
		while (*buf && !strchr(WHITESPACE, *buf))
f0100f15:	8a 03                	mov    (%ebx),%al
f0100f17:	84 c0                	test   %al,%al
f0100f19:	74 c1                	je     f0100edc <shell+0x47>
f0100f1b:	52                   	push   %edx
f0100f1c:	0f be c0             	movsbl %al,%eax
f0100f1f:	52                   	push   %edx
f0100f20:	50                   	push   %eax
f0100f21:	68 1e 27 10 f0       	push   $0xf010271e
f0100f26:	e8 56 09 00 00       	call   f0101881 <strchr>
f0100f2b:	83 c4 10             	add    $0x10,%esp
f0100f2e:	85 c0                	test   %eax,%eax
f0100f30:	74 e2                	je     f0100f14 <shell+0x7f>
f0100f32:	eb a8                	jmp    f0100edc <shell+0x47>
			buf++;
	}
	argv[argc] = 0;

	// Lookup and invoke the command
	if (argc == 0)
f0100f34:	85 f6                	test   %esi,%esi
		}
		argv[argc++] = buf;
		while (*buf && !strchr(WHITESPACE, *buf))
			buf++;
	}
	argv[argc] = 0;
f0100f36:	c7 04 b4 00 00 00 00 	movl   $0x0,(%esp,%esi,4)

	// Lookup and invoke the command
	if (argc == 0)
f0100f3d:	0f 84 74 ff ff ff    	je     f0100eb7 <shell+0x22>
f0100f43:	bf 58 27 10 f0       	mov    $0xf0102758,%edi
f0100f48:	31 db                	xor    %ebx,%ebx
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
		if (strcmp(argv[0], commands[i].name) == 0)
f0100f4a:	50                   	push   %eax
f0100f4b:	50                   	push   %eax
f0100f4c:	ff 37                	pushl  (%edi)
f0100f4e:	83 c7 0c             	add    $0xc,%edi
f0100f51:	ff 74 24 0c          	pushl  0xc(%esp)
f0100f55:	e8 b0 08 00 00       	call   f010180a <strcmp>
f0100f5a:	83 c4 10             	add    $0x10,%esp
f0100f5d:	85 c0                	test   %eax,%eax
f0100f5f:	75 19                	jne    f0100f7a <shell+0xe5>
			return commands[i].func(argc, argv);
f0100f61:	6b db 0c             	imul   $0xc,%ebx,%ebx
f0100f64:	57                   	push   %edi
f0100f65:	57                   	push   %edi
f0100f66:	55                   	push   %ebp
f0100f67:	56                   	push   %esi
f0100f68:	ff 93 60 27 10 f0    	call   *-0xfefd8a0(%ebx)
	while(1)
	{
		buf = readline("OSDI> ");
		if (buf != NULL)
		{
			if (runcmd(buf) < 0)
f0100f6e:	83 c4 10             	add    $0x10,%esp
f0100f71:	85 c0                	test   %eax,%eax
f0100f73:	78 23                	js     f0100f98 <shell+0x103>
f0100f75:	e9 3d ff ff ff       	jmp    f0100eb7 <shell+0x22>
	argv[argc] = 0;

	// Lookup and invoke the command
	if (argc == 0)
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
f0100f7a:	43                   	inc    %ebx
f0100f7b:	83 fb 04             	cmp    $0x4,%ebx
f0100f7e:	75 ca                	jne    f0100f4a <shell+0xb5>
		if (strcmp(argv[0], commands[i].name) == 0)
			return commands[i].func(argc, argv);
	}
	cprintf("Unknown command '%s'\n", argv[0]);
f0100f80:	51                   	push   %ecx
f0100f81:	51                   	push   %ecx
f0100f82:	ff 74 24 08          	pushl  0x8(%esp)
f0100f86:	68 40 27 10 f0       	push   $0xf0102740
f0100f8b:	e8 0e f8 ff ff       	call   f010079e <cprintf>
f0100f90:	83 c4 10             	add    $0x10,%esp
f0100f93:	e9 1f ff ff ff       	jmp    f0100eb7 <shell+0x22>
		{
			if (runcmd(buf) < 0)
				break;
		}
	}
}
f0100f98:	83 c4 4c             	add    $0x4c,%esp
f0100f9b:	5b                   	pop    %ebx
f0100f9c:	5e                   	pop    %esi
f0100f9d:	5f                   	pop    %edi
f0100f9e:	5d                   	pop    %ebp
f0100f9f:	c3                   	ret    

f0100fa0 <set_timer>:

static unsigned long jiffies = 0;

void set_timer(int hz)
{
    int divisor = 1193180 / hz;       /* Calculate our divisor */
f0100fa0:	b9 dc 34 12 00       	mov    $0x1234dc,%ecx
f0100fa5:	89 c8                	mov    %ecx,%eax
f0100fa7:	99                   	cltd   
f0100fa8:	f7 7c 24 04          	idivl  0x4(%esp)
f0100fac:	ba 43 00 00 00       	mov    $0x43,%edx
f0100fb1:	89 c1                	mov    %eax,%ecx
f0100fb3:	b0 36                	mov    $0x36,%al
f0100fb5:	ee                   	out    %al,(%dx)
f0100fb6:	b2 40                	mov    $0x40,%dl
f0100fb8:	88 c8                	mov    %cl,%al
f0100fba:	ee                   	out    %al,(%dx)
    outb(0x43, 0x36);             /* Set our command byte 0x36 */
    outb(0x40, divisor & 0xFF);   /* Set low byte of divisor */
    outb(0x40, divisor >> 8);     /* Set high byte of divisor */
f0100fbb:	89 c8                	mov    %ecx,%eax
f0100fbd:	c1 f8 08             	sar    $0x8,%eax
f0100fc0:	ee                   	out    %al,(%dx)
}
f0100fc1:	c3                   	ret    

f0100fc2 <timer_handler>:
/* 
 * Timer interrupt handler
 */
void timer_handler()
{
	jiffies++;
f0100fc2:	ff 05 28 e2 10 f0    	incl   0xf010e228
}
f0100fc8:	c3                   	ret    

f0100fc9 <get_tick>:

unsigned long get_tick()
{
	return jiffies;
}
f0100fc9:	a1 28 e2 10 f0       	mov    0xf010e228,%eax
f0100fce:	c3                   	ret    

f0100fcf <timer_init>:
void timer_init()
{
f0100fcf:	83 ec 0c             	sub    $0xc,%esp
	set_timer(TIME_HZ);
f0100fd2:	6a 64                	push   $0x64
f0100fd4:	e8 c7 ff ff ff       	call   f0100fa0 <set_timer>

	/* Enable interrupt */
	irq_setmask_8259A(irq_mask_8259A & ~(1<<IRQ_TIMER));
f0100fd9:	50                   	push   %eax
f0100fda:	50                   	push   %eax
f0100fdb:	0f b7 05 00 30 10 f0 	movzwl 0xf0103000,%eax
f0100fe2:	25 fe ff 00 00       	and    $0xfffe,%eax
f0100fe7:	50                   	push   %eax
f0100fe8:	e8 9b f0 ff ff       	call   f0100088 <irq_setmask_8259A>
}
f0100fed:	83 c4 1c             	add    $0x1c,%esp
f0100ff0:	c3                   	ret    
	...

f0101000 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
f0101000:	55                   	push   %ebp
f0101001:	57                   	push   %edi
f0101002:	56                   	push   %esi
f0101003:	53                   	push   %ebx
f0101004:	83 ec 3c             	sub    $0x3c,%esp
f0101007:	89 c5                	mov    %eax,%ebp
f0101009:	89 d6                	mov    %edx,%esi
f010100b:	8b 44 24 50          	mov    0x50(%esp),%eax
f010100f:	89 44 24 24          	mov    %eax,0x24(%esp)
f0101013:	8b 54 24 54          	mov    0x54(%esp),%edx
f0101017:	89 54 24 20          	mov    %edx,0x20(%esp)
f010101b:	8b 5c 24 5c          	mov    0x5c(%esp),%ebx
f010101f:	8b 7c 24 60          	mov    0x60(%esp),%edi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
f0101023:	b8 00 00 00 00       	mov    $0x0,%eax
f0101028:	39 d0                	cmp    %edx,%eax
f010102a:	72 13                	jb     f010103f <printnum+0x3f>
f010102c:	8b 4c 24 24          	mov    0x24(%esp),%ecx
f0101030:	39 4c 24 58          	cmp    %ecx,0x58(%esp)
f0101034:	76 09                	jbe    f010103f <printnum+0x3f>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
f0101036:	83 eb 01             	sub    $0x1,%ebx
f0101039:	85 db                	test   %ebx,%ebx
f010103b:	7f 63                	jg     f01010a0 <printnum+0xa0>
f010103d:	eb 71                	jmp    f01010b0 <printnum+0xb0>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
f010103f:	89 7c 24 10          	mov    %edi,0x10(%esp)
f0101043:	83 eb 01             	sub    $0x1,%ebx
f0101046:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f010104a:	8b 5c 24 58          	mov    0x58(%esp),%ebx
f010104e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f0101052:	8b 44 24 08          	mov    0x8(%esp),%eax
f0101056:	8b 54 24 0c          	mov    0xc(%esp),%edx
f010105a:	89 44 24 28          	mov    %eax,0x28(%esp)
f010105e:	89 54 24 2c          	mov    %edx,0x2c(%esp)
f0101062:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
f0101069:	00 
f010106a:	8b 54 24 24          	mov    0x24(%esp),%edx
f010106e:	89 14 24             	mov    %edx,(%esp)
f0101071:	8b 4c 24 20          	mov    0x20(%esp),%ecx
f0101075:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f0101079:	e8 d2 0a 00 00       	call   f0101b50 <__udivdi3>
f010107e:	8b 4c 24 28          	mov    0x28(%esp),%ecx
f0101082:	8b 5c 24 2c          	mov    0x2c(%esp),%ebx
f0101086:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f010108a:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f010108e:	89 04 24             	mov    %eax,(%esp)
f0101091:	89 54 24 04          	mov    %edx,0x4(%esp)
f0101095:	89 f2                	mov    %esi,%edx
f0101097:	89 e8                	mov    %ebp,%eax
f0101099:	e8 62 ff ff ff       	call   f0101000 <printnum>
f010109e:	eb 10                	jmp    f01010b0 <printnum+0xb0>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
f01010a0:	89 74 24 04          	mov    %esi,0x4(%esp)
f01010a4:	89 3c 24             	mov    %edi,(%esp)
f01010a7:	ff d5                	call   *%ebp
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
f01010a9:	83 eb 01             	sub    $0x1,%ebx
f01010ac:	85 db                	test   %ebx,%ebx
f01010ae:	7f f0                	jg     f01010a0 <printnum+0xa0>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f01010b0:	89 74 24 04          	mov    %esi,0x4(%esp)
f01010b4:	8b 74 24 04          	mov    0x4(%esp),%esi
f01010b8:	8b 44 24 58          	mov    0x58(%esp),%eax
f01010bc:	89 44 24 08          	mov    %eax,0x8(%esp)
f01010c0:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
f01010c7:	00 
f01010c8:	8b 54 24 24          	mov    0x24(%esp),%edx
f01010cc:	89 14 24             	mov    %edx,(%esp)
f01010cf:	8b 4c 24 20          	mov    0x20(%esp),%ecx
f01010d3:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f01010d7:	e8 84 0b 00 00       	call   f0101c60 <__umoddi3>
f01010dc:	89 74 24 04          	mov    %esi,0x4(%esp)
f01010e0:	0f be 80 88 27 10 f0 	movsbl -0xfefd878(%eax),%eax
f01010e7:	89 04 24             	mov    %eax,(%esp)
f01010ea:	ff d5                	call   *%ebp
}
f01010ec:	83 c4 3c             	add    $0x3c,%esp
f01010ef:	5b                   	pop    %ebx
f01010f0:	5e                   	pop    %esi
f01010f1:	5f                   	pop    %edi
f01010f2:	5d                   	pop    %ebp
f01010f3:	c3                   	ret    

f01010f4 <getuint>:
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
f01010f4:	83 fa 01             	cmp    $0x1,%edx
f01010f7:	7e 0d                	jle    f0101106 <getuint+0x12>
		return va_arg(*ap, unsigned long long);
f01010f9:	8b 10                	mov    (%eax),%edx
f01010fb:	8d 4a 08             	lea    0x8(%edx),%ecx
f01010fe:	89 08                	mov    %ecx,(%eax)
f0101100:	8b 02                	mov    (%edx),%eax
f0101102:	8b 52 04             	mov    0x4(%edx),%edx
f0101105:	c3                   	ret    
	else if (lflag)
f0101106:	85 d2                	test   %edx,%edx
f0101108:	74 0f                	je     f0101119 <getuint+0x25>
		return va_arg(*ap, unsigned long);
f010110a:	8b 10                	mov    (%eax),%edx
f010110c:	8d 4a 04             	lea    0x4(%edx),%ecx
f010110f:	89 08                	mov    %ecx,(%eax)
f0101111:	8b 02                	mov    (%edx),%eax
f0101113:	ba 00 00 00 00       	mov    $0x0,%edx
f0101118:	c3                   	ret    
	else
		return va_arg(*ap, unsigned int);
f0101119:	8b 10                	mov    (%eax),%edx
f010111b:	8d 4a 04             	lea    0x4(%edx),%ecx
f010111e:	89 08                	mov    %ecx,(%eax)
f0101120:	8b 02                	mov    (%edx),%eax
f0101122:	ba 00 00 00 00       	mov    $0x0,%edx
}
f0101127:	c3                   	ret    

f0101128 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f0101128:	8b 44 24 08          	mov    0x8(%esp),%eax
	b->cnt++;
f010112c:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
f0101130:	8b 10                	mov    (%eax),%edx
f0101132:	3b 50 04             	cmp    0x4(%eax),%edx
f0101135:	73 0b                	jae    f0101142 <sprintputch+0x1a>
		*b->buf++ = ch;
f0101137:	8b 4c 24 04          	mov    0x4(%esp),%ecx
f010113b:	88 0a                	mov    %cl,(%edx)
f010113d:	83 c2 01             	add    $0x1,%edx
f0101140:	89 10                	mov    %edx,(%eax)
f0101142:	f3 c3                	repz ret 

f0101144 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
f0101144:	83 ec 1c             	sub    $0x1c,%esp
	va_list ap;

	va_start(ap, fmt);
f0101147:	8d 44 24 2c          	lea    0x2c(%esp),%eax
	vprintfmt(putch, putdat, fmt, ap);
f010114b:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010114f:	8b 44 24 28          	mov    0x28(%esp),%eax
f0101153:	89 44 24 08          	mov    %eax,0x8(%esp)
f0101157:	8b 44 24 24          	mov    0x24(%esp),%eax
f010115b:	89 44 24 04          	mov    %eax,0x4(%esp)
f010115f:	8b 44 24 20          	mov    0x20(%esp),%eax
f0101163:	89 04 24             	mov    %eax,(%esp)
f0101166:	e8 04 00 00 00       	call   f010116f <vprintfmt>
	va_end(ap);
}
f010116b:	83 c4 1c             	add    $0x1c,%esp
f010116e:	c3                   	ret    

f010116f <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
f010116f:	55                   	push   %ebp
f0101170:	57                   	push   %edi
f0101171:	56                   	push   %esi
f0101172:	53                   	push   %ebx
f0101173:	83 ec 4c             	sub    $0x4c,%esp
f0101176:	8b 6c 24 60          	mov    0x60(%esp),%ebp
f010117a:	8b 7c 24 64          	mov    0x64(%esp),%edi
f010117e:	8b 5c 24 68          	mov    0x68(%esp),%ebx
f0101182:	eb 11                	jmp    f0101195 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
f0101184:	85 c0                	test   %eax,%eax
f0101186:	0f 84 40 04 00 00    	je     f01015cc <vprintfmt+0x45d>
				return;
			putch(ch, putdat);
f010118c:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0101190:	89 04 24             	mov    %eax,(%esp)
f0101193:	ff d5                	call   *%ebp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
f0101195:	0f b6 03             	movzbl (%ebx),%eax
f0101198:	83 c3 01             	add    $0x1,%ebx
f010119b:	83 f8 25             	cmp    $0x25,%eax
f010119e:	75 e4                	jne    f0101184 <vprintfmt+0x15>
f01011a0:	c6 44 24 28 20       	movb   $0x20,0x28(%esp)
f01011a5:	c7 44 24 2c 00 00 00 	movl   $0x0,0x2c(%esp)
f01011ac:	00 
f01011ad:	be ff ff ff ff       	mov    $0xffffffff,%esi
f01011b2:	c7 44 24 30 ff ff ff 	movl   $0xffffffff,0x30(%esp)
f01011b9:	ff 
f01011ba:	b9 00 00 00 00       	mov    $0x0,%ecx
f01011bf:	89 74 24 34          	mov    %esi,0x34(%esp)
f01011c3:	eb 34                	jmp    f01011f9 <vprintfmt+0x8a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01011c5:	8b 5c 24 24          	mov    0x24(%esp),%ebx

		// flag to pad on the right
		case '-':
			padc = '-';
f01011c9:	c6 44 24 28 2d       	movb   $0x2d,0x28(%esp)
f01011ce:	eb 29                	jmp    f01011f9 <vprintfmt+0x8a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01011d0:	8b 5c 24 24          	mov    0x24(%esp),%ebx
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
f01011d4:	c6 44 24 28 30       	movb   $0x30,0x28(%esp)
f01011d9:	eb 1e                	jmp    f01011f9 <vprintfmt+0x8a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01011db:	8b 5c 24 24          	mov    0x24(%esp),%ebx
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
f01011df:	c7 44 24 30 00 00 00 	movl   $0x0,0x30(%esp)
f01011e6:	00 
f01011e7:	eb 10                	jmp    f01011f9 <vprintfmt+0x8a>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
f01011e9:	8b 44 24 34          	mov    0x34(%esp),%eax
f01011ed:	89 44 24 30          	mov    %eax,0x30(%esp)
f01011f1:	c7 44 24 34 ff ff ff 	movl   $0xffffffff,0x34(%esp)
f01011f8:	ff 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01011f9:	0f b6 03             	movzbl (%ebx),%eax
f01011fc:	0f b6 d0             	movzbl %al,%edx
f01011ff:	8d 73 01             	lea    0x1(%ebx),%esi
f0101202:	89 74 24 24          	mov    %esi,0x24(%esp)
f0101206:	83 e8 23             	sub    $0x23,%eax
f0101209:	3c 55                	cmp    $0x55,%al
f010120b:	0f 87 9c 03 00 00    	ja     f01015ad <vprintfmt+0x43e>
f0101211:	0f b6 c0             	movzbl %al,%eax
f0101214:	ff 24 85 40 28 10 f0 	jmp    *-0xfefd7c0(,%eax,4)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
f010121b:	83 ea 30             	sub    $0x30,%edx
f010121e:	89 54 24 34          	mov    %edx,0x34(%esp)
				ch = *fmt;
f0101222:	8b 54 24 24          	mov    0x24(%esp),%edx
f0101226:	0f be 02             	movsbl (%edx),%eax
				if (ch < '0' || ch > '9')
f0101229:	8d 50 d0             	lea    -0x30(%eax),%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f010122c:	8b 5c 24 24          	mov    0x24(%esp),%ebx
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
f0101230:	83 fa 09             	cmp    $0x9,%edx
f0101233:	77 5b                	ja     f0101290 <vprintfmt+0x121>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0101235:	8b 74 24 34          	mov    0x34(%esp),%esi
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
f0101239:	83 c3 01             	add    $0x1,%ebx
				precision = precision * 10 + ch - '0';
f010123c:	8d 14 b6             	lea    (%esi,%esi,4),%edx
f010123f:	8d 74 50 d0          	lea    -0x30(%eax,%edx,2),%esi
				ch = *fmt;
f0101243:	0f be 03             	movsbl (%ebx),%eax
				if (ch < '0' || ch > '9')
f0101246:	8d 50 d0             	lea    -0x30(%eax),%edx
f0101249:	83 fa 09             	cmp    $0x9,%edx
f010124c:	76 eb                	jbe    f0101239 <vprintfmt+0xca>
f010124e:	89 74 24 34          	mov    %esi,0x34(%esp)
f0101252:	eb 3c                	jmp    f0101290 <vprintfmt+0x121>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
f0101254:	8b 44 24 6c          	mov    0x6c(%esp),%eax
f0101258:	8d 50 04             	lea    0x4(%eax),%edx
f010125b:	89 54 24 6c          	mov    %edx,0x6c(%esp)
f010125f:	8b 00                	mov    (%eax),%eax
f0101261:	89 44 24 34          	mov    %eax,0x34(%esp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0101265:	8b 5c 24 24          	mov    0x24(%esp),%ebx
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
f0101269:	eb 25                	jmp    f0101290 <vprintfmt+0x121>

		case '.':
			if (width < 0)
f010126b:	83 7c 24 30 00       	cmpl   $0x0,0x30(%esp)
f0101270:	0f 88 65 ff ff ff    	js     f01011db <vprintfmt+0x6c>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0101276:	8b 5c 24 24          	mov    0x24(%esp),%ebx
f010127a:	e9 7a ff ff ff       	jmp    f01011f9 <vprintfmt+0x8a>
f010127f:	8b 5c 24 24          	mov    0x24(%esp),%ebx
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
f0101283:	c7 44 24 2c 01 00 00 	movl   $0x1,0x2c(%esp)
f010128a:	00 
			goto reswitch;
f010128b:	e9 69 ff ff ff       	jmp    f01011f9 <vprintfmt+0x8a>

		process_precision:
			if (width < 0)
f0101290:	83 7c 24 30 00       	cmpl   $0x0,0x30(%esp)
f0101295:	0f 89 5e ff ff ff    	jns    f01011f9 <vprintfmt+0x8a>
f010129b:	e9 49 ff ff ff       	jmp    f01011e9 <vprintfmt+0x7a>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
f01012a0:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01012a3:	8b 5c 24 24          	mov    0x24(%esp),%ebx
f01012a7:	e9 4d ff ff ff       	jmp    f01011f9 <vprintfmt+0x8a>
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
f01012ac:	8b 44 24 6c          	mov    0x6c(%esp),%eax
f01012b0:	8d 50 04             	lea    0x4(%eax),%edx
f01012b3:	89 54 24 6c          	mov    %edx,0x6c(%esp)
f01012b7:	89 7c 24 04          	mov    %edi,0x4(%esp)
f01012bb:	8b 00                	mov    (%eax),%eax
f01012bd:	89 04 24             	mov    %eax,(%esp)
f01012c0:	ff d5                	call   *%ebp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01012c2:	8b 5c 24 24          	mov    0x24(%esp),%ebx
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
f01012c6:	e9 ca fe ff ff       	jmp    f0101195 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
f01012cb:	8b 44 24 6c          	mov    0x6c(%esp),%eax
f01012cf:	8d 50 04             	lea    0x4(%eax),%edx
f01012d2:	89 54 24 6c          	mov    %edx,0x6c(%esp)
f01012d6:	8b 00                	mov    (%eax),%eax
f01012d8:	89 c2                	mov    %eax,%edx
f01012da:	c1 fa 1f             	sar    $0x1f,%edx
f01012dd:	31 d0                	xor    %edx,%eax
f01012df:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f01012e1:	83 f8 08             	cmp    $0x8,%eax
f01012e4:	7f 0b                	jg     f01012f1 <vprintfmt+0x182>
f01012e6:	8b 14 85 a0 29 10 f0 	mov    -0xfefd660(,%eax,4),%edx
f01012ed:	85 d2                	test   %edx,%edx
f01012ef:	75 21                	jne    f0101312 <vprintfmt+0x1a3>
				printfmt(putch, putdat, "error %d", err);
f01012f1:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01012f5:	c7 44 24 08 a0 27 10 	movl   $0xf01027a0,0x8(%esp)
f01012fc:	f0 
f01012fd:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0101301:	89 2c 24             	mov    %ebp,(%esp)
f0101304:	e8 3b fe ff ff       	call   f0101144 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0101309:	8b 5c 24 24          	mov    0x24(%esp),%ebx
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
f010130d:	e9 83 fe ff ff       	jmp    f0101195 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
f0101312:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0101316:	c7 44 24 08 89 23 10 	movl   $0xf0102389,0x8(%esp)
f010131d:	f0 
f010131e:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0101322:	89 2c 24             	mov    %ebp,(%esp)
f0101325:	e8 1a fe ff ff       	call   f0101144 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f010132a:	8b 5c 24 24          	mov    0x24(%esp),%ebx
f010132e:	e9 62 fe ff ff       	jmp    f0101195 <vprintfmt+0x26>
f0101333:	8b 74 24 34          	mov    0x34(%esp),%esi
f0101337:	8b 5c 24 24          	mov    0x24(%esp),%ebx
f010133b:	8b 44 24 30          	mov    0x30(%esp),%eax
f010133f:	89 44 24 38          	mov    %eax,0x38(%esp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
f0101343:	8b 44 24 6c          	mov    0x6c(%esp),%eax
f0101347:	8d 50 04             	lea    0x4(%eax),%edx
f010134a:	89 54 24 6c          	mov    %edx,0x6c(%esp)
f010134e:	8b 00                	mov    (%eax),%eax
				p = "(null)";
f0101350:	85 c0                	test   %eax,%eax
f0101352:	ba 99 27 10 f0       	mov    $0xf0102799,%edx
f0101357:	0f 45 d0             	cmovne %eax,%edx
f010135a:	89 54 24 34          	mov    %edx,0x34(%esp)
			if (width > 0 && padc != '-')
f010135e:	83 7c 24 38 00       	cmpl   $0x0,0x38(%esp)
f0101363:	7e 07                	jle    f010136c <vprintfmt+0x1fd>
f0101365:	80 7c 24 28 2d       	cmpb   $0x2d,0x28(%esp)
f010136a:	75 14                	jne    f0101380 <vprintfmt+0x211>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f010136c:	8b 54 24 34          	mov    0x34(%esp),%edx
f0101370:	0f be 02             	movsbl (%edx),%eax
f0101373:	85 c0                	test   %eax,%eax
f0101375:	0f 85 ac 00 00 00    	jne    f0101427 <vprintfmt+0x2b8>
f010137b:	e9 97 00 00 00       	jmp    f0101417 <vprintfmt+0x2a8>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f0101380:	89 74 24 04          	mov    %esi,0x4(%esp)
f0101384:	8b 44 24 34          	mov    0x34(%esp),%eax
f0101388:	89 04 24             	mov    %eax,(%esp)
f010138b:	e8 99 03 00 00       	call   f0101729 <strnlen>
f0101390:	8b 54 24 38          	mov    0x38(%esp),%edx
f0101394:	29 c2                	sub    %eax,%edx
f0101396:	89 54 24 30          	mov    %edx,0x30(%esp)
f010139a:	85 d2                	test   %edx,%edx
f010139c:	7e ce                	jle    f010136c <vprintfmt+0x1fd>
					putch(padc, putdat);
f010139e:	0f be 44 24 28       	movsbl 0x28(%esp),%eax
f01013a3:	89 74 24 38          	mov    %esi,0x38(%esp)
f01013a7:	89 5c 24 3c          	mov    %ebx,0x3c(%esp)
f01013ab:	89 d3                	mov    %edx,%ebx
f01013ad:	89 c6                	mov    %eax,%esi
f01013af:	89 7c 24 04          	mov    %edi,0x4(%esp)
f01013b3:	89 34 24             	mov    %esi,(%esp)
f01013b6:	ff d5                	call   *%ebp
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f01013b8:	83 eb 01             	sub    $0x1,%ebx
f01013bb:	85 db                	test   %ebx,%ebx
f01013bd:	7f f0                	jg     f01013af <vprintfmt+0x240>
f01013bf:	8b 74 24 38          	mov    0x38(%esp),%esi
f01013c3:	8b 5c 24 3c          	mov    0x3c(%esp),%ebx
f01013c7:	c7 44 24 30 00 00 00 	movl   $0x0,0x30(%esp)
f01013ce:	00 
f01013cf:	eb 9b                	jmp    f010136c <vprintfmt+0x1fd>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
f01013d1:	83 7c 24 2c 00       	cmpl   $0x0,0x2c(%esp)
f01013d6:	74 19                	je     f01013f1 <vprintfmt+0x282>
f01013d8:	8d 50 e0             	lea    -0x20(%eax),%edx
f01013db:	83 fa 5e             	cmp    $0x5e,%edx
f01013de:	76 11                	jbe    f01013f1 <vprintfmt+0x282>
					putch('?', putdat);
f01013e0:	89 7c 24 04          	mov    %edi,0x4(%esp)
f01013e4:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
f01013eb:	ff 54 24 28          	call   *0x28(%esp)
f01013ef:	eb 0b                	jmp    f01013fc <vprintfmt+0x28d>
				else
					putch(ch, putdat);
f01013f1:	89 7c 24 04          	mov    %edi,0x4(%esp)
f01013f5:	89 04 24             	mov    %eax,(%esp)
f01013f8:	ff 54 24 28          	call   *0x28(%esp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f01013fc:	83 ed 01             	sub    $0x1,%ebp
f01013ff:	0f be 03             	movsbl (%ebx),%eax
f0101402:	85 c0                	test   %eax,%eax
f0101404:	74 05                	je     f010140b <vprintfmt+0x29c>
f0101406:	83 c3 01             	add    $0x1,%ebx
f0101409:	eb 31                	jmp    f010143c <vprintfmt+0x2cd>
f010140b:	89 6c 24 30          	mov    %ebp,0x30(%esp)
f010140f:	8b 6c 24 28          	mov    0x28(%esp),%ebp
f0101413:	8b 5c 24 38          	mov    0x38(%esp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
f0101417:	83 7c 24 30 00       	cmpl   $0x0,0x30(%esp)
f010141c:	7f 35                	jg     f0101453 <vprintfmt+0x2e4>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f010141e:	8b 5c 24 24          	mov    0x24(%esp),%ebx
f0101422:	e9 6e fd ff ff       	jmp    f0101195 <vprintfmt+0x26>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f0101427:	8b 54 24 34          	mov    0x34(%esp),%edx
f010142b:	83 c2 01             	add    $0x1,%edx
f010142e:	89 6c 24 28          	mov    %ebp,0x28(%esp)
f0101432:	8b 6c 24 30          	mov    0x30(%esp),%ebp
f0101436:	89 5c 24 38          	mov    %ebx,0x38(%esp)
f010143a:	89 d3                	mov    %edx,%ebx
f010143c:	85 f6                	test   %esi,%esi
f010143e:	78 91                	js     f01013d1 <vprintfmt+0x262>
f0101440:	83 ee 01             	sub    $0x1,%esi
f0101443:	79 8c                	jns    f01013d1 <vprintfmt+0x262>
f0101445:	89 6c 24 30          	mov    %ebp,0x30(%esp)
f0101449:	8b 6c 24 28          	mov    0x28(%esp),%ebp
f010144d:	8b 5c 24 38          	mov    0x38(%esp),%ebx
f0101451:	eb c4                	jmp    f0101417 <vprintfmt+0x2a8>
f0101453:	89 de                	mov    %ebx,%esi
f0101455:	8b 5c 24 30          	mov    0x30(%esp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
f0101459:	89 7c 24 04          	mov    %edi,0x4(%esp)
f010145d:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
f0101464:	ff d5                	call   *%ebp
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
f0101466:	83 eb 01             	sub    $0x1,%ebx
f0101469:	85 db                	test   %ebx,%ebx
f010146b:	7f ec                	jg     f0101459 <vprintfmt+0x2ea>
f010146d:	89 f3                	mov    %esi,%ebx
f010146f:	e9 21 fd ff ff       	jmp    f0101195 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
f0101474:	83 f9 01             	cmp    $0x1,%ecx
f0101477:	7e 12                	jle    f010148b <vprintfmt+0x31c>
		return va_arg(*ap, long long);
f0101479:	8b 44 24 6c          	mov    0x6c(%esp),%eax
f010147d:	8d 50 08             	lea    0x8(%eax),%edx
f0101480:	89 54 24 6c          	mov    %edx,0x6c(%esp)
f0101484:	8b 18                	mov    (%eax),%ebx
f0101486:	8b 70 04             	mov    0x4(%eax),%esi
f0101489:	eb 2a                	jmp    f01014b5 <vprintfmt+0x346>
	else if (lflag)
f010148b:	85 c9                	test   %ecx,%ecx
f010148d:	74 14                	je     f01014a3 <vprintfmt+0x334>
		return va_arg(*ap, long);
f010148f:	8b 44 24 6c          	mov    0x6c(%esp),%eax
f0101493:	8d 50 04             	lea    0x4(%eax),%edx
f0101496:	89 54 24 6c          	mov    %edx,0x6c(%esp)
f010149a:	8b 18                	mov    (%eax),%ebx
f010149c:	89 de                	mov    %ebx,%esi
f010149e:	c1 fe 1f             	sar    $0x1f,%esi
f01014a1:	eb 12                	jmp    f01014b5 <vprintfmt+0x346>
	else
		return va_arg(*ap, int);
f01014a3:	8b 44 24 6c          	mov    0x6c(%esp),%eax
f01014a7:	8d 50 04             	lea    0x4(%eax),%edx
f01014aa:	89 54 24 6c          	mov    %edx,0x6c(%esp)
f01014ae:	8b 18                	mov    (%eax),%ebx
f01014b0:	89 de                	mov    %ebx,%esi
f01014b2:	c1 fe 1f             	sar    $0x1f,%esi
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
f01014b5:	b8 0a 00 00 00       	mov    $0xa,%eax
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
f01014ba:	85 f6                	test   %esi,%esi
f01014bc:	0f 89 ab 00 00 00    	jns    f010156d <vprintfmt+0x3fe>
				putch('-', putdat);
f01014c2:	89 7c 24 04          	mov    %edi,0x4(%esp)
f01014c6:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
f01014cd:	ff d5                	call   *%ebp
				num = -(long long) num;
f01014cf:	f7 db                	neg    %ebx
f01014d1:	83 d6 00             	adc    $0x0,%esi
f01014d4:	f7 de                	neg    %esi
			}
			base = 10;
f01014d6:	b8 0a 00 00 00       	mov    $0xa,%eax
f01014db:	e9 8d 00 00 00       	jmp    f010156d <vprintfmt+0x3fe>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
f01014e0:	89 ca                	mov    %ecx,%edx
f01014e2:	8d 44 24 6c          	lea    0x6c(%esp),%eax
f01014e6:	e8 09 fc ff ff       	call   f01010f4 <getuint>
f01014eb:	89 c3                	mov    %eax,%ebx
f01014ed:	89 d6                	mov    %edx,%esi
			base = 10;
f01014ef:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
f01014f4:	eb 77                	jmp    f010156d <vprintfmt+0x3fe>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
f01014f6:	89 7c 24 04          	mov    %edi,0x4(%esp)
f01014fa:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
f0101501:	ff d5                	call   *%ebp
			putch('X', putdat);
f0101503:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0101507:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
f010150e:	ff d5                	call   *%ebp
			putch('X', putdat);
f0101510:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0101514:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
f010151b:	ff d5                	call   *%ebp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f010151d:	8b 5c 24 24          	mov    0x24(%esp),%ebx
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
			putch('X', putdat);
			putch('X', putdat);
			break;
f0101521:	e9 6f fc ff ff       	jmp    f0101195 <vprintfmt+0x26>

		// pointer
		case 'p':
			putch('0', putdat);
f0101526:	89 7c 24 04          	mov    %edi,0x4(%esp)
f010152a:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
f0101531:	ff d5                	call   *%ebp
			putch('x', putdat);
f0101533:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0101537:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
f010153e:	ff d5                	call   *%ebp
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
f0101540:	8b 44 24 6c          	mov    0x6c(%esp),%eax
f0101544:	8d 50 04             	lea    0x4(%eax),%edx
f0101547:	89 54 24 6c          	mov    %edx,0x6c(%esp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
f010154b:	8b 18                	mov    (%eax),%ebx
f010154d:	be 00 00 00 00       	mov    $0x0,%esi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
f0101552:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
f0101557:	eb 14                	jmp    f010156d <vprintfmt+0x3fe>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
f0101559:	89 ca                	mov    %ecx,%edx
f010155b:	8d 44 24 6c          	lea    0x6c(%esp),%eax
f010155f:	e8 90 fb ff ff       	call   f01010f4 <getuint>
f0101564:	89 c3                	mov    %eax,%ebx
f0101566:	89 d6                	mov    %edx,%esi
			base = 16;
f0101568:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
f010156d:	0f be 54 24 28       	movsbl 0x28(%esp),%edx
f0101572:	89 54 24 10          	mov    %edx,0x10(%esp)
f0101576:	8b 54 24 30          	mov    0x30(%esp),%edx
f010157a:	89 54 24 0c          	mov    %edx,0xc(%esp)
f010157e:	89 44 24 08          	mov    %eax,0x8(%esp)
f0101582:	89 1c 24             	mov    %ebx,(%esp)
f0101585:	89 74 24 04          	mov    %esi,0x4(%esp)
f0101589:	89 fa                	mov    %edi,%edx
f010158b:	89 e8                	mov    %ebp,%eax
f010158d:	e8 6e fa ff ff       	call   f0101000 <printnum>
			break;
f0101592:	8b 5c 24 24          	mov    0x24(%esp),%ebx
f0101596:	e9 fa fb ff ff       	jmp    f0101195 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
f010159b:	89 7c 24 04          	mov    %edi,0x4(%esp)
f010159f:	89 14 24             	mov    %edx,(%esp)
f01015a2:	ff d5                	call   *%ebp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01015a4:	8b 5c 24 24          	mov    0x24(%esp),%ebx
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
f01015a8:	e9 e8 fb ff ff       	jmp    f0101195 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
f01015ad:	89 7c 24 04          	mov    %edi,0x4(%esp)
f01015b1:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
f01015b8:	ff d5                	call   *%ebp
			for (fmt--; fmt[-1] != '%'; fmt--)
f01015ba:	eb 02                	jmp    f01015be <vprintfmt+0x44f>
f01015bc:	89 c3                	mov    %eax,%ebx
f01015be:	8d 43 ff             	lea    -0x1(%ebx),%eax
f01015c1:	80 7b ff 25          	cmpb   $0x25,-0x1(%ebx)
f01015c5:	75 f5                	jne    f01015bc <vprintfmt+0x44d>
f01015c7:	e9 c9 fb ff ff       	jmp    f0101195 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
f01015cc:	83 c4 4c             	add    $0x4c,%esp
f01015cf:	5b                   	pop    %ebx
f01015d0:	5e                   	pop    %esi
f01015d1:	5f                   	pop    %edi
f01015d2:	5d                   	pop    %ebp
f01015d3:	c3                   	ret    

f01015d4 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f01015d4:	83 ec 2c             	sub    $0x2c,%esp
f01015d7:	8b 44 24 30          	mov    0x30(%esp),%eax
f01015db:	8b 54 24 34          	mov    0x34(%esp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
f01015df:	89 44 24 14          	mov    %eax,0x14(%esp)
f01015e3:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
f01015e7:	89 4c 24 18          	mov    %ecx,0x18(%esp)
f01015eb:	c7 44 24 1c 00 00 00 	movl   $0x0,0x1c(%esp)
f01015f2:	00 

	if (buf == NULL || n < 1)
f01015f3:	85 c0                	test   %eax,%eax
f01015f5:	74 35                	je     f010162c <vsnprintf+0x58>
f01015f7:	85 d2                	test   %edx,%edx
f01015f9:	7e 31                	jle    f010162c <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
f01015fb:	8b 44 24 3c          	mov    0x3c(%esp),%eax
f01015ff:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0101603:	8b 44 24 38          	mov    0x38(%esp),%eax
f0101607:	89 44 24 08          	mov    %eax,0x8(%esp)
f010160b:	8d 44 24 14          	lea    0x14(%esp),%eax
f010160f:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101613:	c7 04 24 28 11 10 f0 	movl   $0xf0101128,(%esp)
f010161a:	e8 50 fb ff ff       	call   f010116f <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f010161f:	8b 44 24 14          	mov    0x14(%esp),%eax
f0101623:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f0101626:	8b 44 24 1c          	mov    0x1c(%esp),%eax
f010162a:	eb 05                	jmp    f0101631 <vsnprintf+0x5d>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
f010162c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
f0101631:	83 c4 2c             	add    $0x2c,%esp
f0101634:	c3                   	ret    

f0101635 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
f0101635:	83 ec 1c             	sub    $0x1c,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
f0101638:	8d 44 24 2c          	lea    0x2c(%esp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
f010163c:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0101640:	8b 44 24 28          	mov    0x28(%esp),%eax
f0101644:	89 44 24 08          	mov    %eax,0x8(%esp)
f0101648:	8b 44 24 24          	mov    0x24(%esp),%eax
f010164c:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101650:	8b 44 24 20          	mov    0x20(%esp),%eax
f0101654:	89 04 24             	mov    %eax,(%esp)
f0101657:	e8 78 ff ff ff       	call   f01015d4 <vsnprintf>
	va_end(ap);

	return rc;
}
f010165c:	83 c4 1c             	add    $0x1c,%esp
f010165f:	c3                   	ret    

f0101660 <readline>:

#define BUFLEN 1024
static char buf[BUFLEN];

char *readline(const char *prompt)
{
f0101660:	56                   	push   %esi
f0101661:	53                   	push   %ebx
f0101662:	83 ec 14             	sub    $0x14,%esp
f0101665:	8b 44 24 20          	mov    0x20(%esp),%eax
	int i, c, echoing;

	if (prompt != NULL)
f0101669:	85 c0                	test   %eax,%eax
f010166b:	74 10                	je     f010167d <readline+0x1d>
		cprintf("%s", prompt);
f010166d:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101671:	c7 04 24 89 23 10 f0 	movl   $0xf0102389,(%esp)
f0101678:	e8 21 f1 ff ff       	call   f010079e <cprintf>

#define BUFLEN 1024
static char buf[BUFLEN];

char *readline(const char *prompt)
{
f010167d:	be 00 00 00 00       	mov    $0x0,%esi
	if (prompt != NULL)
		cprintf("%s", prompt);

	i = 0;
	while (1) {
		c = getc();
f0101682:	e8 7c ec ff ff       	call   f0100303 <getc>
f0101687:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
f0101689:	85 c0                	test   %eax,%eax
f010168b:	79 17                	jns    f01016a4 <readline+0x44>
			cprintf("read error: %e\n", c);
f010168d:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101691:	c7 04 24 c4 29 10 f0 	movl   $0xf01029c4,(%esp)
f0101698:	e8 01 f1 ff ff       	call   f010079e <cprintf>
			return NULL;
f010169d:	b8 00 00 00 00       	mov    $0x0,%eax
f01016a2:	eb 64                	jmp    f0101708 <readline+0xa8>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f01016a4:	83 f8 08             	cmp    $0x8,%eax
f01016a7:	74 05                	je     f01016ae <readline+0x4e>
f01016a9:	83 f8 7f             	cmp    $0x7f,%eax
f01016ac:	75 15                	jne    f01016c3 <readline+0x63>
f01016ae:	85 f6                	test   %esi,%esi
f01016b0:	7e 11                	jle    f01016c3 <readline+0x63>
			putch('\b');
f01016b2:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
f01016b9:	e8 43 ed ff ff       	call   f0100401 <putch>
			i--;
f01016be:	83 ee 01             	sub    $0x1,%esi
f01016c1:	eb bf                	jmp    f0101682 <readline+0x22>
		} else if (c >= ' ' && i < BUFLEN-1) {
f01016c3:	83 fb 1f             	cmp    $0x1f,%ebx
f01016c6:	7e 1e                	jle    f01016e6 <readline+0x86>
f01016c8:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
f01016ce:	7f 16                	jg     f01016e6 <readline+0x86>
			putch(c);
f01016d0:	0f b6 c3             	movzbl %bl,%eax
f01016d3:	89 04 24             	mov    %eax,(%esp)
f01016d6:	e8 26 ed ff ff       	call   f0100401 <putch>
			buf[i++] = c;
f01016db:	88 9e 40 e2 10 f0    	mov    %bl,-0xfef1dc0(%esi)
f01016e1:	83 c6 01             	add    $0x1,%esi
f01016e4:	eb 9c                	jmp    f0101682 <readline+0x22>
		} else if (c == '\n' || c == '\r') {
f01016e6:	83 fb 0a             	cmp    $0xa,%ebx
f01016e9:	74 05                	je     f01016f0 <readline+0x90>
f01016eb:	83 fb 0d             	cmp    $0xd,%ebx
f01016ee:	75 92                	jne    f0101682 <readline+0x22>
			putch('\n');
f01016f0:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
f01016f7:	e8 05 ed ff ff       	call   f0100401 <putch>
			buf[i] = 0;
f01016fc:	c6 86 40 e2 10 f0 00 	movb   $0x0,-0xfef1dc0(%esi)
			return buf;
f0101703:	b8 40 e2 10 f0       	mov    $0xf010e240,%eax
		}
	}
}
f0101708:	83 c4 14             	add    $0x14,%esp
f010170b:	5b                   	pop    %ebx
f010170c:	5e                   	pop    %esi
f010170d:	c3                   	ret    
	...

f0101710 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
f0101710:	8b 54 24 04          	mov    0x4(%esp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
f0101714:	b8 00 00 00 00       	mov    $0x0,%eax
f0101719:	80 3a 00             	cmpb   $0x0,(%edx)
f010171c:	74 09                	je     f0101727 <strlen+0x17>
		n++;
f010171e:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
f0101721:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
f0101725:	75 f7                	jne    f010171e <strlen+0xe>
		n++;
	return n;
}
f0101727:	f3 c3                	repz ret 

f0101729 <strnlen>:

int
strnlen(const char *s, size_t size)
{
f0101729:	8b 4c 24 04          	mov    0x4(%esp),%ecx
f010172d:	8b 54 24 08          	mov    0x8(%esp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0101731:	b8 00 00 00 00       	mov    $0x0,%eax
f0101736:	85 d2                	test   %edx,%edx
f0101738:	74 12                	je     f010174c <strnlen+0x23>
f010173a:	80 39 00             	cmpb   $0x0,(%ecx)
f010173d:	74 0d                	je     f010174c <strnlen+0x23>
		n++;
f010173f:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0101742:	39 d0                	cmp    %edx,%eax
f0101744:	74 06                	je     f010174c <strnlen+0x23>
f0101746:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
f010174a:	75 f3                	jne    f010173f <strnlen+0x16>
		n++;
	return n;
}
f010174c:	f3 c3                	repz ret 

f010174e <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f010174e:	53                   	push   %ebx
f010174f:	8b 44 24 08          	mov    0x8(%esp),%eax
f0101753:	8b 5c 24 0c          	mov    0xc(%esp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
f0101757:	ba 00 00 00 00       	mov    $0x0,%edx
f010175c:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
f0101760:	88 0c 10             	mov    %cl,(%eax,%edx,1)
f0101763:	83 c2 01             	add    $0x1,%edx
f0101766:	84 c9                	test   %cl,%cl
f0101768:	75 f2                	jne    f010175c <strcpy+0xe>
		/* do nothing */;
	return ret;
}
f010176a:	5b                   	pop    %ebx
f010176b:	c3                   	ret    

f010176c <strcat>:

char *
strcat(char *dst, const char *src)
{
f010176c:	53                   	push   %ebx
f010176d:	83 ec 08             	sub    $0x8,%esp
f0101770:	8b 5c 24 10          	mov    0x10(%esp),%ebx
	int len = strlen(dst);
f0101774:	89 1c 24             	mov    %ebx,(%esp)
f0101777:	e8 94 ff ff ff       	call   f0101710 <strlen>
	strcpy(dst + len, src);
f010177c:	8b 54 24 14          	mov    0x14(%esp),%edx
f0101780:	89 54 24 04          	mov    %edx,0x4(%esp)
f0101784:	8d 04 03             	lea    (%ebx,%eax,1),%eax
f0101787:	89 04 24             	mov    %eax,(%esp)
f010178a:	e8 bf ff ff ff       	call   f010174e <strcpy>
	return dst;
}
f010178f:	89 d8                	mov    %ebx,%eax
f0101791:	83 c4 08             	add    $0x8,%esp
f0101794:	5b                   	pop    %ebx
f0101795:	c3                   	ret    

f0101796 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
f0101796:	56                   	push   %esi
f0101797:	53                   	push   %ebx
f0101798:	8b 44 24 0c          	mov    0xc(%esp),%eax
f010179c:	8b 54 24 10          	mov    0x10(%esp),%edx
f01017a0:	8b 74 24 14          	mov    0x14(%esp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f01017a4:	85 f6                	test   %esi,%esi
f01017a6:	74 18                	je     f01017c0 <strncpy+0x2a>
f01017a8:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
f01017ad:	0f b6 1a             	movzbl (%edx),%ebx
f01017b0:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
f01017b3:	80 3a 01             	cmpb   $0x1,(%edx)
f01017b6:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f01017b9:	83 c1 01             	add    $0x1,%ecx
f01017bc:	39 ce                	cmp    %ecx,%esi
f01017be:	77 ed                	ja     f01017ad <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
f01017c0:	5b                   	pop    %ebx
f01017c1:	5e                   	pop    %esi
f01017c2:	c3                   	ret    

f01017c3 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
f01017c3:	57                   	push   %edi
f01017c4:	56                   	push   %esi
f01017c5:	53                   	push   %ebx
f01017c6:	8b 7c 24 10          	mov    0x10(%esp),%edi
f01017ca:	8b 5c 24 14          	mov    0x14(%esp),%ebx
f01017ce:	8b 74 24 18          	mov    0x18(%esp),%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f01017d2:	89 f8                	mov    %edi,%eax
f01017d4:	85 f6                	test   %esi,%esi
f01017d6:	74 2c                	je     f0101804 <strlcpy+0x41>
		while (--size > 0 && *src != '\0')
f01017d8:	83 fe 01             	cmp    $0x1,%esi
f01017db:	74 24                	je     f0101801 <strlcpy+0x3e>
f01017dd:	0f b6 0b             	movzbl (%ebx),%ecx
f01017e0:	84 c9                	test   %cl,%cl
f01017e2:	74 1d                	je     f0101801 <strlcpy+0x3e>
f01017e4:	ba 00 00 00 00       	mov    $0x0,%edx
	}
	return ret;
}

size_t
strlcpy(char *dst, const char *src, size_t size)
f01017e9:	83 ee 02             	sub    $0x2,%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
f01017ec:	88 08                	mov    %cl,(%eax)
f01017ee:	83 c0 01             	add    $0x1,%eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
f01017f1:	39 f2                	cmp    %esi,%edx
f01017f3:	74 0c                	je     f0101801 <strlcpy+0x3e>
f01017f5:	0f b6 4c 13 01       	movzbl 0x1(%ebx,%edx,1),%ecx
f01017fa:	83 c2 01             	add    $0x1,%edx
f01017fd:	84 c9                	test   %cl,%cl
f01017ff:	75 eb                	jne    f01017ec <strlcpy+0x29>
			*dst++ = *src++;
		*dst = '\0';
f0101801:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
f0101804:	29 f8                	sub    %edi,%eax
}
f0101806:	5b                   	pop    %ebx
f0101807:	5e                   	pop    %esi
f0101808:	5f                   	pop    %edi
f0101809:	c3                   	ret    

f010180a <strcmp>:

int
strcmp(const char *p, const char *q)
{
f010180a:	8b 4c 24 04          	mov    0x4(%esp),%ecx
f010180e:	8b 54 24 08          	mov    0x8(%esp),%edx
	while (*p && *p == *q)
f0101812:	0f b6 01             	movzbl (%ecx),%eax
f0101815:	84 c0                	test   %al,%al
f0101817:	74 15                	je     f010182e <strcmp+0x24>
f0101819:	3a 02                	cmp    (%edx),%al
f010181b:	75 11                	jne    f010182e <strcmp+0x24>
		p++, q++;
f010181d:	83 c1 01             	add    $0x1,%ecx
f0101820:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
f0101823:	0f b6 01             	movzbl (%ecx),%eax
f0101826:	84 c0                	test   %al,%al
f0101828:	74 04                	je     f010182e <strcmp+0x24>
f010182a:	3a 02                	cmp    (%edx),%al
f010182c:	74 ef                	je     f010181d <strcmp+0x13>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
f010182e:	0f b6 c0             	movzbl %al,%eax
f0101831:	0f b6 12             	movzbl (%edx),%edx
f0101834:	29 d0                	sub    %edx,%eax
}
f0101836:	c3                   	ret    

f0101837 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
f0101837:	53                   	push   %ebx
f0101838:	8b 4c 24 08          	mov    0x8(%esp),%ecx
f010183c:	8b 5c 24 0c          	mov    0xc(%esp),%ebx
f0101840:	8b 54 24 10          	mov    0x10(%esp),%edx
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
f0101844:	b8 00 00 00 00       	mov    $0x0,%eax
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
f0101849:	85 d2                	test   %edx,%edx
f010184b:	74 28                	je     f0101875 <strncmp+0x3e>
f010184d:	0f b6 01             	movzbl (%ecx),%eax
f0101850:	84 c0                	test   %al,%al
f0101852:	74 23                	je     f0101877 <strncmp+0x40>
f0101854:	3a 03                	cmp    (%ebx),%al
f0101856:	75 1f                	jne    f0101877 <strncmp+0x40>
f0101858:	83 ea 01             	sub    $0x1,%edx
f010185b:	74 13                	je     f0101870 <strncmp+0x39>
		n--, p++, q++;
f010185d:	83 c1 01             	add    $0x1,%ecx
f0101860:	83 c3 01             	add    $0x1,%ebx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
f0101863:	0f b6 01             	movzbl (%ecx),%eax
f0101866:	84 c0                	test   %al,%al
f0101868:	74 0d                	je     f0101877 <strncmp+0x40>
f010186a:	3a 03                	cmp    (%ebx),%al
f010186c:	74 ea                	je     f0101858 <strncmp+0x21>
f010186e:	eb 07                	jmp    f0101877 <strncmp+0x40>
		n--, p++, q++;
	if (n == 0)
		return 0;
f0101870:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
f0101875:	5b                   	pop    %ebx
f0101876:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f0101877:	0f b6 01             	movzbl (%ecx),%eax
f010187a:	0f b6 13             	movzbl (%ebx),%edx
f010187d:	29 d0                	sub    %edx,%eax
f010187f:	eb f4                	jmp    f0101875 <strncmp+0x3e>

f0101881 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f0101881:	8b 44 24 04          	mov    0x4(%esp),%eax
f0101885:	0f b6 4c 24 08       	movzbl 0x8(%esp),%ecx
	for (; *s; s++)
f010188a:	0f b6 10             	movzbl (%eax),%edx
f010188d:	84 d2                	test   %dl,%dl
f010188f:	74 21                	je     f01018b2 <strchr+0x31>
		if (*s == c)
f0101891:	38 ca                	cmp    %cl,%dl
f0101893:	75 0d                	jne    f01018a2 <strchr+0x21>
f0101895:	f3 c3                	repz ret 
f0101897:	38 ca                	cmp    %cl,%dl
f0101899:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f01018a0:	74 15                	je     f01018b7 <strchr+0x36>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
f01018a2:	83 c0 01             	add    $0x1,%eax
f01018a5:	0f b6 10             	movzbl (%eax),%edx
f01018a8:	84 d2                	test   %dl,%dl
f01018aa:	75 eb                	jne    f0101897 <strchr+0x16>
		if (*s == c)
			return (char *) s;
	return 0;
f01018ac:	b8 00 00 00 00       	mov    $0x0,%eax
f01018b1:	c3                   	ret    
f01018b2:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01018b7:	f3 c3                	repz ret 

f01018b9 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f01018b9:	8b 44 24 04          	mov    0x4(%esp),%eax
f01018bd:	0f b6 4c 24 08       	movzbl 0x8(%esp),%ecx
	for (; *s; s++)
f01018c2:	0f b6 10             	movzbl (%eax),%edx
f01018c5:	84 d2                	test   %dl,%dl
f01018c7:	74 14                	je     f01018dd <strfind+0x24>
		if (*s == c)
f01018c9:	38 ca                	cmp    %cl,%dl
f01018cb:	75 06                	jne    f01018d3 <strfind+0x1a>
f01018cd:	f3 c3                	repz ret 
f01018cf:	38 ca                	cmp    %cl,%dl
f01018d1:	74 0a                	je     f01018dd <strfind+0x24>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
f01018d3:	83 c0 01             	add    $0x1,%eax
f01018d6:	0f b6 10             	movzbl (%eax),%edx
f01018d9:	84 d2                	test   %dl,%dl
f01018db:	75 f2                	jne    f01018cf <strfind+0x16>
		if (*s == c)
			break;
	return (char *) s;
}
f01018dd:	f3 c3                	repz ret 

f01018df <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
f01018df:	83 ec 0c             	sub    $0xc,%esp
f01018e2:	89 1c 24             	mov    %ebx,(%esp)
f01018e5:	89 74 24 04          	mov    %esi,0x4(%esp)
f01018e9:	89 7c 24 08          	mov    %edi,0x8(%esp)
f01018ed:	8b 7c 24 10          	mov    0x10(%esp),%edi
f01018f1:	8b 44 24 14          	mov    0x14(%esp),%eax
f01018f5:	8b 4c 24 18          	mov    0x18(%esp),%ecx
	char *p;

	if (n == 0)
f01018f9:	85 c9                	test   %ecx,%ecx
f01018fb:	74 30                	je     f010192d <memset+0x4e>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
f01018fd:	f7 c7 03 00 00 00    	test   $0x3,%edi
f0101903:	75 25                	jne    f010192a <memset+0x4b>
f0101905:	f6 c1 03             	test   $0x3,%cl
f0101908:	75 20                	jne    f010192a <memset+0x4b>
		c &= 0xFF;
f010190a:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
f010190d:	89 d3                	mov    %edx,%ebx
f010190f:	c1 e3 08             	shl    $0x8,%ebx
f0101912:	89 d6                	mov    %edx,%esi
f0101914:	c1 e6 18             	shl    $0x18,%esi
f0101917:	89 d0                	mov    %edx,%eax
f0101919:	c1 e0 10             	shl    $0x10,%eax
f010191c:	09 f0                	or     %esi,%eax
f010191e:	09 d0                	or     %edx,%eax
f0101920:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
f0101922:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
f0101925:	fc                   	cld    
f0101926:	f3 ab                	rep stos %eax,%es:(%edi)
f0101928:	eb 03                	jmp    f010192d <memset+0x4e>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
f010192a:	fc                   	cld    
f010192b:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
f010192d:	89 f8                	mov    %edi,%eax
f010192f:	8b 1c 24             	mov    (%esp),%ebx
f0101932:	8b 74 24 04          	mov    0x4(%esp),%esi
f0101936:	8b 7c 24 08          	mov    0x8(%esp),%edi
f010193a:	83 c4 0c             	add    $0xc,%esp
f010193d:	c3                   	ret    

f010193e <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
f010193e:	83 ec 08             	sub    $0x8,%esp
f0101941:	89 34 24             	mov    %esi,(%esp)
f0101944:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0101948:	8b 44 24 0c          	mov    0xc(%esp),%eax
f010194c:	8b 74 24 10          	mov    0x10(%esp),%esi
f0101950:	8b 4c 24 14          	mov    0x14(%esp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
f0101954:	39 c6                	cmp    %eax,%esi
f0101956:	73 36                	jae    f010198e <memmove+0x50>
f0101958:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
f010195b:	39 d0                	cmp    %edx,%eax
f010195d:	73 2f                	jae    f010198e <memmove+0x50>
		s += n;
		d += n;
f010195f:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0101962:	f6 c2 03             	test   $0x3,%dl
f0101965:	75 1b                	jne    f0101982 <memmove+0x44>
f0101967:	f7 c7 03 00 00 00    	test   $0x3,%edi
f010196d:	75 13                	jne    f0101982 <memmove+0x44>
f010196f:	f6 c1 03             	test   $0x3,%cl
f0101972:	75 0e                	jne    f0101982 <memmove+0x44>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
f0101974:	83 ef 04             	sub    $0x4,%edi
f0101977:	8d 72 fc             	lea    -0x4(%edx),%esi
f010197a:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
f010197d:	fd                   	std    
f010197e:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0101980:	eb 09                	jmp    f010198b <memmove+0x4d>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
f0101982:	83 ef 01             	sub    $0x1,%edi
f0101985:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
f0101988:	fd                   	std    
f0101989:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
f010198b:	fc                   	cld    
f010198c:	eb 20                	jmp    f01019ae <memmove+0x70>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f010198e:	f7 c6 03 00 00 00    	test   $0x3,%esi
f0101994:	75 13                	jne    f01019a9 <memmove+0x6b>
f0101996:	a8 03                	test   $0x3,%al
f0101998:	75 0f                	jne    f01019a9 <memmove+0x6b>
f010199a:	f6 c1 03             	test   $0x3,%cl
f010199d:	75 0a                	jne    f01019a9 <memmove+0x6b>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
f010199f:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
f01019a2:	89 c7                	mov    %eax,%edi
f01019a4:	fc                   	cld    
f01019a5:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f01019a7:	eb 05                	jmp    f01019ae <memmove+0x70>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
f01019a9:	89 c7                	mov    %eax,%edi
f01019ab:	fc                   	cld    
f01019ac:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
f01019ae:	8b 34 24             	mov    (%esp),%esi
f01019b1:	8b 7c 24 04          	mov    0x4(%esp),%edi
f01019b5:	83 c4 08             	add    $0x8,%esp
f01019b8:	c3                   	ret    

f01019b9 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
f01019b9:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
f01019bc:	8b 44 24 18          	mov    0x18(%esp),%eax
f01019c0:	89 44 24 08          	mov    %eax,0x8(%esp)
f01019c4:	8b 44 24 14          	mov    0x14(%esp),%eax
f01019c8:	89 44 24 04          	mov    %eax,0x4(%esp)
f01019cc:	8b 44 24 10          	mov    0x10(%esp),%eax
f01019d0:	89 04 24             	mov    %eax,(%esp)
f01019d3:	e8 66 ff ff ff       	call   f010193e <memmove>
}
f01019d8:	83 c4 0c             	add    $0xc,%esp
f01019db:	c3                   	ret    

f01019dc <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
f01019dc:	57                   	push   %edi
f01019dd:	56                   	push   %esi
f01019de:	53                   	push   %ebx
f01019df:	8b 5c 24 10          	mov    0x10(%esp),%ebx
f01019e3:	8b 74 24 14          	mov    0x14(%esp),%esi
f01019e7:	8b 7c 24 18          	mov    0x18(%esp),%edi
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
f01019eb:	b8 00 00 00 00       	mov    $0x0,%eax
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f01019f0:	85 ff                	test   %edi,%edi
f01019f2:	74 38                	je     f0101a2c <memcmp+0x50>
		if (*s1 != *s2)
f01019f4:	0f b6 03             	movzbl (%ebx),%eax
f01019f7:	0f b6 0e             	movzbl (%esi),%ecx
f01019fa:	38 c8                	cmp    %cl,%al
f01019fc:	74 1d                	je     f0101a1b <memcmp+0x3f>
f01019fe:	eb 11                	jmp    f0101a11 <memcmp+0x35>
f0101a00:	0f b6 44 13 01       	movzbl 0x1(%ebx,%edx,1),%eax
f0101a05:	0f b6 4c 16 01       	movzbl 0x1(%esi,%edx,1),%ecx
f0101a0a:	83 c2 01             	add    $0x1,%edx
f0101a0d:	38 c8                	cmp    %cl,%al
f0101a0f:	74 12                	je     f0101a23 <memcmp+0x47>
			return (int) *s1 - (int) *s2;
f0101a11:	0f b6 c0             	movzbl %al,%eax
f0101a14:	0f b6 c9             	movzbl %cl,%ecx
f0101a17:	29 c8                	sub    %ecx,%eax
f0101a19:	eb 11                	jmp    f0101a2c <memcmp+0x50>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f0101a1b:	83 ef 01             	sub    $0x1,%edi
f0101a1e:	ba 00 00 00 00       	mov    $0x0,%edx
f0101a23:	39 fa                	cmp    %edi,%edx
f0101a25:	75 d9                	jne    f0101a00 <memcmp+0x24>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
f0101a27:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0101a2c:	5b                   	pop    %ebx
f0101a2d:	5e                   	pop    %esi
f0101a2e:	5f                   	pop    %edi
f0101a2f:	c3                   	ret    

f0101a30 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
f0101a30:	8b 44 24 04          	mov    0x4(%esp),%eax
	const void *ends = (const char *) s + n;
f0101a34:	89 c2                	mov    %eax,%edx
f0101a36:	03 54 24 0c          	add    0xc(%esp),%edx
	for (; s < ends; s++)
f0101a3a:	39 d0                	cmp    %edx,%eax
f0101a3c:	73 16                	jae    f0101a54 <memfind+0x24>
		if (*(const unsigned char *) s == (unsigned char) c)
f0101a3e:	0f b6 4c 24 08       	movzbl 0x8(%esp),%ecx
f0101a43:	38 08                	cmp    %cl,(%eax)
f0101a45:	75 06                	jne    f0101a4d <memfind+0x1d>
f0101a47:	f3 c3                	repz ret 
f0101a49:	38 08                	cmp    %cl,(%eax)
f0101a4b:	74 07                	je     f0101a54 <memfind+0x24>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
f0101a4d:	83 c0 01             	add    $0x1,%eax
f0101a50:	39 c2                	cmp    %eax,%edx
f0101a52:	77 f5                	ja     f0101a49 <memfind+0x19>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
f0101a54:	f3 c3                	repz ret 

f0101a56 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f0101a56:	55                   	push   %ebp
f0101a57:	57                   	push   %edi
f0101a58:	56                   	push   %esi
f0101a59:	53                   	push   %ebx
f0101a5a:	8b 54 24 14          	mov    0x14(%esp),%edx
f0101a5e:	8b 74 24 18          	mov    0x18(%esp),%esi
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f0101a62:	0f b6 02             	movzbl (%edx),%eax
f0101a65:	3c 20                	cmp    $0x20,%al
f0101a67:	74 04                	je     f0101a6d <strtol+0x17>
f0101a69:	3c 09                	cmp    $0x9,%al
f0101a6b:	75 0e                	jne    f0101a7b <strtol+0x25>
		s++;
f0101a6d:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f0101a70:	0f b6 02             	movzbl (%edx),%eax
f0101a73:	3c 20                	cmp    $0x20,%al
f0101a75:	74 f6                	je     f0101a6d <strtol+0x17>
f0101a77:	3c 09                	cmp    $0x9,%al
f0101a79:	74 f2                	je     f0101a6d <strtol+0x17>
		s++;

	// plus/minus sign
	if (*s == '+')
f0101a7b:	3c 2b                	cmp    $0x2b,%al
f0101a7d:	75 0a                	jne    f0101a89 <strtol+0x33>
		s++;
f0101a7f:	83 c2 01             	add    $0x1,%edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
f0101a82:	bf 00 00 00 00       	mov    $0x0,%edi
f0101a87:	eb 10                	jmp    f0101a99 <strtol+0x43>
f0101a89:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
f0101a8e:	3c 2d                	cmp    $0x2d,%al
f0101a90:	75 07                	jne    f0101a99 <strtol+0x43>
		s++, neg = 1;
f0101a92:	83 c2 01             	add    $0x1,%edx
f0101a95:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f0101a99:	83 7c 24 1c 00       	cmpl   $0x0,0x1c(%esp)
f0101a9e:	0f 94 c0             	sete   %al
f0101aa1:	74 07                	je     f0101aaa <strtol+0x54>
f0101aa3:	83 7c 24 1c 10       	cmpl   $0x10,0x1c(%esp)
f0101aa8:	75 18                	jne    f0101ac2 <strtol+0x6c>
f0101aaa:	80 3a 30             	cmpb   $0x30,(%edx)
f0101aad:	75 13                	jne    f0101ac2 <strtol+0x6c>
f0101aaf:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
f0101ab3:	75 0d                	jne    f0101ac2 <strtol+0x6c>
		s += 2, base = 16;
f0101ab5:	83 c2 02             	add    $0x2,%edx
f0101ab8:	c7 44 24 1c 10 00 00 	movl   $0x10,0x1c(%esp)
f0101abf:	00 
f0101ac0:	eb 1c                	jmp    f0101ade <strtol+0x88>
	else if (base == 0 && s[0] == '0')
f0101ac2:	84 c0                	test   %al,%al
f0101ac4:	74 18                	je     f0101ade <strtol+0x88>
		s++, base = 8;
	else if (base == 0)
		base = 10;
f0101ac6:	c7 44 24 1c 0a 00 00 	movl   $0xa,0x1c(%esp)
f0101acd:	00 
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f0101ace:	80 3a 30             	cmpb   $0x30,(%edx)
f0101ad1:	75 0b                	jne    f0101ade <strtol+0x88>
		s++, base = 8;
f0101ad3:	83 c2 01             	add    $0x1,%edx
f0101ad6:	c7 44 24 1c 08 00 00 	movl   $0x8,0x1c(%esp)
f0101add:	00 
	else if (base == 0)
		base = 10;
f0101ade:	b8 00 00 00 00       	mov    $0x0,%eax

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
f0101ae3:	0f b6 0a             	movzbl (%edx),%ecx
f0101ae6:	8d 69 d0             	lea    -0x30(%ecx),%ebp
f0101ae9:	89 eb                	mov    %ebp,%ebx
f0101aeb:	80 fb 09             	cmp    $0x9,%bl
f0101aee:	77 08                	ja     f0101af8 <strtol+0xa2>
			dig = *s - '0';
f0101af0:	0f be c9             	movsbl %cl,%ecx
f0101af3:	83 e9 30             	sub    $0x30,%ecx
f0101af6:	eb 22                	jmp    f0101b1a <strtol+0xc4>
		else if (*s >= 'a' && *s <= 'z')
f0101af8:	8d 69 9f             	lea    -0x61(%ecx),%ebp
f0101afb:	89 eb                	mov    %ebp,%ebx
f0101afd:	80 fb 19             	cmp    $0x19,%bl
f0101b00:	77 08                	ja     f0101b0a <strtol+0xb4>
			dig = *s - 'a' + 10;
f0101b02:	0f be c9             	movsbl %cl,%ecx
f0101b05:	83 e9 57             	sub    $0x57,%ecx
f0101b08:	eb 10                	jmp    f0101b1a <strtol+0xc4>
		else if (*s >= 'A' && *s <= 'Z')
f0101b0a:	8d 69 bf             	lea    -0x41(%ecx),%ebp
f0101b0d:	89 eb                	mov    %ebp,%ebx
f0101b0f:	80 fb 19             	cmp    $0x19,%bl
f0101b12:	77 19                	ja     f0101b2d <strtol+0xd7>
			dig = *s - 'A' + 10;
f0101b14:	0f be c9             	movsbl %cl,%ecx
f0101b17:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
f0101b1a:	3b 4c 24 1c          	cmp    0x1c(%esp),%ecx
f0101b1e:	7d 11                	jge    f0101b31 <strtol+0xdb>
			break;
		s++, val = (val * base) + dig;
f0101b20:	83 c2 01             	add    $0x1,%edx
f0101b23:	0f af 44 24 1c       	imul   0x1c(%esp),%eax
f0101b28:	8d 04 01             	lea    (%ecx,%eax,1),%eax
		// we don't properly detect overflow!
	}
f0101b2b:	eb b6                	jmp    f0101ae3 <strtol+0x8d>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
f0101b2d:	89 c1                	mov    %eax,%ecx
f0101b2f:	eb 02                	jmp    f0101b33 <strtol+0xdd>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
f0101b31:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
f0101b33:	85 f6                	test   %esi,%esi
f0101b35:	74 02                	je     f0101b39 <strtol+0xe3>
		*endptr = (char *) s;
f0101b37:	89 16                	mov    %edx,(%esi)
	return (neg ? -val : val);
f0101b39:	89 ca                	mov    %ecx,%edx
f0101b3b:	f7 da                	neg    %edx
f0101b3d:	85 ff                	test   %edi,%edi
f0101b3f:	0f 45 c2             	cmovne %edx,%eax
}
f0101b42:	5b                   	pop    %ebx
f0101b43:	5e                   	pop    %esi
f0101b44:	5f                   	pop    %edi
f0101b45:	5d                   	pop    %ebp
f0101b46:	c3                   	ret    
	...

f0101b50 <__udivdi3>:
f0101b50:	55                   	push   %ebp
f0101b51:	89 e5                	mov    %esp,%ebp
f0101b53:	57                   	push   %edi
f0101b54:	56                   	push   %esi
f0101b55:	8d 64 24 e0          	lea    -0x20(%esp),%esp
f0101b59:	8b 45 14             	mov    0x14(%ebp),%eax
f0101b5c:	8b 75 08             	mov    0x8(%ebp),%esi
f0101b5f:	8b 4d 10             	mov    0x10(%ebp),%ecx
f0101b62:	85 c0                	test   %eax,%eax
f0101b64:	89 75 e8             	mov    %esi,-0x18(%ebp)
f0101b67:	8b 7d 0c             	mov    0xc(%ebp),%edi
f0101b6a:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f0101b6d:	75 39                	jne    f0101ba8 <__udivdi3+0x58>
f0101b6f:	39 f9                	cmp    %edi,%ecx
f0101b71:	77 65                	ja     f0101bd8 <__udivdi3+0x88>
f0101b73:	85 c9                	test   %ecx,%ecx
f0101b75:	75 0b                	jne    f0101b82 <__udivdi3+0x32>
f0101b77:	b8 01 00 00 00       	mov    $0x1,%eax
f0101b7c:	31 d2                	xor    %edx,%edx
f0101b7e:	f7 f1                	div    %ecx
f0101b80:	89 c1                	mov    %eax,%ecx
f0101b82:	89 f8                	mov    %edi,%eax
f0101b84:	31 d2                	xor    %edx,%edx
f0101b86:	f7 f1                	div    %ecx
f0101b88:	89 c7                	mov    %eax,%edi
f0101b8a:	89 f0                	mov    %esi,%eax
f0101b8c:	f7 f1                	div    %ecx
f0101b8e:	89 fa                	mov    %edi,%edx
f0101b90:	89 c6                	mov    %eax,%esi
f0101b92:	89 75 f0             	mov    %esi,-0x10(%ebp)
f0101b95:	89 55 f4             	mov    %edx,-0xc(%ebp)
f0101b98:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0101b9b:	8b 55 f4             	mov    -0xc(%ebp),%edx
f0101b9e:	8d 64 24 20          	lea    0x20(%esp),%esp
f0101ba2:	5e                   	pop    %esi
f0101ba3:	5f                   	pop    %edi
f0101ba4:	5d                   	pop    %ebp
f0101ba5:	c3                   	ret    
f0101ba6:	66 90                	xchg   %ax,%ax
f0101ba8:	31 d2                	xor    %edx,%edx
f0101baa:	31 f6                	xor    %esi,%esi
f0101bac:	39 f8                	cmp    %edi,%eax
f0101bae:	77 e2                	ja     f0101b92 <__udivdi3+0x42>
f0101bb0:	0f bd d0             	bsr    %eax,%edx
f0101bb3:	83 f2 1f             	xor    $0x1f,%edx
f0101bb6:	89 55 ec             	mov    %edx,-0x14(%ebp)
f0101bb9:	75 2d                	jne    f0101be8 <__udivdi3+0x98>
f0101bbb:	8b 4d e8             	mov    -0x18(%ebp),%ecx
f0101bbe:	39 4d f0             	cmp    %ecx,-0x10(%ebp)
f0101bc1:	76 06                	jbe    f0101bc9 <__udivdi3+0x79>
f0101bc3:	39 f8                	cmp    %edi,%eax
f0101bc5:	89 f2                	mov    %esi,%edx
f0101bc7:	73 c9                	jae    f0101b92 <__udivdi3+0x42>
f0101bc9:	31 d2                	xor    %edx,%edx
f0101bcb:	be 01 00 00 00       	mov    $0x1,%esi
f0101bd0:	eb c0                	jmp    f0101b92 <__udivdi3+0x42>
f0101bd2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0101bd8:	89 f0                	mov    %esi,%eax
f0101bda:	89 fa                	mov    %edi,%edx
f0101bdc:	f7 f1                	div    %ecx
f0101bde:	31 d2                	xor    %edx,%edx
f0101be0:	89 c6                	mov    %eax,%esi
f0101be2:	eb ae                	jmp    f0101b92 <__udivdi3+0x42>
f0101be4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0101be8:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
f0101bec:	89 c2                	mov    %eax,%edx
f0101bee:	b8 20 00 00 00       	mov    $0x20,%eax
f0101bf3:	2b 45 ec             	sub    -0x14(%ebp),%eax
f0101bf6:	d3 e2                	shl    %cl,%edx
f0101bf8:	89 c1                	mov    %eax,%ecx
f0101bfa:	8b 75 f0             	mov    -0x10(%ebp),%esi
f0101bfd:	d3 ee                	shr    %cl,%esi
f0101bff:	09 d6                	or     %edx,%esi
f0101c01:	89 fa                	mov    %edi,%edx
f0101c03:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
f0101c07:	89 75 e4             	mov    %esi,-0x1c(%ebp)
f0101c0a:	8b 75 f0             	mov    -0x10(%ebp),%esi
f0101c0d:	d3 e6                	shl    %cl,%esi
f0101c0f:	89 c1                	mov    %eax,%ecx
f0101c11:	89 75 f0             	mov    %esi,-0x10(%ebp)
f0101c14:	8b 75 e8             	mov    -0x18(%ebp),%esi
f0101c17:	d3 ea                	shr    %cl,%edx
f0101c19:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
f0101c1d:	d3 e7                	shl    %cl,%edi
f0101c1f:	89 c1                	mov    %eax,%ecx
f0101c21:	d3 ee                	shr    %cl,%esi
f0101c23:	09 fe                	or     %edi,%esi
f0101c25:	89 f0                	mov    %esi,%eax
f0101c27:	f7 75 e4             	divl   -0x1c(%ebp)
f0101c2a:	89 d7                	mov    %edx,%edi
f0101c2c:	89 c6                	mov    %eax,%esi
f0101c2e:	f7 65 f0             	mull   -0x10(%ebp)
f0101c31:	39 d7                	cmp    %edx,%edi
f0101c33:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f0101c36:	72 12                	jb     f0101c4a <__udivdi3+0xfa>
f0101c38:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
f0101c3c:	8b 55 e8             	mov    -0x18(%ebp),%edx
f0101c3f:	d3 e2                	shl    %cl,%edx
f0101c41:	39 c2                	cmp    %eax,%edx
f0101c43:	73 08                	jae    f0101c4d <__udivdi3+0xfd>
f0101c45:	3b 7d e4             	cmp    -0x1c(%ebp),%edi
f0101c48:	75 03                	jne    f0101c4d <__udivdi3+0xfd>
f0101c4a:	8d 76 ff             	lea    -0x1(%esi),%esi
f0101c4d:	31 d2                	xor    %edx,%edx
f0101c4f:	e9 3e ff ff ff       	jmp    f0101b92 <__udivdi3+0x42>
	...

f0101c60 <__umoddi3>:
f0101c60:	55                   	push   %ebp
f0101c61:	89 e5                	mov    %esp,%ebp
f0101c63:	57                   	push   %edi
f0101c64:	56                   	push   %esi
f0101c65:	8d 64 24 e0          	lea    -0x20(%esp),%esp
f0101c69:	8b 7d 14             	mov    0x14(%ebp),%edi
f0101c6c:	8b 45 08             	mov    0x8(%ebp),%eax
f0101c6f:	8b 4d 10             	mov    0x10(%ebp),%ecx
f0101c72:	8b 75 0c             	mov    0xc(%ebp),%esi
f0101c75:	85 ff                	test   %edi,%edi
f0101c77:	89 45 e8             	mov    %eax,-0x18(%ebp)
f0101c7a:	89 4d f4             	mov    %ecx,-0xc(%ebp)
f0101c7d:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0101c80:	89 f2                	mov    %esi,%edx
f0101c82:	75 14                	jne    f0101c98 <__umoddi3+0x38>
f0101c84:	39 f1                	cmp    %esi,%ecx
f0101c86:	76 40                	jbe    f0101cc8 <__umoddi3+0x68>
f0101c88:	f7 f1                	div    %ecx
f0101c8a:	89 d0                	mov    %edx,%eax
f0101c8c:	31 d2                	xor    %edx,%edx
f0101c8e:	8d 64 24 20          	lea    0x20(%esp),%esp
f0101c92:	5e                   	pop    %esi
f0101c93:	5f                   	pop    %edi
f0101c94:	5d                   	pop    %ebp
f0101c95:	c3                   	ret    
f0101c96:	66 90                	xchg   %ax,%ax
f0101c98:	39 f7                	cmp    %esi,%edi
f0101c9a:	77 4c                	ja     f0101ce8 <__umoddi3+0x88>
f0101c9c:	0f bd c7             	bsr    %edi,%eax
f0101c9f:	83 f0 1f             	xor    $0x1f,%eax
f0101ca2:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0101ca5:	75 51                	jne    f0101cf8 <__umoddi3+0x98>
f0101ca7:	3b 4d f0             	cmp    -0x10(%ebp),%ecx
f0101caa:	0f 87 e8 00 00 00    	ja     f0101d98 <__umoddi3+0x138>
f0101cb0:	89 f2                	mov    %esi,%edx
f0101cb2:	8b 75 f0             	mov    -0x10(%ebp),%esi
f0101cb5:	29 ce                	sub    %ecx,%esi
f0101cb7:	19 fa                	sbb    %edi,%edx
f0101cb9:	89 75 f0             	mov    %esi,-0x10(%ebp)
f0101cbc:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0101cbf:	8d 64 24 20          	lea    0x20(%esp),%esp
f0101cc3:	5e                   	pop    %esi
f0101cc4:	5f                   	pop    %edi
f0101cc5:	5d                   	pop    %ebp
f0101cc6:	c3                   	ret    
f0101cc7:	90                   	nop
f0101cc8:	85 c9                	test   %ecx,%ecx
f0101cca:	75 0b                	jne    f0101cd7 <__umoddi3+0x77>
f0101ccc:	b8 01 00 00 00       	mov    $0x1,%eax
f0101cd1:	31 d2                	xor    %edx,%edx
f0101cd3:	f7 f1                	div    %ecx
f0101cd5:	89 c1                	mov    %eax,%ecx
f0101cd7:	89 f0                	mov    %esi,%eax
f0101cd9:	31 d2                	xor    %edx,%edx
f0101cdb:	f7 f1                	div    %ecx
f0101cdd:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0101ce0:	f7 f1                	div    %ecx
f0101ce2:	eb a6                	jmp    f0101c8a <__umoddi3+0x2a>
f0101ce4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0101ce8:	89 f2                	mov    %esi,%edx
f0101cea:	8d 64 24 20          	lea    0x20(%esp),%esp
f0101cee:	5e                   	pop    %esi
f0101cef:	5f                   	pop    %edi
f0101cf0:	5d                   	pop    %ebp
f0101cf1:	c3                   	ret    
f0101cf2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0101cf8:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
f0101cfc:	c7 45 f0 20 00 00 00 	movl   $0x20,-0x10(%ebp)
f0101d03:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0101d06:	29 45 f0             	sub    %eax,-0x10(%ebp)
f0101d09:	d3 e7                	shl    %cl,%edi
f0101d0b:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0101d0e:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
f0101d12:	89 f2                	mov    %esi,%edx
f0101d14:	d3 e8                	shr    %cl,%eax
f0101d16:	09 f8                	or     %edi,%eax
f0101d18:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
f0101d1c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0101d1f:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0101d22:	d3 e0                	shl    %cl,%eax
f0101d24:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
f0101d28:	89 45 f4             	mov    %eax,-0xc(%ebp)
f0101d2b:	8b 45 e8             	mov    -0x18(%ebp),%eax
f0101d2e:	d3 ea                	shr    %cl,%edx
f0101d30:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
f0101d34:	d3 e6                	shl    %cl,%esi
f0101d36:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
f0101d3a:	d3 e8                	shr    %cl,%eax
f0101d3c:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
f0101d40:	09 f0                	or     %esi,%eax
f0101d42:	8b 75 e8             	mov    -0x18(%ebp),%esi
f0101d45:	d3 e6                	shl    %cl,%esi
f0101d47:	f7 75 e4             	divl   -0x1c(%ebp)
f0101d4a:	89 75 e8             	mov    %esi,-0x18(%ebp)
f0101d4d:	89 d6                	mov    %edx,%esi
f0101d4f:	f7 65 f4             	mull   -0xc(%ebp)
f0101d52:	89 d7                	mov    %edx,%edi
f0101d54:	89 c2                	mov    %eax,%edx
f0101d56:	39 fe                	cmp    %edi,%esi
f0101d58:	89 f9                	mov    %edi,%ecx
f0101d5a:	72 30                	jb     f0101d8c <__umoddi3+0x12c>
f0101d5c:	39 45 e8             	cmp    %eax,-0x18(%ebp)
f0101d5f:	72 27                	jb     f0101d88 <__umoddi3+0x128>
f0101d61:	8b 45 e8             	mov    -0x18(%ebp),%eax
f0101d64:	29 d0                	sub    %edx,%eax
f0101d66:	19 ce                	sbb    %ecx,%esi
f0101d68:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
f0101d6c:	89 f2                	mov    %esi,%edx
f0101d6e:	d3 e8                	shr    %cl,%eax
f0101d70:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
f0101d74:	d3 e2                	shl    %cl,%edx
f0101d76:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
f0101d7a:	09 d0                	or     %edx,%eax
f0101d7c:	89 f2                	mov    %esi,%edx
f0101d7e:	d3 ea                	shr    %cl,%edx
f0101d80:	8d 64 24 20          	lea    0x20(%esp),%esp
f0101d84:	5e                   	pop    %esi
f0101d85:	5f                   	pop    %edi
f0101d86:	5d                   	pop    %ebp
f0101d87:	c3                   	ret    
f0101d88:	39 fe                	cmp    %edi,%esi
f0101d8a:	75 d5                	jne    f0101d61 <__umoddi3+0x101>
f0101d8c:	89 f9                	mov    %edi,%ecx
f0101d8e:	89 c2                	mov    %eax,%edx
f0101d90:	2b 55 f4             	sub    -0xc(%ebp),%edx
f0101d93:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
f0101d96:	eb c9                	jmp    f0101d61 <__umoddi3+0x101>
f0101d98:	39 f7                	cmp    %esi,%edi
f0101d9a:	0f 82 10 ff ff ff    	jb     f0101cb0 <__umoddi3+0x50>
f0101da0:	e9 17 ff ff ff       	jmp    f0101cbc <__umoddi3+0x5c>
