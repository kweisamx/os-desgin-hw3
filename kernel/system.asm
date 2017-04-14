
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
f0100009:	b8 00 60 10 00       	mov    $0x106000,%eax
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
	# C code. # because the [0,4M] has map to the pa
	mov	$relocated, %eax
f010001c:	b8 23 00 10 f0       	mov    $0xf0100023,%eax
	jmp	*%eax # it can reset the eip
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
f010002f:	bc 00 00 11 f0       	mov    $0xf0110000,%esp

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
f010006e:	e8 44 21 00 00       	call   f01021b7 <timer_init>
	 trap_init();
f0100073:	e8 e5 06 00 00       	call   f010075d <trap_init>
     mem_init();
f0100078:	e8 f0 0d 00 00       	call   f0100e6d <mem_init>

	/* Enable interrupt */
    __asm __volatile("sti");
f010007d:	fb                   	sti    
    /* Test for page fault handler */
    ptr = (int*)(0x12345678);
 //   *ptr = 1;

	shell();
}
f010007e:	83 c4 0c             	add    $0xc,%esp

    /* Test for page fault handler */
    ptr = (int*)(0x12345678);
 //   *ptr = 1;

	shell();
f0100081:	e9 f7 1f 00 00       	jmp    f010207d <shell>
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
f010008c:	80 3d 00 00 11 f0 00 	cmpb   $0x0,0xf0110000
		irq_setmask_8259A(irq_mask_8259A);
}

void
irq_setmask_8259A(uint16_t mask)
{
f0100093:	89 d0                	mov    %edx,%eax
	int i;
	irq_mask_8259A = mask;
f0100095:	66 89 15 00 50 10 f0 	mov    %dx,0xf0105000
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
f0100107:	66 a1 00 50 10 f0    	mov    0xf0105000,%ax

/* Initialize the 8259A interrupt controllers. */
void
pic_init(void)
{
	didinit = 1;
f010010d:	c6 05 00 00 11 f0 01 	movb   $0x1,0xf0110000
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
f0100151:	83 0d 0c 02 11 f0 40 	orl    $0x40,0xf011020c
f0100158:	eb 40                	jmp    f010019a <kbd_proc_data+0x72>
		return 0;
	} else if (data & 0x80) {
f010015a:	8a 44 24 0f          	mov    0xf(%esp),%al
f010015e:	8b 15 0c 02 11 f0    	mov    0xf011020c,%edx
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
f0100185:	8a 80 ac 2f 10 f0    	mov    -0xfefd054(%eax),%al
f010018b:	83 c8 40             	or     $0x40,%eax
f010018e:	0f b6 c0             	movzbl %al,%eax
f0100191:	f7 d0                	not    %eax
f0100193:	21 d0                	and    %edx,%eax
f0100195:	a3 0c 02 11 f0       	mov    %eax,0xf011020c
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
f01001ad:	89 15 0c 02 11 f0    	mov    %edx,0xf011020c
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
f01001c8:	0f b6 80 ac 2f 10 f0 	movzbl -0xfefd054(%eax),%eax
	shift ^= togglecode[data];
f01001cf:	0f b6 92 ac 30 10 f0 	movzbl -0xfefcf54(%edx),%edx
		// Last character was an E0 escape; or with 0x80
		data |= 0x80;
		shift &= ~E0ESC;
	}

	shift |= shiftcode[data];
f01001d6:	0b 05 0c 02 11 f0    	or     0xf011020c,%eax
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
f01001e9:	8b 0c 8d ac 31 10 f0 	mov    -0xfefce54(,%ecx,4),%ecx
f01001f0:	0f b6 d2             	movzbl %dl,%edx
		data |= 0x80;
		shift &= ~E0ESC;
	}

	shift |= shiftcode[data];
	shift ^= togglecode[data];
f01001f3:	a3 0c 02 11 f0       	mov    %eax,0xf011020c

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
f010024e:	68 a0 2f 10 f0       	push   $0xf0102fa0
f0100253:	e8 e6 05 00 00       	call   f010083e <cprintf>
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
f010026b:	8b 15 04 02 11 f0    	mov    0xf0110204,%edx
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
f0100273:	3b 15 08 02 11 f0    	cmp    0xf0110208,%edx
f0100279:	74 1b                	je     f0100296 <cons_getc+0x2b>
		c = cons.buf[cons.rpos++];
f010027b:	8d 4a 01             	lea    0x1(%edx),%ecx
f010027e:	0f b6 82 04 00 11 f0 	movzbl -0xfeefffc(%edx),%eax
		if (cons.rpos == CONSBUFSIZE)
			cons.rpos = 0;
f0100285:	31 d2                	xor    %edx,%edx
f0100287:	81 f9 00 02 00 00    	cmp    $0x200,%ecx
f010028d:	0f 45 d1             	cmovne %ecx,%edx
f0100290:	89 15 04 02 11 f0    	mov    %edx,0xf0110204
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
f01002a3:	8b 15 08 02 11 f0    	mov    0xf0110208,%edx
f01002a9:	88 82 04 00 11 f0    	mov    %al,-0xfeefffc(%edx)
f01002af:	8d 42 01             	lea    0x1(%edx),%eax
		if (cons.wpos == CONSBUFSIZE)
			cons.wpos = 0;
f01002b2:	3d 00 02 00 00       	cmp    $0x200,%eax
f01002b7:	0f 44 c3             	cmove  %ebx,%eax
f01002ba:	a3 08 02 11 f0       	mov    %eax,0xf0110208
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
f01002d1:	c7 05 04 02 11 f0 00 	movl   $0x0,0xf0110204
f01002d8:	00 00 00 
    cons.wpos = 0;
f01002db:	c7 05 08 02 11 f0 00 	movl   $0x0,0xf0110208
f01002e2:	00 00 00 
	kbd_intr();
f01002e5:	e8 ad ff ff ff       	call   f0100297 <kbd_intr>
	irq_setmask_8259A(irq_mask_8259A & ~(1<<IRQ_KBD));
f01002ea:	0f b7 05 00 50 10 f0 	movzwl 0xf0105000,%eax
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
f0100315:	8b 1d 14 02 11 f0    	mov    0xf0110214,%ebx
{
    unsigned short blank, temp;

    /* A blank is defined as a space... we need to give it
    *  backcolor too */
    blank = 0x0 | (attrib << 8);
f010031b:	8b 35 04 53 10 f0    	mov    0xf0105304,%esi

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
f0100329:	a1 40 06 11 f0       	mov    0xf0110640,%eax
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
f0100353:	e8 41 28 00 00       	call   f0102b99 <memcpy>

        /* Finally, we set the chunk of memory that occupies
        *  the last line of text to our 'blank' character */
        memset (textmemptr + (25 - temp) * 80, blank, 80);
f0100358:	83 c4 0c             	add    $0xc,%esp
f010035b:	8d 84 1b a0 0f 00 00 	lea    0xfa0(%ebx,%ebx,1),%eax
f0100362:	03 05 40 06 11 f0    	add    0xf0110640,%eax
f0100368:	6a 50                	push   $0x50
f010036a:	56                   	push   %esi
f010036b:	50                   	push   %eax
f010036c:	e8 4e 27 00 00       	call   f0102abf <memset>
        csr_y = 25 - 1;
f0100371:	83 c4 10             	add    $0x10,%esp
f0100374:	c7 05 14 02 11 f0 18 	movl   $0x18,0xf0110214
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
f0100384:	66 6b 0d 14 02 11 f0 	imul   $0x50,0xf0110214,%cx
f010038b:	50 
f010038c:	ba d4 03 00 00       	mov    $0x3d4,%edx
f0100391:	03 0d 10 02 11 f0    	add    0xf0110210,%ecx
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
f01003b5:	8b 35 04 53 10 f0    	mov    0xf0105304,%esi
f01003bb:	c1 e6 08             	shl    $0x8,%esi

    /* Sets the entire screen to spaces in our current
    *  color */
    for(i = 0; i < 25; i++)
        memset (textmemptr + i * 80, blank, 80);
f01003be:	0f b7 f6             	movzwl %si,%esi
f01003c1:	a1 40 06 11 f0       	mov    0xf0110640,%eax
f01003c6:	51                   	push   %ecx
f01003c7:	6a 50                	push   $0x50
f01003c9:	56                   	push   %esi
f01003ca:	01 d8                	add    %ebx,%eax
f01003cc:	81 c3 a0 00 00 00    	add    $0xa0,%ebx
f01003d2:	50                   	push   %eax
f01003d3:	e8 e7 26 00 00       	call   f0102abf <memset>
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
f01003e3:	c7 05 10 02 11 f0 00 	movl   $0x0,0xf0110210
f01003ea:	00 00 00 
    csr_y = 0;
f01003ed:	c7 05 14 02 11 f0 00 	movl   $0x0,0xf0110214
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
f0100405:	8b 0d 04 53 10 f0    	mov    0xf0105304,%ecx
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
f0100416:	a1 10 02 11 f0       	mov    0xf0110210,%eax
f010041b:	85 c0                	test   %eax,%eax
f010041d:	74 7d                	je     f010049c <putch+0x9b>
          where = (textmemptr-1) + (csr_y * 80 + csr_x);
f010041f:	6b 15 14 02 11 f0 50 	imul   $0x50,0xf0110214,%edx
f0100426:	8d 5c 10 ff          	lea    -0x1(%eax,%edx,1),%ebx
          *where = 0x0 | att;	/* Character AND attributes: color */
f010042a:	8b 15 40 06 11 f0    	mov    0xf0110640,%edx
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
f010043b:	a1 10 02 11 f0       	mov    0xf0110210,%eax
f0100440:	83 c0 08             	add    $0x8,%eax
f0100443:	83 e0 f8             	and    $0xfffffff8,%eax
f0100446:	a3 10 02 11 f0       	mov    %eax,0xf0110210
f010044b:	eb 4f                	jmp    f010049c <putch+0x9b>
    }
    /* Handles a 'Carriage Return', which simply brings the
    *  cursor back to the margin */
    else if(c == '\r')
f010044d:	3c 0d                	cmp    $0xd,%al
f010044f:	75 0c                	jne    f010045d <putch+0x5c>
    {
        csr_x = 0;
f0100451:	c7 05 10 02 11 f0 00 	movl   $0x0,0xf0110210
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
f0100461:	c7 05 10 02 11 f0 00 	movl   $0x0,0xf0110210
f0100468:	00 00 00 
        csr_y++;
f010046b:	ff 05 14 02 11 f0    	incl   0xf0110214
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
f0100477:	8b 15 10 02 11 f0    	mov    0xf0110210,%edx
        *where = c | att;	/* Character AND attributes: color */
f010047d:	0f b6 c0             	movzbl %al,%eax
    *  printable character. The equation for finding the index
    *  in a linear chunk of memory can be represented by:
    *  Index = [(y * width) + x] */
    else if(c >= ' ')
    {
        where = textmemptr + (csr_y * 80 + csr_x);
f0100480:	6b 1d 14 02 11 f0 50 	imul   $0x50,0xf0110214,%ebx
        *where = c | att;	/* Character AND attributes: color */
f0100487:	09 c8                	or     %ecx,%eax
f0100489:	8b 0d 40 06 11 f0    	mov    0xf0110640,%ecx
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
f0100496:	89 15 10 02 11 f0    	mov    %edx,0xf0110210
    }

    /* If the cursor has reached the edge of the screen's width, we
    *  insert a new line in there */
    if(csr_x >= 80)
f010049c:	83 3d 10 02 11 f0 4f 	cmpl   $0x4f,0xf0110210
f01004a3:	7e 10                	jle    f01004b5 <putch+0xb4>
    {
        csr_x = 0;
        csr_y++;
f01004a5:	ff 05 14 02 11 f0    	incl   0xf0110214

    /* If the cursor has reached the edge of the screen's width, we
    *  insert a new line in there */
    if(csr_x >= 80)
    {
        csr_x = 0;
f01004ab:	c7 05 10 02 11 f0 00 	movl   $0x0,0xf0110210
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
f01004e5:	e8 06 24 00 00       	call   f01028f0 <strlen>
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
f0100509:	a3 04 53 10 f0       	mov    %eax,0xf0105304
}
f010050e:	c3                   	ret    

f010050f <init_video>:

/* Sets our text-mode VGA pointer, then clears the screen for us */
void init_video(void)
{
f010050f:	83 ec 0c             	sub    $0xc,%esp
    textmemptr = (unsigned short *)0xB8000;
f0100512:	c7 05 40 06 11 f0 00 	movl   $0xb8000,0xf0110640
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
f010052e:	68 bc 31 10 f0       	push   $0xf01031bc
f0100533:	e8 06 03 00 00       	call   f010083e <cprintf>
	cprintf("  esi  0x%08x\n", regs->reg_esi);
f0100538:	58                   	pop    %eax
f0100539:	5a                   	pop    %edx
f010053a:	ff 73 04             	pushl  0x4(%ebx)
f010053d:	68 cb 31 10 f0       	push   $0xf01031cb
f0100542:	e8 f7 02 00 00       	call   f010083e <cprintf>
	cprintf("  ebp  0x%08x\n", regs->reg_ebp);
f0100547:	5a                   	pop    %edx
f0100548:	59                   	pop    %ecx
f0100549:	ff 73 08             	pushl  0x8(%ebx)
f010054c:	68 da 31 10 f0       	push   $0xf01031da
f0100551:	e8 e8 02 00 00       	call   f010083e <cprintf>
	cprintf("  oesp 0x%08x\n", regs->reg_oesp);
f0100556:	59                   	pop    %ecx
f0100557:	58                   	pop    %eax
f0100558:	ff 73 0c             	pushl  0xc(%ebx)
f010055b:	68 e9 31 10 f0       	push   $0xf01031e9
f0100560:	e8 d9 02 00 00       	call   f010083e <cprintf>
	cprintf("  ebx  0x%08x\n", regs->reg_ebx);
f0100565:	58                   	pop    %eax
f0100566:	5a                   	pop    %edx
f0100567:	ff 73 10             	pushl  0x10(%ebx)
f010056a:	68 f8 31 10 f0       	push   $0xf01031f8
f010056f:	e8 ca 02 00 00       	call   f010083e <cprintf>
	cprintf("  edx  0x%08x\n", regs->reg_edx);
f0100574:	5a                   	pop    %edx
f0100575:	59                   	pop    %ecx
f0100576:	ff 73 14             	pushl  0x14(%ebx)
f0100579:	68 07 32 10 f0       	push   $0xf0103207
f010057e:	e8 bb 02 00 00       	call   f010083e <cprintf>
	cprintf("  ecx  0x%08x\n", regs->reg_ecx);
f0100583:	59                   	pop    %ecx
f0100584:	58                   	pop    %eax
f0100585:	ff 73 18             	pushl  0x18(%ebx)
f0100588:	68 16 32 10 f0       	push   $0xf0103216
f010058d:	e8 ac 02 00 00       	call   f010083e <cprintf>
	cprintf("  eax  0x%08x\n", regs->reg_eax);
f0100592:	58                   	pop    %eax
f0100593:	5a                   	pop    %edx
f0100594:	ff 73 1c             	pushl  0x1c(%ebx)
f0100597:	68 25 32 10 f0       	push   $0xf0103225
f010059c:	e8 9d 02 00 00       	call   f010083e <cprintf>
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
f01005af:	68 89 32 10 f0       	push   $0xf0103289
f01005b4:	e8 85 02 00 00       	call   f010083e <cprintf>
	print_regs(&tf->tf_regs);
f01005b9:	89 1c 24             	mov    %ebx,(%esp)
f01005bc:	e8 63 ff ff ff       	call   f0100524 <print_regs>
	cprintf("  es   0x----%04x\n", tf->tf_es);
f01005c1:	0f b7 43 20          	movzwl 0x20(%ebx),%eax
f01005c5:	5a                   	pop    %edx
f01005c6:	59                   	pop    %ecx
f01005c7:	50                   	push   %eax
f01005c8:	68 9c 32 10 f0       	push   $0xf010329c
f01005cd:	e8 6c 02 00 00       	call   f010083e <cprintf>
	cprintf("  ds   0x----%04x\n", tf->tf_ds);
f01005d2:	5e                   	pop    %esi
f01005d3:	58                   	pop    %eax
f01005d4:	0f b7 43 24          	movzwl 0x24(%ebx),%eax
f01005d8:	50                   	push   %eax
f01005d9:	68 af 32 10 f0       	push   $0xf01032af
f01005de:	e8 5b 02 00 00       	call   f010083e <cprintf>
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
f01005ee:	8b 14 85 b4 34 10 f0 	mov    -0xfefcb4c(,%eax,4),%edx
f01005f5:	eb 1d                	jmp    f0100614 <print_trapframe+0x6e>
	if (trapno == T_SYSCALL)
f01005f7:	83 f8 30             	cmp    $0x30,%eax
		return "System call";
f01005fa:	ba 34 32 10 f0       	mov    $0xf0103234,%edx
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
f0100604:	ba 40 32 10 f0       	mov    $0xf0103240,%edx
f0100609:	83 f9 0f             	cmp    $0xf,%ecx
f010060c:	b9 53 32 10 f0       	mov    $0xf0103253,%ecx
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
f0100617:	68 c2 32 10 f0       	push   $0xf01032c2
f010061c:	e8 1d 02 00 00       	call   f010083e <cprintf>
	// If this trap was a page fault that just happened
	// (so %cr2 is meaningful), print the faulting linear address.
	if (tf == last_tf && tf->tf_trapno == T_PGFLT)
f0100621:	83 c4 10             	add    $0x10,%esp
f0100624:	3b 1d 18 02 11 f0    	cmp    0xf0110218,%ebx
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
f0100638:	68 d4 32 10 f0       	push   $0xf01032d4
f010063d:	e8 fc 01 00 00       	call   f010083e <cprintf>
f0100642:	83 c4 10             	add    $0x10,%esp
	cprintf("  err  0x%08x", tf->tf_err);
f0100645:	56                   	push   %esi
f0100646:	56                   	push   %esi
f0100647:	ff 73 2c             	pushl  0x2c(%ebx)
f010064a:	68 e3 32 10 f0       	push   $0xf01032e3
f010064f:	e8 ea 01 00 00       	call   f010083e <cprintf>
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
f0100660:	b8 6d 32 10 f0       	mov    $0xf010326d,%eax
f0100665:	b9 62 32 10 f0       	mov    $0xf0103262,%ecx
f010066a:	ba 79 32 10 f0       	mov    $0xf0103279,%edx
f010066f:	f7 c6 01 00 00 00    	test   $0x1,%esi
f0100675:	0f 44 c8             	cmove  %eax,%ecx
f0100678:	f7 c6 02 00 00 00    	test   $0x2,%esi
f010067e:	b8 7f 32 10 f0       	mov    $0xf010327f,%eax
f0100683:	0f 44 d0             	cmove  %eax,%edx
f0100686:	83 e6 04             	and    $0x4,%esi
f0100689:	51                   	push   %ecx
f010068a:	b8 84 32 10 f0       	mov    $0xf0103284,%eax
f010068f:	be 26 3f 10 f0       	mov    $0xf0103f26,%esi
f0100694:	52                   	push   %edx
f0100695:	0f 44 c6             	cmove  %esi,%eax
f0100698:	50                   	push   %eax
f0100699:	68 f1 32 10 f0       	push   $0xf01032f1
f010069e:	eb 08                	jmp    f01006a8 <print_trapframe+0x102>
			tf->tf_err & 4 ? "user" : "kernel",
			tf->tf_err & 2 ? "write" : "read",
			tf->tf_err & 1 ? "protection" : "not-present");
	else
		cprintf("\n");
f01006a0:	83 ec 0c             	sub    $0xc,%esp
f01006a3:	68 9a 32 10 f0       	push   $0xf010329a
f01006a8:	e8 91 01 00 00       	call   f010083e <cprintf>
f01006ad:	5a                   	pop    %edx
f01006ae:	59                   	pop    %ecx
	cprintf("  eip  0x%08x\n", tf->tf_eip);
f01006af:	ff 73 30             	pushl  0x30(%ebx)
f01006b2:	68 00 33 10 f0       	push   $0xf0103300
f01006b7:	e8 82 01 00 00       	call   f010083e <cprintf>
	cprintf("  cs   0x----%04x\n", tf->tf_cs);
f01006bc:	5e                   	pop    %esi
f01006bd:	58                   	pop    %eax
f01006be:	0f b7 43 34          	movzwl 0x34(%ebx),%eax
f01006c2:	50                   	push   %eax
f01006c3:	68 0f 33 10 f0       	push   $0xf010330f
f01006c8:	e8 71 01 00 00       	call   f010083e <cprintf>
	cprintf("  flag 0x%08x\n", tf->tf_eflags);
f01006cd:	5a                   	pop    %edx
f01006ce:	59                   	pop    %ecx
f01006cf:	ff 73 38             	pushl  0x38(%ebx)
f01006d2:	68 22 33 10 f0       	push   $0xf0103322
f01006d7:	e8 62 01 00 00       	call   f010083e <cprintf>
	if ((tf->tf_cs & 3) != 0) {
f01006dc:	83 c4 10             	add    $0x10,%esp
f01006df:	f6 43 34 03          	testb  $0x3,0x34(%ebx)
f01006e3:	74 23                	je     f0100708 <print_trapframe+0x162>
		cprintf("  esp  0x%08x\n", tf->tf_esp);
f01006e5:	50                   	push   %eax
f01006e6:	50                   	push   %eax
f01006e7:	ff 73 3c             	pushl  0x3c(%ebx)
f01006ea:	68 31 33 10 f0       	push   $0xf0103331
f01006ef:	e8 4a 01 00 00       	call   f010083e <cprintf>
		cprintf("  ss   0x----%04x\n", tf->tf_ss);
f01006f4:	0f b7 43 40          	movzwl 0x40(%ebx),%eax
f01006f8:	59                   	pop    %ecx
f01006f9:	5e                   	pop    %esi
f01006fa:	50                   	push   %eax
f01006fb:	68 40 33 10 f0       	push   $0xf0103340
f0100700:	e8 39 01 00 00       	call   f010083e <cprintf>
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
f0100718:	a3 18 02 11 f0       	mov    %eax,0xf0110218
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
f0100732:	e9 73 1a 00 00       	jmp    f01021aa <timer_handler>
        return;
    }
    if(tf->tf_trapno == T_PGFLT)
f0100737:	83 fa 0e             	cmp    $0xe,%edx
f010073a:	75 15                	jne    f0100751 <default_trap_handler+0x43>
f010073c:	0f 20 d0             	mov    %cr2,%eax
    {
		cprintf("0556148 Page Fault @ 0x%08x\n", rcr2());
f010073f:	52                   	push   %edx
f0100740:	52                   	push   %edx
f0100741:	50                   	push   %eax
f0100742:	68 53 33 10 f0       	push   $0xf0103353
f0100747:	e8 f2 00 00 00       	call   f010083e <cprintf>
f010074c:	83 c4 10             	add    $0x10,%esp
f010074f:	eb fe                	jmp    f010074f <default_trap_handler+0x41>
   *       We prepared the keyboard handler and timer handler for you
   *       already. Please reference in kernel/kbd.c and kernel/timer.c
   */

	// Unexpected trap: The user process or the kernel has a bug.
	print_trapframe(tf);
f0100751:	89 44 24 10          	mov    %eax,0x10(%esp)
	// print_trapframe can print some additional information.
	last_tf = tf;

	// Dispatch based on what type of trap occurred
	trap_dispatch(tf);
}
f0100755:	83 c4 0c             	add    $0xc,%esp
   *       We prepared the keyboard handler and timer handler for you
   *       already. Please reference in kernel/kbd.c and kernel/timer.c
   */

	// Unexpected trap: The user process or the kernel has a bug.
	print_trapframe(tf);
f0100758:	e9 49 fe ff ff       	jmp    f01005a6 <print_trapframe>

f010075d <trap_init>:
 //   int i;                                                                       
   // for(i = 0;i < 256; i++)
     //   SETGATE(idt[i],0,GD_KT,64*i,0);
           //it is means to map idt to function
           //trap_entry.s is to define the function of handler
    SETGATE(idt[IRQ_OFFSET + IRQ_KBD],0,GD_KT,kbd,0);
f010075d:	b8 ee 07 10 f0       	mov    $0xf01007ee,%eax
f0100762:	66 a3 4c 07 11 f0    	mov    %ax,0xf011074c
f0100768:	c1 e8 10             	shr    $0x10,%eax
f010076b:	66 a3 52 07 11 f0    	mov    %ax,0xf0110752
    SETGATE(idt[IRQ_OFFSET + IRQ_TIMER],0,GD_KT,timer,0);
f0100771:	b8 e8 07 10 f0       	mov    $0xf01007e8,%eax
f0100776:	66 a3 44 07 11 f0    	mov    %ax,0xf0110744
f010077c:	c1 e8 10             	shr    $0x10,%eax
f010077f:	66 a3 4a 07 11 f0    	mov    %ax,0xf011074a
    SETGATE(idt[T_PGFLT],1,GD_KT,pagefault,0);
f0100785:	b8 f4 07 10 f0       	mov    $0xf01007f4,%eax
f010078a:	66 a3 b4 06 11 f0    	mov    %ax,0xf01106b4
f0100790:	c1 e8 10             	shr    $0x10,%eax
f0100793:	66 a3 ba 06 11 f0    	mov    %ax,0xf01106ba
}

static __inline void
lidt(void *p)
{
	__asm __volatile("lidt (%0)" : : "r" (p));
f0100799:	b8 08 53 10 f0       	mov    $0xf0105308,%eax
 //   int i;                                                                       
   // for(i = 0;i < 256; i++)
     //   SETGATE(idt[i],0,GD_KT,64*i,0);
           //it is means to map idt to function
           //trap_entry.s is to define the function of handler
    SETGATE(idt[IRQ_OFFSET + IRQ_KBD],0,GD_KT,kbd,0);
f010079e:	66 c7 05 4e 07 11 f0 	movw   $0x8,0xf011074e
f01007a5:	08 00 
f01007a7:	c6 05 50 07 11 f0 00 	movb   $0x0,0xf0110750
f01007ae:	c6 05 51 07 11 f0 8e 	movb   $0x8e,0xf0110751
    SETGATE(idt[IRQ_OFFSET + IRQ_TIMER],0,GD_KT,timer,0);
f01007b5:	66 c7 05 46 07 11 f0 	movw   $0x8,0xf0110746
f01007bc:	08 00 
f01007be:	c6 05 48 07 11 f0 00 	movb   $0x0,0xf0110748
f01007c5:	c6 05 49 07 11 f0 8e 	movb   $0x8e,0xf0110749
    SETGATE(idt[T_PGFLT],1,GD_KT,pagefault,0);
f01007cc:	66 c7 05 b6 06 11 f0 	movw   $0x8,0xf01106b6
f01007d3:	08 00 
f01007d5:	c6 05 b8 06 11 f0 00 	movb   $0x0,0xf01106b8
f01007dc:	c6 05 b9 06 11 f0 8f 	movb   $0x8f,0xf01106b9
f01007e3:	0f 01 18             	lidtl  (%eax)

	/* Keyboard interrupt setup */
	/* Timer Trap setup */
  /* Load IDT */

}
f01007e6:	c3                   	ret    
	...

f01007e8 <timer>:
	pushl $(num);							\
	jmp _alltraps


.text
    TRAPHANDLER_NOEC(timer,IRQ_OFFSET + IRQ_TIMER)
f01007e8:	6a 00                	push   $0x0
f01007ea:	6a 20                	push   $0x20
f01007ec:	eb 0c                	jmp    f01007fa <_alltraps>

f01007ee <kbd>:
    TRAPHANDLER_NOEC(kbd,IRQ_OFFSET + IRQ_KBD)   
f01007ee:	6a 00                	push   $0x0
f01007f0:	6a 21                	push   $0x21
f01007f2:	eb 06                	jmp    f01007fa <_alltraps>

f01007f4 <pagefault>:
    TRAPHANDLER_NOEC(pagefault,T_PGFLT)
f01007f4:	6a 00                	push   $0x0
f01007f6:	6a 0e                	push   $0xe
f01007f8:	eb 00                	jmp    f01007fa <_alltraps>

f01007fa <_alltraps>:
   *       CPU.
   *       You may want to leverage the "pusha" instructions to reduce your work of
   *       pushing all the general purpose registers into the stack.
	 */
/*because  in kernel stack ,we need to reverse the push order trapno ->     ds - > es -> pusha*/
    pushl %ds
f01007fa:	1e                   	push   %ds
    pushl %es
f01007fb:	06                   	push   %es
    pusha          #  push AX CX BX SP BP SI DI
f01007fc:	60                   	pusha  

    /*load kernel segment */
    movw $(GD_KT), %ax
f01007fd:	66 b8 08 00          	mov    $0x8,%ax
    movw %ax , %ds
f0100801:	8e d8                	mov    %eax,%ds
    movw %ax , %es
f0100803:	8e c0                	mov    %eax,%es

	pushl %esp # Pass a pointer which points to the Trapframe as an argument to default_trap_handler()
f0100805:	54                   	push   %esp
	call default_trap_handler
f0100806:	e8 03 ff ff ff       	call   f010070e <default_trap_handler>
    popl %esp
f010080b:	5c                   	pop    %esp
    popa
f010080c:	61                   	popa   
    popl %es
f010080d:	07                   	pop    %es
    popl %ds
f010080e:	1f                   	pop    %ds

	add $8, %esp # Cleans up the pushed error code and pushed ISR number
f010080f:	83 c4 08             	add    $0x8,%esp
	iret # pops 5 things at once: CS, EIP, EFLAGS, SS, and ESP!
f0100812:	cf                   	iret   
	...

f0100814 <vcprintf>:
#include <inc/stdio.h>


int
vcprintf(const char *fmt, va_list ap)
{
f0100814:	83 ec 1c             	sub    $0x1c,%esp
	int cnt = 0;
f0100817:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
f010081e:	00 

	vprintfmt((void*)putch, &cnt, fmt, ap);
f010081f:	ff 74 24 24          	pushl  0x24(%esp)
f0100823:	ff 74 24 24          	pushl  0x24(%esp)
f0100827:	8d 44 24 14          	lea    0x14(%esp),%eax
f010082b:	50                   	push   %eax
f010082c:	68 01 04 10 f0       	push   $0xf0100401
f0100831:	e8 19 1b 00 00       	call   f010234f <vprintfmt>
	return cnt;
}
f0100836:	8b 44 24 1c          	mov    0x1c(%esp),%eax
f010083a:	83 c4 2c             	add    $0x2c,%esp
f010083d:	c3                   	ret    

f010083e <cprintf>:

int
cprintf(const char *fmt, ...)
{
f010083e:	83 ec 0c             	sub    $0xc,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
f0100841:	8d 44 24 14          	lea    0x14(%esp),%eax
	cnt = vcprintf(fmt, ap);
f0100845:	52                   	push   %edx
f0100846:	52                   	push   %edx
f0100847:	50                   	push   %eax
f0100848:	ff 74 24 1c          	pushl  0x1c(%esp)
f010084c:	e8 c3 ff ff ff       	call   f0100814 <vcprintf>
	va_end(ap);

	return cnt;
}
f0100851:	83 c4 1c             	add    $0x1c,%esp
f0100854:	c3                   	ret    
f0100855:	00 00                	add    %al,(%eax)
	...

f0100858 <page2pa>:
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0100858:	2b 05 4c 0e 11 f0    	sub    0xf0110e4c,%eax
f010085e:	c1 f8 03             	sar    $0x3,%eax
f0100861:	c1 e0 0c             	shl    $0xc,%eax
}
f0100864:	c3                   	ret    

f0100865 <boot_alloc>:
	// Initialize nextfree if this is the first time.
	// 'end' is a magic symbol automatically generated by the linker,#end is behind on bss
	// which points to the end of the kernel's bss segment:
	// the first virtual address that the linker did *not* assign
	// to any kernel code or global variables.
	if (!nextfree) {
f0100865:	83 3d 24 02 11 f0 00 	cmpl   $0x0,0xf0110224
// This function may ONLY be used during initialization,
// before the page_free_list list has been set up.
// boot_alloc return the address which can be used
static void *
boot_alloc(uint32_t n)
{
f010086c:	89 c2                	mov    %eax,%edx
	// Initialize nextfree if this is the first time.
	// 'end' is a magic symbol automatically generated by the linker,#end is behind on bss
	// which points to the end of the kernel's bss segment:
	// the first virtual address that the linker did *not* assign
	// to any kernel code or global variables.
	if (!nextfree) {
f010086e:	75 11                	jne    f0100881 <boot_alloc+0x1c>
		extern char end[];
		nextfree = ROUNDUP((char *) end, PGSIZE);
f0100870:	b9 53 1e 11 f0       	mov    $0xf0111e53,%ecx
f0100875:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
f010087b:	89 0d 24 02 11 f0    	mov    %ecx,0xf0110224

	//!! Allocate a chunk large enough to hold 'n' bytes, then update
	//!! nextfree.  Make sure nextfree is kept aligned
	//!!! to a multiple of PGSIZE.
    //if n is zero return the address currently, else return the address can be div by page
    if (n == 0)
f0100881:	85 d2                	test   %edx,%edx
f0100883:	a1 24 02 11 f0       	mov    0xf0110224,%eax
f0100888:	74 15                	je     f010089f <boot_alloc+0x3a>
        return nextfree;
    else if (n > 0)
    {
        result = nextfree;
        nextfree += ROUNDUP(n, PGSIZE);//find the nearest address which is nearest to address is be div by pagesize
f010088a:	81 c2 ff 0f 00 00    	add    $0xfff,%edx
f0100890:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0100896:	8d 14 10             	lea    (%eax,%edx,1),%edx
f0100899:	89 15 24 02 11 f0    	mov    %edx,0xf0110224
    }

	return result;
}
f010089f:	c3                   	ret    

f01008a0 <_kaddr>:
 * virtual address.  It panics if you pass an invalid physical address. */
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
f01008a0:	53                   	push   %ebx
	if (PGNUM(pa) >= npages)
f01008a1:	89 cb                	mov    %ecx,%ebx
 * virtual address.  It panics if you pass an invalid physical address. */
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
f01008a3:	83 ec 08             	sub    $0x8,%esp
	if (PGNUM(pa) >= npages)
f01008a6:	c1 eb 0c             	shr    $0xc,%ebx
f01008a9:	3b 1d 44 0e 11 f0    	cmp    0xf0110e44,%ebx
f01008af:	72 0d                	jb     f01008be <_kaddr+0x1e>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01008b1:	51                   	push   %ecx
f01008b2:	68 04 35 10 f0       	push   $0xf0103504
f01008b7:	52                   	push   %edx
f01008b8:	50                   	push   %eax
f01008b9:	e8 f6 15 00 00       	call   f0101eb4 <_panic>
	return (void *)(pa + KERNBASE);
f01008be:	8d 81 00 00 00 f0    	lea    -0x10000000(%ecx),%eax
}
f01008c4:	83 c4 08             	add    $0x8,%esp
f01008c7:	5b                   	pop    %ebx
f01008c8:	c3                   	ret    

f01008c9 <page2kva>:
	return &pages[PGNUM(pa)];
}

static inline void*
page2kva(struct PageInfo *pp)
{
f01008c9:	83 ec 0c             	sub    $0xc,%esp
	return KADDR(page2pa(pp));
f01008cc:	e8 87 ff ff ff       	call   f0100858 <page2pa>
f01008d1:	ba 4d 00 00 00       	mov    $0x4d,%edx
}
f01008d6:	83 c4 0c             	add    $0xc,%esp
}

static inline void*
page2kva(struct PageInfo *pp)
{
	return KADDR(page2pa(pp));
f01008d9:	89 c1                	mov    %eax,%ecx
f01008db:	b8 27 35 10 f0       	mov    $0xf0103527,%eax
f01008e0:	eb be                	jmp    f01008a0 <_kaddr>

f01008e2 <check_va2pa>:
// this functionality for us!  We define our own version to help check
// the check_kern_pgdir() function; it shouldn't be used elsewhere.

static physaddr_t
check_va2pa(pde_t *pgdir, uintptr_t va)
{
f01008e2:	56                   	push   %esi
f01008e3:	89 d6                	mov    %edx,%esi
f01008e5:	53                   	push   %ebx
	pte_t *p;

	pgdir = &pgdir[PDX(va)];
	if (!(*pgdir & PTE_P))
		return ~0;
f01008e6:	83 cb ff             	or     $0xffffffff,%ebx
static physaddr_t
check_va2pa(pde_t *pgdir, uintptr_t va)
{
	pte_t *p;

	pgdir = &pgdir[PDX(va)];
f01008e9:	c1 ea 16             	shr    $0x16,%edx
// this functionality for us!  We define our own version to help check
// the check_kern_pgdir() function; it shouldn't be used elsewhere.

static physaddr_t
check_va2pa(pde_t *pgdir, uintptr_t va)
{
f01008ec:	83 ec 04             	sub    $0x4,%esp
	pte_t *p;

	pgdir = &pgdir[PDX(va)];
	if (!(*pgdir & PTE_P))
f01008ef:	8b 0c 90             	mov    (%eax,%edx,4),%ecx
f01008f2:	f6 c1 01             	test   $0x1,%cl
f01008f5:	74 2e                	je     f0100925 <check_va2pa+0x43>
		return ~0;
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
f01008f7:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
f01008fd:	ba eb 02 00 00       	mov    $0x2eb,%edx
f0100902:	b8 36 35 10 f0       	mov    $0xf0103536,%eax
f0100907:	e8 94 ff ff ff       	call   f01008a0 <_kaddr>
	if (!(p[PTX(va)] & PTE_P))
f010090c:	c1 ee 0c             	shr    $0xc,%esi
f010090f:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
f0100915:	8b 04 b0             	mov    (%eax,%esi,4),%eax
		return ~0;
	return PTE_ADDR(p[PTX(va)]);
f0100918:	89 c2                	mov    %eax,%edx
f010091a:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0100920:	a8 01                	test   $0x1,%al
f0100922:	0f 45 da             	cmovne %edx,%ebx
}
f0100925:	89 d8                	mov    %ebx,%eax
f0100927:	83 c4 04             	add    $0x4,%esp
f010092a:	5b                   	pop    %ebx
f010092b:	5e                   	pop    %esi
f010092c:	c3                   	ret    

f010092d <check_page_free_list>:
//
// Check that the pages on the page_free_list are reasonable.
//
static void
check_page_free_list(bool only_low_memory)
{
f010092d:	55                   	push   %ebp
f010092e:	57                   	push   %edi
f010092f:	56                   	push   %esi
f0100930:	53                   	push   %ebx
f0100931:	83 ec 1c             	sub    $0x1c,%esp
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
	int nfree_basemem = 0, nfree_extmem = 0;
	char *first_free_page;

	if (!page_free_list)
f0100934:	8b 1d 1c 02 11 f0    	mov    0xf011021c,%ebx
//
static void
check_page_free_list(bool only_low_memory)
{
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f010093a:	3c 01                	cmp    $0x1,%al
f010093c:	19 f6                	sbb    %esi,%esi
f010093e:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
f0100944:	46                   	inc    %esi
	int nfree_basemem = 0, nfree_extmem = 0;
	char *first_free_page;

	if (!page_free_list)
f0100945:	85 db                	test   %ebx,%ebx
f0100947:	75 10                	jne    f0100959 <check_page_free_list+0x2c>
		panic("'page_free_list' is a null pointer!");
f0100949:	51                   	push   %ecx
f010094a:	68 43 35 10 f0       	push   $0xf0103543
f010094f:	68 29 02 00 00       	push   $0x229
f0100954:	e9 b6 00 00 00       	jmp    f0100a0f <check_page_free_list+0xe2>

	if (only_low_memory) {
f0100959:	84 c0                	test   %al,%al
f010095b:	74 4b                	je     f01009a8 <check_page_free_list+0x7b>
		// Move pages with lower addresses first in the free
		// list, since entry_pgdir does not map all pages.
		struct PageInfo *pp1, *pp2;
		struct PageInfo **tp[2] = { &pp1, &pp2 };
f010095d:	8d 44 24 0c          	lea    0xc(%esp),%eax
f0100961:	89 04 24             	mov    %eax,(%esp)
f0100964:	8d 44 24 08          	lea    0x8(%esp),%eax
f0100968:	89 44 24 04          	mov    %eax,0x4(%esp)
		for (pp = page_free_list; pp; pp = pp->pp_link) {
			int pagetype = PDX(page2pa(pp)) >= pdx_limit;
f010096c:	89 d8                	mov    %ebx,%eax
f010096e:	e8 e5 fe ff ff       	call   f0100858 <page2pa>
f0100973:	c1 e8 16             	shr    $0x16,%eax
f0100976:	39 f0                	cmp    %esi,%eax
f0100978:	0f 93 c0             	setae  %al
f010097b:	0f b6 c0             	movzbl %al,%eax
			*tp[pagetype] = pp;
f010097e:	8b 14 84             	mov    (%esp,%eax,4),%edx
f0100981:	89 1a                	mov    %ebx,(%edx)
			tp[pagetype] = &pp->pp_link;
f0100983:	89 1c 84             	mov    %ebx,(%esp,%eax,4)
	if (only_low_memory) {
		// Move pages with lower addresses first in the free
		// list, since entry_pgdir does not map all pages.
		struct PageInfo *pp1, *pp2;
		struct PageInfo **tp[2] = { &pp1, &pp2 };
		for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100986:	8b 1b                	mov    (%ebx),%ebx
f0100988:	85 db                	test   %ebx,%ebx
f010098a:	75 e0                	jne    f010096c <check_page_free_list+0x3f>
			int pagetype = PDX(page2pa(pp)) >= pdx_limit;
			*tp[pagetype] = pp;
			tp[pagetype] = &pp->pp_link;
		}
		*tp[1] = 0;
f010098c:	8b 44 24 04          	mov    0x4(%esp),%eax
f0100990:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		*tp[0] = pp2;
f0100996:	8b 04 24             	mov    (%esp),%eax
f0100999:	8b 54 24 08          	mov    0x8(%esp),%edx
f010099d:	89 10                	mov    %edx,(%eax)
		page_free_list = pp1;
f010099f:	8b 44 24 0c          	mov    0xc(%esp),%eax
f01009a3:	a3 1c 02 11 f0       	mov    %eax,0xf011021c
	}

	// if there's a page that shouldn't be on the free list,
	// try to make sure it eventually causes trouble.
	for (pp = page_free_list; pp; pp = pp->pp_link)
f01009a8:	8b 1d 1c 02 11 f0    	mov    0xf011021c,%ebx
f01009ae:	eb 2b                	jmp    f01009db <check_page_free_list+0xae>
		if (PDX(page2pa(pp)) < pdx_limit)
f01009b0:	89 d8                	mov    %ebx,%eax
f01009b2:	e8 a1 fe ff ff       	call   f0100858 <page2pa>
f01009b7:	c1 e8 16             	shr    $0x16,%eax
f01009ba:	39 f0                	cmp    %esi,%eax
f01009bc:	73 1b                	jae    f01009d9 <check_page_free_list+0xac>
			memset(page2kva(pp), 0x97, 128);
f01009be:	89 d8                	mov    %ebx,%eax
f01009c0:	e8 04 ff ff ff       	call   f01008c9 <page2kva>
f01009c5:	52                   	push   %edx
f01009c6:	68 80 00 00 00       	push   $0x80
f01009cb:	68 97 00 00 00       	push   $0x97
f01009d0:	50                   	push   %eax
f01009d1:	e8 e9 20 00 00       	call   f0102abf <memset>
f01009d6:	83 c4 10             	add    $0x10,%esp
		page_free_list = pp1;
	}

	// if there's a page that shouldn't be on the free list,
	// try to make sure it eventually causes trouble.
	for (pp = page_free_list; pp; pp = pp->pp_link)
f01009d9:	8b 1b                	mov    (%ebx),%ebx
f01009db:	85 db                	test   %ebx,%ebx
f01009dd:	75 d1                	jne    f01009b0 <check_page_free_list+0x83>
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
f01009df:	31 c0                	xor    %eax,%eax
static void
check_page_free_list(bool only_low_memory)
{
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
	int nfree_basemem = 0, nfree_extmem = 0;
f01009e1:	31 f6                	xor    %esi,%esi
	// try to make sure it eventually causes trouble.
	for (pp = page_free_list; pp; pp = pp->pp_link)
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
f01009e3:	e8 7d fe ff ff       	call   f0100865 <boot_alloc>
static void
check_page_free_list(bool only_low_memory)
{
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
	int nfree_basemem = 0, nfree_extmem = 0;
f01009e8:	31 ff                	xor    %edi,%edi
	for (pp = page_free_list; pp; pp = pp->pp_link)
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f01009ea:	8b 1d 1c 02 11 f0    	mov    0xf011021c,%ebx
	// try to make sure it eventually causes trouble.
	for (pp = page_free_list; pp; pp = pp->pp_link)
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
f01009f0:	89 c5                	mov    %eax,%ebp
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f01009f2:	e9 ff 00 00 00       	jmp    f0100af6 <check_page_free_list+0x1c9>
		// check that we didn't corrupt the free list itself
		assert(pp >= pages);
f01009f7:	a1 4c 0e 11 f0       	mov    0xf0110e4c,%eax
f01009fc:	39 c3                	cmp    %eax,%ebx
f01009fe:	73 19                	jae    f0100a19 <check_page_free_list+0xec>
f0100a00:	68 67 35 10 f0       	push   $0xf0103567
f0100a05:	68 73 35 10 f0       	push   $0xf0103573
f0100a0a:	68 43 02 00 00       	push   $0x243
f0100a0f:	68 36 35 10 f0       	push   $0xf0103536
f0100a14:	e8 9b 14 00 00       	call   f0101eb4 <_panic>
		assert(pp < pages + npages);
f0100a19:	8b 15 44 0e 11 f0    	mov    0xf0110e44,%edx
f0100a1f:	8d 14 d0             	lea    (%eax,%edx,8),%edx
f0100a22:	39 d3                	cmp    %edx,%ebx
f0100a24:	72 11                	jb     f0100a37 <check_page_free_list+0x10a>
f0100a26:	68 88 35 10 f0       	push   $0xf0103588
f0100a2b:	68 73 35 10 f0       	push   $0xf0103573
f0100a30:	68 44 02 00 00       	push   $0x244
f0100a35:	eb d8                	jmp    f0100a0f <check_page_free_list+0xe2>
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0100a37:	89 da                	mov    %ebx,%edx
f0100a39:	29 c2                	sub    %eax,%edx
f0100a3b:	89 d0                	mov    %edx,%eax
f0100a3d:	a8 07                	test   $0x7,%al
f0100a3f:	74 11                	je     f0100a52 <check_page_free_list+0x125>
f0100a41:	68 9c 35 10 f0       	push   $0xf010359c
f0100a46:	68 73 35 10 f0       	push   $0xf0103573
f0100a4b:	68 45 02 00 00       	push   $0x245
f0100a50:	eb bd                	jmp    f0100a0f <check_page_free_list+0xe2>

		// check a few pages that shouldn't be on the free list
		assert(page2pa(pp) != 0);
f0100a52:	89 d8                	mov    %ebx,%eax
f0100a54:	e8 ff fd ff ff       	call   f0100858 <page2pa>
f0100a59:	85 c0                	test   %eax,%eax
f0100a5b:	75 11                	jne    f0100a6e <check_page_free_list+0x141>
f0100a5d:	68 ce 35 10 f0       	push   $0xf01035ce
f0100a62:	68 73 35 10 f0       	push   $0xf0103573
f0100a67:	68 48 02 00 00       	push   $0x248
f0100a6c:	eb a1                	jmp    f0100a0f <check_page_free_list+0xe2>
		assert(page2pa(pp) != IOPHYSMEM);
f0100a6e:	3d 00 00 0a 00       	cmp    $0xa0000,%eax
f0100a73:	75 11                	jne    f0100a86 <check_page_free_list+0x159>
f0100a75:	68 df 35 10 f0       	push   $0xf01035df
f0100a7a:	68 73 35 10 f0       	push   $0xf0103573
f0100a7f:	68 49 02 00 00       	push   $0x249
f0100a84:	eb 89                	jmp    f0100a0f <check_page_free_list+0xe2>
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
f0100a86:	3d 00 f0 0f 00       	cmp    $0xff000,%eax
f0100a8b:	75 14                	jne    f0100aa1 <check_page_free_list+0x174>
f0100a8d:	68 f8 35 10 f0       	push   $0xf01035f8
f0100a92:	68 73 35 10 f0       	push   $0xf0103573
f0100a97:	68 4a 02 00 00       	push   $0x24a
f0100a9c:	e9 6e ff ff ff       	jmp    f0100a0f <check_page_free_list+0xe2>
		assert(page2pa(pp) != EXTPHYSMEM);
f0100aa1:	3d 00 00 10 00       	cmp    $0x100000,%eax
f0100aa6:	75 14                	jne    f0100abc <check_page_free_list+0x18f>
f0100aa8:	68 1b 36 10 f0       	push   $0xf010361b
f0100aad:	68 73 35 10 f0       	push   $0xf0103573
f0100ab2:	68 4b 02 00 00       	push   $0x24b
f0100ab7:	e9 53 ff ff ff       	jmp    f0100a0f <check_page_free_list+0xe2>
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
f0100abc:	3d ff ff 0f 00       	cmp    $0xfffff,%eax
f0100ac1:	76 1f                	jbe    f0100ae2 <check_page_free_list+0x1b5>
f0100ac3:	89 d8                	mov    %ebx,%eax
f0100ac5:	e8 ff fd ff ff       	call   f01008c9 <page2kva>
f0100aca:	39 e8                	cmp    %ebp,%eax
f0100acc:	73 14                	jae    f0100ae2 <check_page_free_list+0x1b5>
f0100ace:	68 35 36 10 f0       	push   $0xf0103635
f0100ad3:	68 73 35 10 f0       	push   $0xf0103573
f0100ad8:	68 4c 02 00 00       	push   $0x24c
f0100add:	e9 2d ff ff ff       	jmp    f0100a0f <check_page_free_list+0xe2>

		if (page2pa(pp) < EXTPHYSMEM)
f0100ae2:	89 d8                	mov    %ebx,%eax
f0100ae4:	e8 6f fd ff ff       	call   f0100858 <page2pa>
f0100ae9:	3d ff ff 0f 00       	cmp    $0xfffff,%eax
f0100aee:	77 03                	ja     f0100af3 <check_page_free_list+0x1c6>
			++nfree_basemem;
f0100af0:	47                   	inc    %edi
f0100af1:	eb 01                	jmp    f0100af4 <check_page_free_list+0x1c7>
		else
			++nfree_extmem;
f0100af3:	46                   	inc    %esi
	for (pp = page_free_list; pp; pp = pp->pp_link)
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100af4:	8b 1b                	mov    (%ebx),%ebx
f0100af6:	85 db                	test   %ebx,%ebx
f0100af8:	0f 85 f9 fe ff ff    	jne    f01009f7 <check_page_free_list+0xca>
			++nfree_basemem;
		else
			++nfree_extmem;
	}

	assert(nfree_basemem > 0);
f0100afe:	85 ff                	test   %edi,%edi
f0100b00:	75 14                	jne    f0100b16 <check_page_free_list+0x1e9>
f0100b02:	68 7a 36 10 f0       	push   $0xf010367a
f0100b07:	68 73 35 10 f0       	push   $0xf0103573
f0100b0c:	68 54 02 00 00       	push   $0x254
f0100b11:	e9 f9 fe ff ff       	jmp    f0100a0f <check_page_free_list+0xe2>
	assert(nfree_extmem > 0);
f0100b16:	85 f6                	test   %esi,%esi
f0100b18:	75 14                	jne    f0100b2e <check_page_free_list+0x201>
f0100b1a:	68 8c 36 10 f0       	push   $0xf010368c
f0100b1f:	68 73 35 10 f0       	push   $0xf0103573
f0100b24:	68 55 02 00 00       	push   $0x255
f0100b29:	e9 e1 fe ff ff       	jmp    f0100a0f <check_page_free_list+0xe2>
	cprintf("check_page_free_list() succeeded!\n");
f0100b2e:	83 ec 0c             	sub    $0xc,%esp
f0100b31:	68 9d 36 10 f0       	push   $0xf010369d
f0100b36:	e8 03 fd ff ff       	call   f010083e <cprintf>
}
f0100b3b:	83 c4 2c             	add    $0x2c,%esp
f0100b3e:	5b                   	pop    %ebx
f0100b3f:	5e                   	pop    %esi
f0100b40:	5f                   	pop    %edi
f0100b41:	5d                   	pop    %ebp
f0100b42:	c3                   	ret    

f0100b43 <nvram_read>:
// Detect machine's physical memory setup.
// --------------------------------------------------------------

static int
nvram_read(int r)
{
f0100b43:	56                   	push   %esi
f0100b44:	53                   	push   %ebx
f0100b45:	89 c3                	mov    %eax,%ebx
f0100b47:	83 ec 10             	sub    $0x10,%esp
	return mc146818_read(r) | (mc146818_read(r + 1) << 8);
f0100b4a:	43                   	inc    %ebx
f0100b4b:	50                   	push   %eax
f0100b4c:	e8 e7 13 00 00       	call   f0101f38 <mc146818_read>
f0100b51:	89 1c 24             	mov    %ebx,(%esp)
f0100b54:	89 c6                	mov    %eax,%esi
f0100b56:	e8 dd 13 00 00       	call   f0101f38 <mc146818_read>
}
f0100b5b:	83 c4 14             	add    $0x14,%esp
f0100b5e:	5b                   	pop    %ebx
// --------------------------------------------------------------

static int
nvram_read(int r)
{
	return mc146818_read(r) | (mc146818_read(r + 1) << 8);
f0100b5f:	c1 e0 08             	shl    $0x8,%eax
f0100b62:	09 f0                	or     %esi,%eax
}
f0100b64:	5e                   	pop    %esi
f0100b65:	c3                   	ret    

f0100b66 <_paddr.clone.0>:
 * non-kernel virtual address.
 */
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
f0100b66:	83 ec 0c             	sub    $0xc,%esp
{
	if ((uint32_t)kva < KERNBASE)
f0100b69:	81 fa ff ff ff ef    	cmp    $0xefffffff,%edx
f0100b6f:	77 11                	ja     f0100b82 <_paddr.clone.0+0x1c>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0100b71:	52                   	push   %edx
f0100b72:	68 c0 36 10 f0       	push   $0xf01036c0
f0100b77:	50                   	push   %eax
f0100b78:	68 36 35 10 f0       	push   $0xf0103536
f0100b7d:	e8 32 13 00 00       	call   f0101eb4 <_panic>
	return (physaddr_t)kva - KERNBASE;
f0100b82:	8d 82 00 00 00 10    	lea    0x10000000(%edx),%eax
}
f0100b88:	83 c4 0c             	add    $0xc,%esp
f0100b8b:	c3                   	ret    

f0100b8c <page_init>:
// allocator functions below to allocate and deallocate physical
// memory via the page_free_list.
//
void
page_init(void)
{
f0100b8c:	56                   	push   %esi
	// NB: DO NOT actually touch the physical memory corresponding to
	// free pages!
	
    /* TODO */
    size_t i;
	for (i = 0; i < npages; i++) {
f0100b8d:	31 f6                	xor    %esi,%esi
// allocator functions below to allocate and deallocate physical
// memory via the page_free_list.
//
void
page_init(void)
{
f0100b8f:	53                   	push   %ebx
	// NB: DO NOT actually touch the physical memory corresponding to
	// free pages!
	
    /* TODO */
    size_t i;
	for (i = 0; i < npages; i++) {
f0100b90:	31 db                	xor    %ebx,%ebx
f0100b92:	e9 82 00 00 00       	jmp    f0100c19 <page_init+0x8d>
        if(i ==0)
f0100b97:	85 db                	test   %ebx,%ebx
f0100b99:	75 11                	jne    f0100bac <page_init+0x20>
        {
            pages[i].pp_ref = 1; //from the hint tell us the 0 page is taken
f0100b9b:	a1 4c 0e 11 f0       	mov    0xf0110e4c,%eax
f0100ba0:	66 c7 40 04 01 00    	movw   $0x1,0x4(%eax)
            pages[i].pp_link=NULL;
f0100ba6:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
        }
        if(i<npages_basemem)
f0100bac:	3b 1d 20 02 11 f0    	cmp    0xf0110220,%ebx
f0100bb2:	73 1a                	jae    f0100bce <page_init+0x42>
        {
            pages[i].pp_ref = 0;//free
f0100bb4:	a1 4c 0e 11 f0       	mov    0xf0110e4c,%eax
            pages[i].pp_link = page_free_list;
f0100bb9:	8b 15 1c 02 11 f0    	mov    0xf011021c,%edx
            pages[i].pp_ref = 1; //from the hint tell us the 0 page is taken
            pages[i].pp_link=NULL;
        }
        if(i<npages_basemem)
        {
            pages[i].pp_ref = 0;//free
f0100bbf:	01 f0                	add    %esi,%eax
f0100bc1:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)
            pages[i].pp_link = page_free_list;
f0100bc7:	89 10                	mov    %edx,(%eax)
            page_free_list = &pages[i];
f0100bc9:	a3 1c 02 11 f0       	mov    %eax,0xf011021c
        }
        //(ext-io)/pg is number of io , the other is number of part of ext(kernel)
        if(i < ((EXTPHYSMEM-IOPHYSMEM)/PGSIZE) || i < ((uint32_t)boot_alloc(0)- KERNBASE)/PGSIZE)
f0100bce:	83 fb 5f             	cmp    $0x5f,%ebx
f0100bd1:	76 13                	jbe    f0100be6 <page_init+0x5a>
f0100bd3:	31 c0                	xor    %eax,%eax
f0100bd5:	e8 8b fc ff ff       	call   f0100865 <boot_alloc>
f0100bda:	05 00 00 00 10       	add    $0x10000000,%eax
f0100bdf:	c1 e8 0c             	shr    $0xc,%eax
f0100be2:	39 c3                	cmp    %eax,%ebx
f0100be4:	73 15                	jae    f0100bfb <page_init+0x6f>
        {
            pages[i].pp_ref = 1; //from the hint tell us the 0 page is taken
f0100be6:	a1 4c 0e 11 f0       	mov    0xf0110e4c,%eax
f0100beb:	01 f0                	add    %esi,%eax
f0100bed:	66 c7 40 04 01 00    	movw   $0x1,0x4(%eax)
            pages[i].pp_link=NULL;
f0100bf3:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
f0100bf9:	eb 1a                	jmp    f0100c15 <page_init+0x89>
        }
        else
        {
            pages[i].pp_ref = 0;
f0100bfb:	a1 4c 0e 11 f0       	mov    0xf0110e4c,%eax
            pages[i].pp_link = page_free_list;
f0100c00:	8b 15 1c 02 11 f0    	mov    0xf011021c,%edx
            pages[i].pp_ref = 1; //from the hint tell us the 0 page is taken
            pages[i].pp_link=NULL;
        }
        else
        {
            pages[i].pp_ref = 0;
f0100c06:	01 f0                	add    %esi,%eax
f0100c08:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)
            pages[i].pp_link = page_free_list;
f0100c0e:	89 10                	mov    %edx,(%eax)
            page_free_list = &pages[i];
f0100c10:	a3 1c 02 11 f0       	mov    %eax,0xf011021c
	// NB: DO NOT actually touch the physical memory corresponding to
	// free pages!
	
    /* TODO */
    size_t i;
	for (i = 0; i < npages; i++) {
f0100c15:	43                   	inc    %ebx
f0100c16:	83 c6 08             	add    $0x8,%esi
f0100c19:	3b 1d 44 0e 11 f0    	cmp    0xf0110e44,%ebx
f0100c1f:	0f 82 72 ff ff ff    	jb     f0100b97 <page_init+0xb>
            pages[i].pp_ref = 0;
            pages[i].pp_link = page_free_list;
            page_free_list = &pages[i];
        }
    }
}
f0100c25:	5b                   	pop    %ebx
f0100c26:	5e                   	pop    %esi
f0100c27:	c3                   	ret    

f0100c28 <page_alloc>:
// Returns NULL if out of free memory.
//
// Hint: use page2kva and memset
struct PageInfo *
page_alloc(int alloc_flags)
{
f0100c28:	53                   	push   %ebx
f0100c29:	83 ec 08             	sub    $0x8,%esp
    /* TODO */
    if(!page_free_list)
f0100c2c:	8b 1d 1c 02 11 f0    	mov    0xf011021c,%ebx
f0100c32:	85 db                	test   %ebx,%ebx
f0100c34:	74 2c                	je     f0100c62 <page_alloc+0x3a>
        return NULL;
    struct PageInfo *newpage;
    newpage = page_free_list;
    page_free_list = newpage->pp_link;
f0100c36:	8b 03                	mov    (%ebx),%eax
    newpage->pp_link = NULL;
    //get the page and let the link to next page


    if(alloc_flags & ALLOC_ZERO)
f0100c38:	f6 44 24 10 01       	testb  $0x1,0x10(%esp)
    if(!page_free_list)
        return NULL;
    struct PageInfo *newpage;
    newpage = page_free_list;
    page_free_list = newpage->pp_link;
    newpage->pp_link = NULL;
f0100c3d:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
    /* TODO */
    if(!page_free_list)
        return NULL;
    struct PageInfo *newpage;
    newpage = page_free_list;
    page_free_list = newpage->pp_link;
f0100c43:	a3 1c 02 11 f0       	mov    %eax,0xf011021c
    newpage->pp_link = NULL;
    //get the page and let the link to next page


    if(alloc_flags & ALLOC_ZERO)
f0100c48:	74 18                	je     f0100c62 <page_alloc+0x3a>
         memset(page2kva(newpage),'\0',PGSIZE);
f0100c4a:	89 d8                	mov    %ebx,%eax
f0100c4c:	e8 78 fc ff ff       	call   f01008c9 <page2kva>
f0100c51:	52                   	push   %edx
f0100c52:	68 00 10 00 00       	push   $0x1000
f0100c57:	6a 00                	push   $0x0
f0100c59:	50                   	push   %eax
f0100c5a:	e8 60 1e 00 00       	call   f0102abf <memset>
f0100c5f:	83 c4 10             	add    $0x10,%esp
         return newpage;
}
f0100c62:	89 d8                	mov    %ebx,%eax
f0100c64:	83 c4 08             	add    $0x8,%esp
f0100c67:	5b                   	pop    %ebx
f0100c68:	c3                   	ret    

f0100c69 <page_free>:
// Return a page to the free list.
// (This function should only be called when pp->pp_ref reaches 0.)
//
void
page_free(struct PageInfo *pp)
{
f0100c69:	83 ec 0c             	sub    $0xc,%esp
f0100c6c:	8b 44 24 10          	mov    0x10(%esp),%eax
	// Fill this function in
	// Hint: You may want to panic if pp->pp_ref is nonzero or
	// pp->pp_link is not NULL.
    /* TODO */
    if(pp->pp_link != NULL || pp->pp_ref != 0)
f0100c70:	83 38 00             	cmpl   $0x0,(%eax)
f0100c73:	75 07                	jne    f0100c7c <page_free+0x13>
f0100c75:	66 83 78 04 00       	cmpw   $0x0,0x4(%eax)
f0100c7a:	74 15                	je     f0100c91 <page_free+0x28>
    {
        panic("the page can't return free");
f0100c7c:	51                   	push   %ecx
f0100c7d:	68 e4 36 10 f0       	push   $0xf01036e4
f0100c82:	68 50 01 00 00       	push   $0x150
f0100c87:	68 36 35 10 f0       	push   $0xf0103536
f0100c8c:	e8 23 12 00 00       	call   f0101eb4 <_panic>
        return;
    }   
    pp->pp_link = page_free_list;
f0100c91:	8b 15 1c 02 11 f0    	mov    0xf011021c,%edx
    page_free_list = pp;
f0100c97:	a3 1c 02 11 f0       	mov    %eax,0xf011021c
    if(pp->pp_link != NULL || pp->pp_ref != 0)
    {
        panic("the page can't return free");
        return;
    }   
    pp->pp_link = page_free_list;
f0100c9c:	89 10                	mov    %edx,(%eax)
    page_free_list = pp;
}
f0100c9e:	83 c4 0c             	add    $0xc,%esp
f0100ca1:	c3                   	ret    

f0100ca2 <page_decref>:
// Decrement the reference count on a page,
// freeing it if there are no more refs.
//
void
page_decref(struct PageInfo* pp)
{
f0100ca2:	83 ec 0c             	sub    $0xc,%esp
f0100ca5:	8b 44 24 10          	mov    0x10(%esp),%eax
	if (--pp->pp_ref == 0)
f0100ca9:	8b 50 04             	mov    0x4(%eax),%edx
f0100cac:	4a                   	dec    %edx
f0100cad:	66 85 d2             	test   %dx,%dx
f0100cb0:	66 89 50 04          	mov    %dx,0x4(%eax)
f0100cb4:	75 08                	jne    f0100cbe <page_decref+0x1c>
		page_free(pp);
}
f0100cb6:	83 c4 0c             	add    $0xc,%esp
//
void
page_decref(struct PageInfo* pp)
{
	if (--pp->pp_ref == 0)
		page_free(pp);
f0100cb9:	e9 ab ff ff ff       	jmp    f0100c69 <page_free>
}
f0100cbe:	83 c4 0c             	add    $0xc,%esp
f0100cc1:	c3                   	ret    

f0100cc2 <pgdir_walk>:
//
//check a va which have pte?if has ,return it
//if no we create
pte_t *
pgdir_walk(pde_t *pgdir, const void *va, int create)
{
f0100cc2:	57                   	push   %edi
f0100cc3:	56                   	push   %esi
f0100cc4:	53                   	push   %ebx
f0100cc5:	8b 5c 24 14          	mov    0x14(%esp),%ebx
	// Fill this function in
    /* TODO */
    int pagedir_index = PDX(va);
f0100cc9:	89 de                	mov    %ebx,%esi
f0100ccb:	c1 ee 16             	shr    $0x16,%esi
    int pagetable_index = PTX(va);
    //chech the page table entry which is in memory?

    if(!(pgdir[pagedir_index] & PTE_P)){//check the page table(the offset if padir) that can present(inc/mmu.h)
f0100cce:	c1 e6 02             	shl    $0x2,%esi
f0100cd1:	03 74 24 10          	add    0x10(%esp),%esi
f0100cd5:	8b 3e                	mov    (%esi),%edi
f0100cd7:	83 e7 01             	and    $0x1,%edi
f0100cda:	75 2a                	jne    f0100d06 <pgdir_walk+0x44>
                return NULL;//return false
            page->pp_ref++;
            pgdir[pagedir_index] =( page2pa(page) | PTE_P | PTE_U | PTE_W); //present read/write user/kernel can use , all OR with page2pa
        }
        else 
            return NULL;
f0100cdc:	31 d2                	xor    %edx,%edx
    int pagedir_index = PDX(va);
    int pagetable_index = PTX(va);
    //chech the page table entry which is in memory?

    if(!(pgdir[pagedir_index] & PTE_P)){//check the page table(the offset if padir) that can present(inc/mmu.h)
        if(create){
f0100cde:	83 7c 24 18 00       	cmpl   $0x0,0x18(%esp)
f0100ce3:	74 44                	je     f0100d29 <pgdir_walk+0x67>
            struct PageInfo *page = page_alloc(ALLOC_ZERO);//a zero page
f0100ce5:	83 ec 0c             	sub    $0xc,%esp
f0100ce8:	6a 01                	push   $0x1
f0100cea:	e8 39 ff ff ff       	call   f0100c28 <page_alloc>
            if(!page)
f0100cef:	83 c4 10             	add    $0x10,%esp
                return NULL;//return false
f0100cf2:	89 fa                	mov    %edi,%edx
    //chech the page table entry which is in memory?

    if(!(pgdir[pagedir_index] & PTE_P)){//check the page table(the offset if padir) that can present(inc/mmu.h)
        if(create){
            struct PageInfo *page = page_alloc(ALLOC_ZERO);//a zero page
            if(!page)
f0100cf4:	85 c0                	test   %eax,%eax
f0100cf6:	74 31                	je     f0100d29 <pgdir_walk+0x67>
                return NULL;//return false
            page->pp_ref++;
f0100cf8:	66 ff 40 04          	incw   0x4(%eax)
            pgdir[pagedir_index] =( page2pa(page) | PTE_P | PTE_U | PTE_W); //present read/write user/kernel can use , all OR with page2pa
f0100cfc:	e8 57 fb ff ff       	call   f0100858 <page2pa>
f0100d01:	83 c8 07             	or     $0x7,%eax
f0100d04:	89 06                	mov    %eax,(%esi)
        }
        else 
            return NULL;
    }
    pte_t *result;
    result = KADDR(PTE_ADDR(pgdir[pagedir_index]));//PTE_ADDR , the address of page table or dir,inc/mmu.h,KADDR is phy addr to kernel viruial addr , kernel/mem.h
f0100d06:	8b 0e                	mov    (%esi),%ecx
f0100d08:	ba 91 01 00 00       	mov    $0x191,%edx
f0100d0d:	b8 36 35 10 f0       	mov    $0xf0103536,%eax
pgdir_walk(pde_t *pgdir, const void *va, int create)
{
	// Fill this function in
    /* TODO */
    int pagedir_index = PDX(va);
    int pagetable_index = PTX(va);
f0100d12:	c1 eb 0a             	shr    $0xa,%ebx
        else 
            return NULL;
    }
    pte_t *result;
    result = KADDR(PTE_ADDR(pgdir[pagedir_index]));//PTE_ADDR , the address of page table or dir,inc/mmu.h,KADDR is phy addr to kernel viruial addr , kernel/mem.h
    return &result[pagetable_index];
f0100d15:	81 e3 fc 0f 00 00    	and    $0xffc,%ebx
        }
        else 
            return NULL;
    }
    pte_t *result;
    result = KADDR(PTE_ADDR(pgdir[pagedir_index]));//PTE_ADDR , the address of page table or dir,inc/mmu.h,KADDR is phy addr to kernel viruial addr , kernel/mem.h
f0100d1b:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
f0100d21:	e8 7a fb ff ff       	call   f01008a0 <_kaddr>
    return &result[pagetable_index];
f0100d26:	8d 14 18             	lea    (%eax,%ebx,1),%edx
}
f0100d29:	89 d0                	mov    %edx,%eax
f0100d2b:	5b                   	pop    %ebx
f0100d2c:	5e                   	pop    %esi
f0100d2d:	5f                   	pop    %edi
f0100d2e:	c3                   	ret    

f0100d2f <boot_map_region>:
// mapped pages.
//
// Hint: the TA solution uses pgdir_walk
static void
boot_map_region(pde_t *pgdir, uintptr_t va, size_t size, physaddr_t pa, int perm)//perm means permission
{
f0100d2f:	55                   	push   %ebp
f0100d30:	89 cd                	mov    %ecx,%ebp
f0100d32:	57                   	push   %edi
    /* TODO */
    pte_t *pte;
    int i;
    for (i = 0; i < size/PGSIZE; i++)
f0100d33:	31 ff                	xor    %edi,%edi
// mapped pages.
//
// Hint: the TA solution uses pgdir_walk
static void
boot_map_region(pde_t *pgdir, uintptr_t va, size_t size, physaddr_t pa, int perm)//perm means permission
{
f0100d35:	56                   	push   %esi
f0100d36:	89 d6                	mov    %edx,%esi
f0100d38:	53                   	push   %ebx
f0100d39:	89 c3                	mov    %eax,%ebx
f0100d3b:	83 ec 0c             	sub    $0xc,%esp
    /* TODO */
    pte_t *pte;
    int i;
    for (i = 0; i < size/PGSIZE; i++)
f0100d3e:	c1 ed 0c             	shr    $0xc,%ebp
    {
        pte = pgdir_walk(pgdir,(void*)va,1);//1 mean create 
        *pte = (pa | perm | PTE_P);
f0100d41:	83 4c 24 24 01       	orl    $0x1,0x24(%esp)
boot_map_region(pde_t *pgdir, uintptr_t va, size_t size, physaddr_t pa, int perm)//perm means permission
{
    /* TODO */
    pte_t *pte;
    int i;
    for (i = 0; i < size/PGSIZE; i++)
f0100d46:	eb 26                	jmp    f0100d6e <boot_map_region+0x3f>
    {
        pte = pgdir_walk(pgdir,(void*)va,1);//1 mean create 
f0100d48:	50                   	push   %eax
boot_map_region(pde_t *pgdir, uintptr_t va, size_t size, physaddr_t pa, int perm)//perm means permission
{
    /* TODO */
    pte_t *pte;
    int i;
    for (i = 0; i < size/PGSIZE; i++)
f0100d49:	47                   	inc    %edi
    {
        pte = pgdir_walk(pgdir,(void*)va,1);//1 mean create 
f0100d4a:	6a 01                	push   $0x1
f0100d4c:	56                   	push   %esi
        *pte = (pa | perm | PTE_P);
        pa += PGSIZE;
        va += PGSIZE;
f0100d4d:	81 c6 00 10 00 00    	add    $0x1000,%esi
    /* TODO */
    pte_t *pte;
    int i;
    for (i = 0; i < size/PGSIZE; i++)
    {
        pte = pgdir_walk(pgdir,(void*)va,1);//1 mean create 
f0100d53:	53                   	push   %ebx
f0100d54:	e8 69 ff ff ff       	call   f0100cc2 <pgdir_walk>
        *pte = (pa | perm | PTE_P);
f0100d59:	8b 54 24 34          	mov    0x34(%esp),%edx
f0100d5d:	0b 54 24 30          	or     0x30(%esp),%edx
f0100d61:	89 10                	mov    %edx,(%eax)
        pa += PGSIZE;
f0100d63:	81 44 24 30 00 10 00 	addl   $0x1000,0x30(%esp)
f0100d6a:	00 
boot_map_region(pde_t *pgdir, uintptr_t va, size_t size, physaddr_t pa, int perm)//perm means permission
{
    /* TODO */
    pte_t *pte;
    int i;
    for (i = 0; i < size/PGSIZE; i++)
f0100d6b:	83 c4 10             	add    $0x10,%esp
f0100d6e:	39 ef                	cmp    %ebp,%edi
f0100d70:	72 d6                	jb     f0100d48 <boot_map_region+0x19>
        *pte = (pa | perm | PTE_P);
        pa += PGSIZE;
        va += PGSIZE;
    }
    
}
f0100d72:	83 c4 0c             	add    $0xc,%esp
f0100d75:	5b                   	pop    %ebx
f0100d76:	5e                   	pop    %esi
f0100d77:	5f                   	pop    %edi
f0100d78:	5d                   	pop    %ebp
f0100d79:	c3                   	ret    

f0100d7a <page_lookup>:
//
// Hint: the TA solution uses pgdir_walk and pa2page.
//
struct PageInfo *
page_lookup(pde_t *pgdir, void *va, pte_t **pte_store)
{
f0100d7a:	53                   	push   %ebx
f0100d7b:	83 ec 0c             	sub    $0xc,%esp
f0100d7e:	8b 5c 24 1c          	mov    0x1c(%esp),%ebx
    /* TODO */
    pte_t *pte=pgdir_walk(pgdir,(void *)va,0);
f0100d82:	6a 00                	push   $0x0
f0100d84:	ff 74 24 1c          	pushl  0x1c(%esp)
f0100d88:	ff 74 24 1c          	pushl  0x1c(%esp)
f0100d8c:	e8 31 ff ff ff       	call   f0100cc2 <pgdir_walk>
    if(pte==NULL)
f0100d91:	83 c4 10             	add    $0x10,%esp
//
struct PageInfo *
page_lookup(pde_t *pgdir, void *va, pte_t **pte_store)
{
    /* TODO */
    pte_t *pte=pgdir_walk(pgdir,(void *)va,0);
f0100d94:	89 c2                	mov    %eax,%edx
    if(pte==NULL)
        return NULL;
f0100d96:	31 c0                	xor    %eax,%eax
struct PageInfo *
page_lookup(pde_t *pgdir, void *va, pte_t **pte_store)
{
    /* TODO */
    pte_t *pte=pgdir_walk(pgdir,(void *)va,0);
    if(pte==NULL)
f0100d98:	85 d2                	test   %edx,%edx
f0100d9a:	74 35                	je     f0100dd1 <page_lookup+0x57>
        return NULL;
    if(!(*pte & PTE_P))
f0100d9c:	8b 0a                	mov    (%edx),%ecx
f0100d9e:	f6 c1 01             	test   $0x1,%cl
f0100da1:	74 2e                	je     f0100dd1 <page_lookup+0x57>
        return NULL;
    if(pte_store)
f0100da3:	85 db                	test   %ebx,%ebx
f0100da5:	74 02                	je     f0100da9 <page_lookup+0x2f>
        *pte_store = pte;//if pte_store is not zero ,then put the pde to the pte_store
f0100da7:	89 13                	mov    %edx,(%ebx)
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100da9:	89 c8                	mov    %ecx,%eax
f0100dab:	c1 e8 0c             	shr    $0xc,%eax
f0100dae:	3b 05 44 0e 11 f0    	cmp    0xf0110e44,%eax
f0100db4:	72 12                	jb     f0100dc8 <page_lookup+0x4e>
		panic("pa2page called with invalid pa");
f0100db6:	52                   	push   %edx
f0100db7:	68 ff 36 10 f0       	push   $0xf01036ff
f0100dbc:	6a 46                	push   $0x46
f0100dbe:	68 27 35 10 f0       	push   $0xf0103527
f0100dc3:	e8 ec 10 00 00       	call   f0101eb4 <_panic>
	return &pages[PGNUM(pa)];
f0100dc8:	c1 e0 03             	shl    $0x3,%eax
f0100dcb:	03 05 4c 0e 11 f0    	add    0xf0110e4c,%eax
    return pa2page(PTE_ADDR(*pte));
}
f0100dd1:	83 c4 08             	add    $0x8,%esp
f0100dd4:	5b                   	pop    %ebx
f0100dd5:	c3                   	ret    

f0100dd6 <page_remove>:
// Hint: The TA solution is implemented using page_lookup,
// 	tlb_invalidate, and page_decref.
//
void
page_remove(pde_t *pgdir, void *va)
{
f0100dd6:	53                   	push   %ebx
f0100dd7:	83 ec 1c             	sub    $0x1c,%esp
f0100dda:	8b 5c 24 28          	mov    0x28(%esp),%ebx
    /* TODO */
    pte_t *pte;
    struct PageInfo *page = page_lookup(pgdir,(void *)va,&pte);
f0100dde:	8d 44 24 10          	lea    0x10(%esp),%eax
f0100de2:	50                   	push   %eax
f0100de3:	53                   	push   %ebx
f0100de4:	ff 74 24 2c          	pushl  0x2c(%esp)
f0100de8:	e8 8d ff ff ff       	call   f0100d7a <page_lookup>
    if(page == NULL)
f0100ded:	83 c4 10             	add    $0x10,%esp
f0100df0:	85 c0                	test   %eax,%eax
f0100df2:	74 19                	je     f0100e0d <page_remove+0x37>
        return NULL;
    page_decref(page);
f0100df4:	83 ec 0c             	sub    $0xc,%esp
f0100df7:	50                   	push   %eax
f0100df8:	e8 a5 fe ff ff       	call   f0100ca2 <page_decref>
    *pte = 0;//the page table entry set to 0
f0100dfd:	8b 44 24 1c          	mov    0x1c(%esp),%eax
f0100e01:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
}

static __inline void
invlpg(void *addr)
{
	__asm __volatile("invlpg (%0)" : : "r" (addr) : "memory");
f0100e07:	0f 01 3b             	invlpg (%ebx)
f0100e0a:	83 c4 10             	add    $0x10,%esp
    tlb_invalidate(pgdir, va);
}
f0100e0d:	83 c4 18             	add    $0x18,%esp
f0100e10:	5b                   	pop    %ebx
f0100e11:	c3                   	ret    

f0100e12 <page_insert>:
// Hint: The TA solution is implemented using pgdir_walk, page_remove,
// and page2pa.
//
int
page_insert(pde_t *pgdir, struct PageInfo *pp, void *va, int perm)
{
f0100e12:	55                   	push   %ebp
f0100e13:	57                   	push   %edi
f0100e14:	56                   	push   %esi
f0100e15:	53                   	push   %ebx
f0100e16:	83 ec 10             	sub    $0x10,%esp
f0100e19:	8b 6c 24 2c          	mov    0x2c(%esp),%ebp
f0100e1d:	8b 7c 24 24          	mov    0x24(%esp),%edi
f0100e21:	8b 74 24 28          	mov    0x28(%esp),%esi
    /* TODO */
    pte_t *pte = pgdir_walk(pgdir,(void *)va,1);
f0100e25:	6a 01                	push   $0x1
f0100e27:	55                   	push   %ebp
f0100e28:	57                   	push   %edi
f0100e29:	e8 94 fe ff ff       	call   f0100cc2 <pgdir_walk>
    if(pte==NULL)
f0100e2e:	83 c4 10             	add    $0x10,%esp
//
int
page_insert(pde_t *pgdir, struct PageInfo *pp, void *va, int perm)
{
    /* TODO */
    pte_t *pte = pgdir_walk(pgdir,(void *)va,1);
f0100e31:	89 c3                	mov    %eax,%ebx
    if(pte==NULL)
        return -E_NO_MEM;
f0100e33:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
int
page_insert(pde_t *pgdir, struct PageInfo *pp, void *va, int perm)
{
    /* TODO */
    pte_t *pte = pgdir_walk(pgdir,(void *)va,1);
    if(pte==NULL)
f0100e38:	85 db                	test   %ebx,%ebx
f0100e3a:	74 29                	je     f0100e65 <page_insert+0x53>
        return -E_NO_MEM;
    pp->pp_ref++;
f0100e3c:	66 ff 46 04          	incw   0x4(%esi)
    if(*pte & PTE_P)
f0100e40:	f6 03 01             	testb  $0x1,(%ebx)
f0100e43:	74 0c                	je     f0100e51 <page_insert+0x3f>
        page_remove(pgdir,va);
f0100e45:	51                   	push   %ecx
f0100e46:	51                   	push   %ecx
f0100e47:	55                   	push   %ebp
f0100e48:	57                   	push   %edi
f0100e49:	e8 88 ff ff ff       	call   f0100dd6 <page_remove>
f0100e4e:	83 c4 10             	add    $0x10,%esp
    *pte = page2pa(pp) | perm | PTE_P;
f0100e51:	89 f0                	mov    %esi,%eax
f0100e53:	e8 00 fa ff ff       	call   f0100858 <page2pa>
f0100e58:	8b 54 24 2c          	mov    0x2c(%esp),%edx
f0100e5c:	83 ca 01             	or     $0x1,%edx
f0100e5f:	09 c2                	or     %eax,%edx
    return 0;
f0100e61:	31 c0                	xor    %eax,%eax
    if(pte==NULL)
        return -E_NO_MEM;
    pp->pp_ref++;
    if(*pte & PTE_P)
        page_remove(pgdir,va);
    *pte = page2pa(pp) | perm | PTE_P;
f0100e63:	89 13                	mov    %edx,(%ebx)
    return 0;
}
f0100e65:	83 c4 0c             	add    $0xc,%esp
f0100e68:	5b                   	pop    %ebx
f0100e69:	5e                   	pop    %esi
f0100e6a:	5f                   	pop    %edi
f0100e6b:	5d                   	pop    %ebp
f0100e6c:	c3                   	ret    

f0100e6d <mem_init>:
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
{
f0100e6d:	55                   	push   %ebp
{
	size_t npages_extmem;

	// Use CMOS calls to measure available base & extended memory.
	// (CMOS calls return results in kilobytes.)
	npages_basemem = (nvram_read(NVRAM_BASELO) * 1024) / PGSIZE;
f0100e6e:	b8 15 00 00 00       	mov    $0x15,%eax
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
{
f0100e73:	57                   	push   %edi
f0100e74:	56                   	push   %esi
f0100e75:	53                   	push   %ebx
{
	size_t npages_extmem;

	// Use CMOS calls to measure available base & extended memory.
	// (CMOS calls return results in kilobytes.)
	npages_basemem = (nvram_read(NVRAM_BASELO) * 1024) / PGSIZE;
f0100e76:	bb 04 00 00 00       	mov    $0x4,%ebx
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
{
f0100e7b:	83 ec 2c             	sub    $0x2c,%esp
	uint32_t cr0;
    nextfree = 0;
f0100e7e:	c7 05 24 02 11 f0 00 	movl   $0x0,0xf0110224
f0100e85:	00 00 00 
    page_free_list = 0;
f0100e88:	c7 05 1c 02 11 f0 00 	movl   $0x0,0xf011021c
f0100e8f:	00 00 00 
{
	size_t npages_extmem;

	// Use CMOS calls to measure available base & extended memory.
	// (CMOS calls return results in kilobytes.)
	npages_basemem = (nvram_read(NVRAM_BASELO) * 1024) / PGSIZE;
f0100e92:	e8 ac fc ff ff       	call   f0100b43 <nvram_read>
f0100e97:	99                   	cltd   
f0100e98:	f7 fb                	idiv   %ebx
f0100e9a:	a3 20 02 11 f0       	mov    %eax,0xf0110220
	npages_extmem = (nvram_read(NVRAM_EXTLO) * 1024) / PGSIZE;
f0100e9f:	b8 17 00 00 00       	mov    $0x17,%eax
f0100ea4:	e8 9a fc ff ff       	call   f0100b43 <nvram_read>
f0100ea9:	99                   	cltd   
f0100eaa:	f7 fb                	idiv   %ebx

	// Calculate the number of physical pages available in both base
	// and extended memory.
	if (npages_extmem)
f0100eac:	85 c0                	test   %eax,%eax
		npages = (EXTPHYSMEM / PGSIZE) + npages_extmem;
f0100eae:	8d 90 00 01 00 00    	lea    0x100(%eax),%edx
	npages_basemem = (nvram_read(NVRAM_BASELO) * 1024) / PGSIZE;
	npages_extmem = (nvram_read(NVRAM_EXTLO) * 1024) / PGSIZE;

	// Calculate the number of physical pages available in both base
	// and extended memory.
	if (npages_extmem)
f0100eb4:	75 06                	jne    f0100ebc <mem_init+0x4f>
		npages = (EXTPHYSMEM / PGSIZE) + npages_extmem;
	else
		npages = npages_basemem;
f0100eb6:	8b 15 20 02 11 f0    	mov    0xf0110220,%edx

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
		npages * PGSIZE / 1024,
		npages_basemem * PGSIZE / 1024,
		npages_extmem * PGSIZE / 1024);
f0100ebc:	c1 e0 0c             	shl    $0xc,%eax
	if (npages_extmem)
		npages = (EXTPHYSMEM / PGSIZE) + npages_extmem;
	else
		npages = npages_basemem;

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f0100ebf:	c1 e8 0a             	shr    $0xa,%eax
f0100ec2:	50                   	push   %eax
		npages * PGSIZE / 1024,
		npages_basemem * PGSIZE / 1024,
f0100ec3:	a1 20 02 11 f0       	mov    0xf0110220,%eax
	// Calculate the number of physical pages available in both base
	// and extended memory.
	if (npages_extmem)
		npages = (EXTPHYSMEM / PGSIZE) + npages_extmem;
	else
		npages = npages_basemem;
f0100ec8:	89 15 44 0e 11 f0    	mov    %edx,0xf0110e44

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
		npages * PGSIZE / 1024,
		npages_basemem * PGSIZE / 1024,
f0100ece:	c1 e0 0c             	shl    $0xc,%eax
	if (npages_extmem)
		npages = (EXTPHYSMEM / PGSIZE) + npages_extmem;
	else
		npages = npages_basemem;

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f0100ed1:	c1 e8 0a             	shr    $0xa,%eax
f0100ed4:	50                   	push   %eax
		npages * PGSIZE / 1024,
f0100ed5:	a1 44 0e 11 f0       	mov    0xf0110e44,%eax
f0100eda:	c1 e0 0c             	shl    $0xc,%eax
	if (npages_extmem)
		npages = (EXTPHYSMEM / PGSIZE) + npages_extmem;
	else
		npages = npages_basemem;

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f0100edd:	c1 e8 0a             	shr    $0xa,%eax
f0100ee0:	50                   	push   %eax
f0100ee1:	68 1e 37 10 f0       	push   $0xf010371e
f0100ee6:	e8 53 f9 ff ff       	call   f010083e <cprintf>
	// Find out how much memory the machine has (npages & npages_basemem).
	i386_detect_memory();//get the number of membase page(can be used) ,io hole page(not) ,extmem page(ok)

	//////////////////////////////////////////////////////////////////////
	//!!! create initial page directory.
	kern_pgdir = (pde_t *) boot_alloc(PGSIZE);//in inc/mmu.h PGSIZE is 4096b = 4KB
f0100eeb:	b8 00 10 00 00       	mov    $0x1000,%eax
f0100ef0:	e8 70 f9 ff ff       	call   f0100865 <boot_alloc>
	memset(kern_pgdir, 0, PGSIZE);//memset(start addr , content, size)
f0100ef5:	83 c4 0c             	add    $0xc,%esp
f0100ef8:	68 00 10 00 00       	push   $0x1000
f0100efd:	6a 00                	push   $0x0
f0100eff:	50                   	push   %eax
	// Find out how much memory the machine has (npages & npages_basemem).
	i386_detect_memory();//get the number of membase page(can be used) ,io hole page(not) ,extmem page(ok)

	//////////////////////////////////////////////////////////////////////
	//!!! create initial page directory.
	kern_pgdir = (pde_t *) boot_alloc(PGSIZE);//in inc/mmu.h PGSIZE is 4096b = 4KB
f0100f00:	a3 48 0e 11 f0       	mov    %eax,0xf0110e48
	memset(kern_pgdir, 0, PGSIZE);//memset(start addr , content, size)
f0100f05:	e8 b5 1b 00 00       	call   f0102abf <memset>
	// (For now, you don't have understand the greater purpose of the
	// following line.)

	// Permissions: kernel R, user R
    // UVPT is a virtual address in memlayout.h , the address is map to the kern_pgdir(physcial addr)
	kern_pgdir[PDX(UVPT)] = PADDR(kern_pgdir) | PTE_U | PTE_P;
f0100f0a:	8b 1d 48 0e 11 f0    	mov    0xf0110e48,%ebx
f0100f10:	b8 8f 00 00 00       	mov    $0x8f,%eax
f0100f15:	89 da                	mov    %ebx,%edx
f0100f17:	e8 4a fc ff ff       	call   f0100b66 <_paddr.clone.0>
f0100f1c:	83 c8 05             	or     $0x5,%eax
f0100f1f:	89 83 f4 0e 00 00    	mov    %eax,0xef4(%ebx)
	// each physical page, there is a corresponding struct PageInfo in this
	// array.  'npages' is the number of physical pages in memory.  Use memset
	// to initialize all fields of each struct PageInfo to 0.
	// Your code goes here:
    /* TODO */
    pages = (struct PageInfo *)boot_alloc(sizeof(struct PageInfo)*npages);
f0100f25:	a1 44 0e 11 f0       	mov    0xf0110e44,%eax
f0100f2a:	c1 e0 03             	shl    $0x3,%eax
f0100f2d:	e8 33 f9 ff ff       	call   f0100865 <boot_alloc>
    memset(pages,0,npages*(sizeof(struct PageInfo)));
f0100f32:	8b 15 44 0e 11 f0    	mov    0xf0110e44,%edx
f0100f38:	83 c4 0c             	add    $0xc,%esp
f0100f3b:	c1 e2 03             	shl    $0x3,%edx
f0100f3e:	52                   	push   %edx
f0100f3f:	6a 00                	push   $0x0
f0100f41:	50                   	push   %eax
	// each physical page, there is a corresponding struct PageInfo in this
	// array.  'npages' is the number of physical pages in memory.  Use memset
	// to initialize all fields of each struct PageInfo to 0.
	// Your code goes here:
    /* TODO */
    pages = (struct PageInfo *)boot_alloc(sizeof(struct PageInfo)*npages);
f0100f42:	a3 4c 0e 11 f0       	mov    %eax,0xf0110e4c
    memset(pages,0,npages*(sizeof(struct PageInfo)));
f0100f47:	e8 73 1b 00 00       	call   f0102abf <memset>
	// Now that we've allocated the initial kernel data structures, we set
	// up the list of free physical pages. Once we've done so, all further
	// memory management will go through the page_* functions. In
	// particular, we can now map memory using boot_map_region
	// or page_insert
	page_init();
f0100f4c:	e8 3b fc ff ff       	call   f0100b8c <page_init>

	check_page_free_list(1);
f0100f51:	b8 01 00 00 00       	mov    $0x1,%eax
f0100f56:	e8 d2 f9 ff ff       	call   f010092d <check_page_free_list>
	int nfree;
	struct PageInfo *fl;
	char *c;
	int i;

	if (!pages)
f0100f5b:	83 c4 10             	add    $0x10,%esp
f0100f5e:	83 3d 4c 0e 11 f0 00 	cmpl   $0x0,0xf0110e4c
f0100f65:	75 0d                	jne    f0100f74 <mem_init+0x107>
		panic("'pages' is a null pointer!");
f0100f67:	51                   	push   %ecx
f0100f68:	68 5a 37 10 f0       	push   $0xf010375a
f0100f6d:	68 67 02 00 00       	push   $0x267
f0100f72:	eb 34                	jmp    f0100fa8 <mem_init+0x13b>

	// check number of free pages
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f0100f74:	a1 1c 02 11 f0       	mov    0xf011021c,%eax
f0100f79:	31 f6                	xor    %esi,%esi
f0100f7b:	eb 03                	jmp    f0100f80 <mem_init+0x113>
f0100f7d:	8b 00                	mov    (%eax),%eax
		++nfree;
f0100f7f:	46                   	inc    %esi

	if (!pages)
		panic("'pages' is a null pointer!");

	// check number of free pages
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f0100f80:	85 c0                	test   %eax,%eax
f0100f82:	75 f9                	jne    f0100f7d <mem_init+0x110>
		++nfree;

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0100f84:	83 ec 0c             	sub    $0xc,%esp
f0100f87:	6a 00                	push   $0x0
f0100f89:	e8 9a fc ff ff       	call   f0100c28 <page_alloc>
f0100f8e:	89 44 24 18          	mov    %eax,0x18(%esp)
f0100f92:	83 c4 10             	add    $0x10,%esp
f0100f95:	85 c0                	test   %eax,%eax
f0100f97:	75 19                	jne    f0100fb2 <mem_init+0x145>
f0100f99:	68 75 37 10 f0       	push   $0xf0103775
f0100f9e:	68 73 35 10 f0       	push   $0xf0103573
f0100fa3:	68 6f 02 00 00       	push   $0x26f
f0100fa8:	68 36 35 10 f0       	push   $0xf0103536
f0100fad:	e8 02 0f 00 00       	call   f0101eb4 <_panic>
	assert((pp1 = page_alloc(0)));
f0100fb2:	83 ec 0c             	sub    $0xc,%esp
f0100fb5:	6a 00                	push   $0x0
f0100fb7:	e8 6c fc ff ff       	call   f0100c28 <page_alloc>
f0100fbc:	83 c4 10             	add    $0x10,%esp
f0100fbf:	85 c0                	test   %eax,%eax
f0100fc1:	89 c7                	mov    %eax,%edi
f0100fc3:	75 11                	jne    f0100fd6 <mem_init+0x169>
f0100fc5:	68 8b 37 10 f0       	push   $0xf010378b
f0100fca:	68 73 35 10 f0       	push   $0xf0103573
f0100fcf:	68 70 02 00 00       	push   $0x270
f0100fd4:	eb d2                	jmp    f0100fa8 <mem_init+0x13b>
	assert((pp2 = page_alloc(0)));
f0100fd6:	83 ec 0c             	sub    $0xc,%esp
f0100fd9:	6a 00                	push   $0x0
f0100fdb:	e8 48 fc ff ff       	call   f0100c28 <page_alloc>
f0100fe0:	83 c4 10             	add    $0x10,%esp
f0100fe3:	85 c0                	test   %eax,%eax
f0100fe5:	89 c3                	mov    %eax,%ebx
f0100fe7:	75 11                	jne    f0100ffa <mem_init+0x18d>
f0100fe9:	68 a1 37 10 f0       	push   $0xf01037a1
f0100fee:	68 73 35 10 f0       	push   $0xf0103573
f0100ff3:	68 71 02 00 00       	push   $0x271
f0100ff8:	eb ae                	jmp    f0100fa8 <mem_init+0x13b>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f0100ffa:	3b 7c 24 08          	cmp    0x8(%esp),%edi
f0100ffe:	75 11                	jne    f0101011 <mem_init+0x1a4>
f0101000:	68 b7 37 10 f0       	push   $0xf01037b7
f0101005:	68 73 35 10 f0       	push   $0xf0103573
f010100a:	68 74 02 00 00       	push   $0x274
f010100f:	eb 97                	jmp    f0100fa8 <mem_init+0x13b>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101011:	39 f8                	cmp    %edi,%eax
f0101013:	74 06                	je     f010101b <mem_init+0x1ae>
f0101015:	3b 44 24 08          	cmp    0x8(%esp),%eax
f0101019:	75 14                	jne    f010102f <mem_init+0x1c2>
f010101b:	68 c9 37 10 f0       	push   $0xf01037c9
f0101020:	68 73 35 10 f0       	push   $0xf0103573
f0101025:	68 75 02 00 00       	push   $0x275
f010102a:	e9 79 ff ff ff       	jmp    f0100fa8 <mem_init+0x13b>
	assert(page2pa(pp0) < npages*PGSIZE);
f010102f:	8b 44 24 08          	mov    0x8(%esp),%eax
f0101033:	e8 20 f8 ff ff       	call   f0100858 <page2pa>
f0101038:	8b 2d 44 0e 11 f0    	mov    0xf0110e44,%ebp
f010103e:	c1 e5 0c             	shl    $0xc,%ebp
f0101041:	39 e8                	cmp    %ebp,%eax
f0101043:	72 14                	jb     f0101059 <mem_init+0x1ec>
f0101045:	68 e9 37 10 f0       	push   $0xf01037e9
f010104a:	68 73 35 10 f0       	push   $0xf0103573
f010104f:	68 76 02 00 00       	push   $0x276
f0101054:	e9 4f ff ff ff       	jmp    f0100fa8 <mem_init+0x13b>
	assert(page2pa(pp1) < npages*PGSIZE);
f0101059:	89 f8                	mov    %edi,%eax
f010105b:	e8 f8 f7 ff ff       	call   f0100858 <page2pa>
f0101060:	39 e8                	cmp    %ebp,%eax
f0101062:	72 14                	jb     f0101078 <mem_init+0x20b>
f0101064:	68 06 38 10 f0       	push   $0xf0103806
f0101069:	68 73 35 10 f0       	push   $0xf0103573
f010106e:	68 77 02 00 00       	push   $0x277
f0101073:	e9 30 ff ff ff       	jmp    f0100fa8 <mem_init+0x13b>
	assert(page2pa(pp2) < npages*PGSIZE);
f0101078:	89 d8                	mov    %ebx,%eax
f010107a:	e8 d9 f7 ff ff       	call   f0100858 <page2pa>
f010107f:	39 e8                	cmp    %ebp,%eax
f0101081:	72 14                	jb     f0101097 <mem_init+0x22a>
f0101083:	68 23 38 10 f0       	push   $0xf0103823
f0101088:	68 73 35 10 f0       	push   $0xf0103573
f010108d:	68 78 02 00 00       	push   $0x278
f0101092:	e9 11 ff ff ff       	jmp    f0100fa8 <mem_init+0x13b>
	// temporarily steal the rest of the free pages
	fl = page_free_list;
	page_free_list = 0;

	// should be no free memory
	assert(!page_alloc(0));
f0101097:	83 ec 0c             	sub    $0xc,%esp
	assert(page2pa(pp0) < npages*PGSIZE);
	assert(page2pa(pp1) < npages*PGSIZE);
	assert(page2pa(pp2) < npages*PGSIZE);

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f010109a:	8b 2d 1c 02 11 f0    	mov    0xf011021c,%ebp
	page_free_list = 0;

	// should be no free memory
	assert(!page_alloc(0));
f01010a0:	6a 00                	push   $0x0
	assert(page2pa(pp1) < npages*PGSIZE);
	assert(page2pa(pp2) < npages*PGSIZE);

	// temporarily steal the rest of the free pages
	fl = page_free_list;
	page_free_list = 0;
f01010a2:	c7 05 1c 02 11 f0 00 	movl   $0x0,0xf011021c
f01010a9:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f01010ac:	e8 77 fb ff ff       	call   f0100c28 <page_alloc>
f01010b1:	83 c4 10             	add    $0x10,%esp
f01010b4:	85 c0                	test   %eax,%eax
f01010b6:	74 14                	je     f01010cc <mem_init+0x25f>
f01010b8:	68 40 38 10 f0       	push   $0xf0103840
f01010bd:	68 73 35 10 f0       	push   $0xf0103573
f01010c2:	68 7f 02 00 00       	push   $0x27f
f01010c7:	e9 dc fe ff ff       	jmp    f0100fa8 <mem_init+0x13b>

	// free and re-allocate?
	page_free(pp0);
f01010cc:	83 ec 0c             	sub    $0xc,%esp
f01010cf:	ff 74 24 14          	pushl  0x14(%esp)
f01010d3:	e8 91 fb ff ff       	call   f0100c69 <page_free>
	page_free(pp1);
f01010d8:	89 3c 24             	mov    %edi,(%esp)
f01010db:	e8 89 fb ff ff       	call   f0100c69 <page_free>
	page_free(pp2);
f01010e0:	89 1c 24             	mov    %ebx,(%esp)
f01010e3:	e8 81 fb ff ff       	call   f0100c69 <page_free>
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f01010e8:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01010ef:	e8 34 fb ff ff       	call   f0100c28 <page_alloc>
f01010f4:	83 c4 10             	add    $0x10,%esp
f01010f7:	85 c0                	test   %eax,%eax
f01010f9:	89 c3                	mov    %eax,%ebx
f01010fb:	75 14                	jne    f0101111 <mem_init+0x2a4>
f01010fd:	68 75 37 10 f0       	push   $0xf0103775
f0101102:	68 73 35 10 f0       	push   $0xf0103573
f0101107:	68 86 02 00 00       	push   $0x286
f010110c:	e9 97 fe ff ff       	jmp    f0100fa8 <mem_init+0x13b>
	assert((pp1 = page_alloc(0)));
f0101111:	83 ec 0c             	sub    $0xc,%esp
f0101114:	6a 00                	push   $0x0
f0101116:	e8 0d fb ff ff       	call   f0100c28 <page_alloc>
f010111b:	89 44 24 18          	mov    %eax,0x18(%esp)
f010111f:	83 c4 10             	add    $0x10,%esp
f0101122:	85 c0                	test   %eax,%eax
f0101124:	75 14                	jne    f010113a <mem_init+0x2cd>
f0101126:	68 8b 37 10 f0       	push   $0xf010378b
f010112b:	68 73 35 10 f0       	push   $0xf0103573
f0101130:	68 87 02 00 00       	push   $0x287
f0101135:	e9 6e fe ff ff       	jmp    f0100fa8 <mem_init+0x13b>
	assert((pp2 = page_alloc(0)));
f010113a:	83 ec 0c             	sub    $0xc,%esp
f010113d:	6a 00                	push   $0x0
f010113f:	e8 e4 fa ff ff       	call   f0100c28 <page_alloc>
f0101144:	83 c4 10             	add    $0x10,%esp
f0101147:	85 c0                	test   %eax,%eax
f0101149:	89 c7                	mov    %eax,%edi
f010114b:	75 14                	jne    f0101161 <mem_init+0x2f4>
f010114d:	68 a1 37 10 f0       	push   $0xf01037a1
f0101152:	68 73 35 10 f0       	push   $0xf0103573
f0101157:	68 88 02 00 00       	push   $0x288
f010115c:	e9 47 fe ff ff       	jmp    f0100fa8 <mem_init+0x13b>
	assert(pp0);
	assert(pp1 && pp1 != pp0);
f0101161:	39 5c 24 08          	cmp    %ebx,0x8(%esp)
f0101165:	75 14                	jne    f010117b <mem_init+0x30e>
f0101167:	68 b7 37 10 f0       	push   $0xf01037b7
f010116c:	68 73 35 10 f0       	push   $0xf0103573
f0101171:	68 8a 02 00 00       	push   $0x28a
f0101176:	e9 2d fe ff ff       	jmp    f0100fa8 <mem_init+0x13b>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f010117b:	3b 44 24 08          	cmp    0x8(%esp),%eax
f010117f:	74 04                	je     f0101185 <mem_init+0x318>
f0101181:	39 d8                	cmp    %ebx,%eax
f0101183:	75 14                	jne    f0101199 <mem_init+0x32c>
f0101185:	68 c9 37 10 f0       	push   $0xf01037c9
f010118a:	68 73 35 10 f0       	push   $0xf0103573
f010118f:	68 8b 02 00 00       	push   $0x28b
f0101194:	e9 0f fe ff ff       	jmp    f0100fa8 <mem_init+0x13b>
	assert(!page_alloc(0));
f0101199:	83 ec 0c             	sub    $0xc,%esp
f010119c:	6a 00                	push   $0x0
f010119e:	e8 85 fa ff ff       	call   f0100c28 <page_alloc>
f01011a3:	83 c4 10             	add    $0x10,%esp
f01011a6:	85 c0                	test   %eax,%eax
f01011a8:	74 14                	je     f01011be <mem_init+0x351>
f01011aa:	68 40 38 10 f0       	push   $0xf0103840
f01011af:	68 73 35 10 f0       	push   $0xf0103573
f01011b4:	68 8c 02 00 00       	push   $0x28c
f01011b9:	e9 ea fd ff ff       	jmp    f0100fa8 <mem_init+0x13b>

	// test flags
	memset(page2kva(pp0), 1, PGSIZE);
f01011be:	89 d8                	mov    %ebx,%eax
f01011c0:	e8 04 f7 ff ff       	call   f01008c9 <page2kva>
f01011c5:	52                   	push   %edx
f01011c6:	68 00 10 00 00       	push   $0x1000
f01011cb:	6a 01                	push   $0x1
f01011cd:	50                   	push   %eax
f01011ce:	e8 ec 18 00 00       	call   f0102abf <memset>
	page_free(pp0);
f01011d3:	89 1c 24             	mov    %ebx,(%esp)
f01011d6:	e8 8e fa ff ff       	call   f0100c69 <page_free>
	assert((pp = page_alloc(ALLOC_ZERO)));
f01011db:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f01011e2:	e8 41 fa ff ff       	call   f0100c28 <page_alloc>
f01011e7:	83 c4 10             	add    $0x10,%esp
f01011ea:	85 c0                	test   %eax,%eax
f01011ec:	75 14                	jne    f0101202 <mem_init+0x395>
f01011ee:	68 4f 38 10 f0       	push   $0xf010384f
f01011f3:	68 73 35 10 f0       	push   $0xf0103573
f01011f8:	68 91 02 00 00       	push   $0x291
f01011fd:	e9 a6 fd ff ff       	jmp    f0100fa8 <mem_init+0x13b>
	assert(pp && pp0 == pp);
f0101202:	39 c3                	cmp    %eax,%ebx
f0101204:	74 14                	je     f010121a <mem_init+0x3ad>
f0101206:	68 6d 38 10 f0       	push   $0xf010386d
f010120b:	68 73 35 10 f0       	push   $0xf0103573
f0101210:	68 92 02 00 00       	push   $0x292
f0101215:	e9 8e fd ff ff       	jmp    f0100fa8 <mem_init+0x13b>
	c = page2kva(pp);
f010121a:	89 d8                	mov    %ebx,%eax
f010121c:	e8 a8 f6 ff ff       	call   f01008c9 <page2kva>
	for (i = 0; i < PGSIZE; i++)
f0101221:	31 d2                	xor    %edx,%edx
		assert(c[i] == 0);
f0101223:	80 3c 10 00          	cmpb   $0x0,(%eax,%edx,1)
f0101227:	74 14                	je     f010123d <mem_init+0x3d0>
f0101229:	68 7d 38 10 f0       	push   $0xf010387d
f010122e:	68 73 35 10 f0       	push   $0xf0103573
f0101233:	68 95 02 00 00       	push   $0x295
f0101238:	e9 6b fd ff ff       	jmp    f0100fa8 <mem_init+0x13b>
	memset(page2kva(pp0), 1, PGSIZE);
	page_free(pp0);
	assert((pp = page_alloc(ALLOC_ZERO)));
	assert(pp && pp0 == pp);
	c = page2kva(pp);
	for (i = 0; i < PGSIZE; i++)
f010123d:	42                   	inc    %edx
f010123e:	81 fa 00 10 00 00    	cmp    $0x1000,%edx
f0101244:	75 dd                	jne    f0101223 <mem_init+0x3b6>

	// give free list back
	page_free_list = fl;

	// free the pages we took
	page_free(pp0);
f0101246:	83 ec 0c             	sub    $0xc,%esp
f0101249:	53                   	push   %ebx
	c = page2kva(pp);
	for (i = 0; i < PGSIZE; i++)
		assert(c[i] == 0);

	// give free list back
	page_free_list = fl;
f010124a:	89 2d 1c 02 11 f0    	mov    %ebp,0xf011021c

	// free the pages we took
	page_free(pp0);
f0101250:	e8 14 fa ff ff       	call   f0100c69 <page_free>
	page_free(pp1);
f0101255:	5b                   	pop    %ebx
f0101256:	ff 74 24 14          	pushl  0x14(%esp)
f010125a:	e8 0a fa ff ff       	call   f0100c69 <page_free>
	page_free(pp2);
f010125f:	89 3c 24             	mov    %edi,(%esp)
f0101262:	e8 02 fa ff ff       	call   f0100c69 <page_free>

	// number of free pages should be the same
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0101267:	a1 1c 02 11 f0       	mov    0xf011021c,%eax
f010126c:	83 c4 10             	add    $0x10,%esp
f010126f:	eb 03                	jmp    f0101274 <mem_init+0x407>
f0101271:	8b 00                	mov    (%eax),%eax
		--nfree;
f0101273:	4e                   	dec    %esi
	page_free(pp0);
	page_free(pp1);
	page_free(pp2);

	// number of free pages should be the same
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0101274:	85 c0                	test   %eax,%eax
f0101276:	75 f9                	jne    f0101271 <mem_init+0x404>
		--nfree;
	assert(nfree == 0);
f0101278:	85 f6                	test   %esi,%esi
f010127a:	74 14                	je     f0101290 <mem_init+0x423>
f010127c:	68 87 38 10 f0       	push   $0xf0103887
f0101281:	68 73 35 10 f0       	push   $0xf0103573
f0101286:	68 a2 02 00 00       	push   $0x2a2
f010128b:	e9 18 fd ff ff       	jmp    f0100fa8 <mem_init+0x13b>

	cprintf("check_page_alloc() succeeded!\n");
f0101290:	83 ec 0c             	sub    $0xc,%esp
f0101293:	68 92 38 10 f0       	push   $0xf0103892
f0101298:	e8 a1 f5 ff ff       	call   f010083e <cprintf>
	int i;
	extern pde_t entry_pgdir[];

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f010129d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01012a4:	e8 7f f9 ff ff       	call   f0100c28 <page_alloc>
f01012a9:	83 c4 10             	add    $0x10,%esp
f01012ac:	85 c0                	test   %eax,%eax
f01012ae:	89 c6                	mov    %eax,%esi
f01012b0:	75 14                	jne    f01012c6 <mem_init+0x459>
f01012b2:	68 75 37 10 f0       	push   $0xf0103775
f01012b7:	68 73 35 10 f0       	push   $0xf0103573
f01012bc:	68 ff 02 00 00       	push   $0x2ff
f01012c1:	e9 e2 fc ff ff       	jmp    f0100fa8 <mem_init+0x13b>
	assert((pp1 = page_alloc(0)));
f01012c6:	83 ec 0c             	sub    $0xc,%esp
f01012c9:	6a 00                	push   $0x0
f01012cb:	e8 58 f9 ff ff       	call   f0100c28 <page_alloc>
f01012d0:	83 c4 10             	add    $0x10,%esp
f01012d3:	85 c0                	test   %eax,%eax
f01012d5:	89 c3                	mov    %eax,%ebx
f01012d7:	75 14                	jne    f01012ed <mem_init+0x480>
f01012d9:	68 8b 37 10 f0       	push   $0xf010378b
f01012de:	68 73 35 10 f0       	push   $0xf0103573
f01012e3:	68 00 03 00 00       	push   $0x300
f01012e8:	e9 bb fc ff ff       	jmp    f0100fa8 <mem_init+0x13b>
	assert((pp2 = page_alloc(0)));
f01012ed:	83 ec 0c             	sub    $0xc,%esp
f01012f0:	6a 00                	push   $0x0
f01012f2:	e8 31 f9 ff ff       	call   f0100c28 <page_alloc>
f01012f7:	83 c4 10             	add    $0x10,%esp
f01012fa:	85 c0                	test   %eax,%eax
f01012fc:	89 c7                	mov    %eax,%edi
f01012fe:	75 14                	jne    f0101314 <mem_init+0x4a7>
f0101300:	68 a1 37 10 f0       	push   $0xf01037a1
f0101305:	68 73 35 10 f0       	push   $0xf0103573
f010130a:	68 01 03 00 00       	push   $0x301
f010130f:	e9 94 fc ff ff       	jmp    f0100fa8 <mem_init+0x13b>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f0101314:	39 f3                	cmp    %esi,%ebx
f0101316:	75 14                	jne    f010132c <mem_init+0x4bf>
f0101318:	68 b7 37 10 f0       	push   $0xf01037b7
f010131d:	68 73 35 10 f0       	push   $0xf0103573
f0101322:	68 04 03 00 00       	push   $0x304
f0101327:	e9 7c fc ff ff       	jmp    f0100fa8 <mem_init+0x13b>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f010132c:	39 d8                	cmp    %ebx,%eax
f010132e:	74 04                	je     f0101334 <mem_init+0x4c7>
f0101330:	39 f0                	cmp    %esi,%eax
f0101332:	75 14                	jne    f0101348 <mem_init+0x4db>
f0101334:	68 c9 37 10 f0       	push   $0xf01037c9
f0101339:	68 73 35 10 f0       	push   $0xf0103573
f010133e:	68 05 03 00 00       	push   $0x305
f0101343:	e9 60 fc ff ff       	jmp    f0100fa8 <mem_init+0x13b>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f0101348:	a1 1c 02 11 f0       	mov    0xf011021c,%eax
	page_free_list = 0;
f010134d:	c7 05 1c 02 11 f0 00 	movl   $0x0,0xf011021c
f0101354:	00 00 00 
	assert(pp0);
	assert(pp1 && pp1 != pp0);
	assert(pp2 && pp2 != pp1 && pp2 != pp0);

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f0101357:	89 44 24 08          	mov    %eax,0x8(%esp)
	page_free_list = 0;

	// should be no free memory
	assert(!page_alloc(0));
f010135b:	83 ec 0c             	sub    $0xc,%esp
f010135e:	6a 00                	push   $0x0
f0101360:	e8 c3 f8 ff ff       	call   f0100c28 <page_alloc>
f0101365:	83 c4 10             	add    $0x10,%esp
f0101368:	85 c0                	test   %eax,%eax
f010136a:	74 14                	je     f0101380 <mem_init+0x513>
f010136c:	68 40 38 10 f0       	push   $0xf0103840
f0101371:	68 73 35 10 f0       	push   $0xf0103573
f0101376:	68 0c 03 00 00       	push   $0x30c
f010137b:	e9 28 fc ff ff       	jmp    f0100fa8 <mem_init+0x13b>

	// there is no page allocated at address 0
	assert(page_lookup(kern_pgdir, (void *) 0x0, &ptep) == NULL);
f0101380:	51                   	push   %ecx
f0101381:	8d 44 24 20          	lea    0x20(%esp),%eax
f0101385:	50                   	push   %eax
f0101386:	6a 00                	push   $0x0
f0101388:	ff 35 48 0e 11 f0    	pushl  0xf0110e48
f010138e:	e8 e7 f9 ff ff       	call   f0100d7a <page_lookup>
f0101393:	83 c4 10             	add    $0x10,%esp
f0101396:	85 c0                	test   %eax,%eax
f0101398:	74 14                	je     f01013ae <mem_init+0x541>
f010139a:	68 b1 38 10 f0       	push   $0xf01038b1
f010139f:	68 73 35 10 f0       	push   $0xf0103573
f01013a4:	68 0f 03 00 00       	push   $0x30f
f01013a9:	e9 fa fb ff ff       	jmp    f0100fa8 <mem_init+0x13b>

	// there is no free memory, so we can't allocate a page table
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) < 0);
f01013ae:	6a 02                	push   $0x2
f01013b0:	6a 00                	push   $0x0
f01013b2:	53                   	push   %ebx
f01013b3:	ff 35 48 0e 11 f0    	pushl  0xf0110e48
f01013b9:	e8 54 fa ff ff       	call   f0100e12 <page_insert>
f01013be:	83 c4 10             	add    $0x10,%esp
f01013c1:	85 c0                	test   %eax,%eax
f01013c3:	78 14                	js     f01013d9 <mem_init+0x56c>
f01013c5:	68 e6 38 10 f0       	push   $0xf01038e6
f01013ca:	68 73 35 10 f0       	push   $0xf0103573
f01013cf:	68 12 03 00 00       	push   $0x312
f01013d4:	e9 cf fb ff ff       	jmp    f0100fa8 <mem_init+0x13b>

	// free pp0 and try again: pp0 should be used for page table
	page_free(pp0);
f01013d9:	83 ec 0c             	sub    $0xc,%esp
f01013dc:	56                   	push   %esi
f01013dd:	e8 87 f8 ff ff       	call   f0100c69 <page_free>
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) == 0);
f01013e2:	6a 02                	push   $0x2
f01013e4:	6a 00                	push   $0x0
f01013e6:	53                   	push   %ebx
f01013e7:	ff 35 48 0e 11 f0    	pushl  0xf0110e48
f01013ed:	e8 20 fa ff ff       	call   f0100e12 <page_insert>
f01013f2:	83 c4 20             	add    $0x20,%esp
f01013f5:	85 c0                	test   %eax,%eax
f01013f7:	74 14                	je     f010140d <mem_init+0x5a0>
f01013f9:	68 13 39 10 f0       	push   $0xf0103913
f01013fe:	68 73 35 10 f0       	push   $0xf0103573
f0101403:	68 16 03 00 00       	push   $0x316
f0101408:	e9 9b fb ff ff       	jmp    f0100fa8 <mem_init+0x13b>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f010140d:	8b 2d 48 0e 11 f0    	mov    0xf0110e48,%ebp
f0101413:	89 f0                	mov    %esi,%eax
f0101415:	e8 3e f4 ff ff       	call   f0100858 <page2pa>
f010141a:	8b 55 00             	mov    0x0(%ebp),%edx
f010141d:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0101423:	39 c2                	cmp    %eax,%edx
f0101425:	74 14                	je     f010143b <mem_init+0x5ce>
f0101427:	68 41 39 10 f0       	push   $0xf0103941
f010142c:	68 73 35 10 f0       	push   $0xf0103573
f0101431:	68 17 03 00 00       	push   $0x317
f0101436:	e9 6d fb ff ff       	jmp    f0100fa8 <mem_init+0x13b>
	assert(check_va2pa(kern_pgdir, 0x0) == page2pa(pp1));
f010143b:	31 d2                	xor    %edx,%edx
f010143d:	89 e8                	mov    %ebp,%eax
f010143f:	e8 9e f4 ff ff       	call   f01008e2 <check_va2pa>
f0101444:	89 c5                	mov    %eax,%ebp
f0101446:	89 d8                	mov    %ebx,%eax
f0101448:	e8 0b f4 ff ff       	call   f0100858 <page2pa>
f010144d:	39 c5                	cmp    %eax,%ebp
f010144f:	74 14                	je     f0101465 <mem_init+0x5f8>
f0101451:	68 69 39 10 f0       	push   $0xf0103969
f0101456:	68 73 35 10 f0       	push   $0xf0103573
f010145b:	68 18 03 00 00       	push   $0x318
f0101460:	e9 43 fb ff ff       	jmp    f0100fa8 <mem_init+0x13b>
	assert(pp1->pp_ref == 1);
f0101465:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f010146a:	74 14                	je     f0101480 <mem_init+0x613>
f010146c:	68 96 39 10 f0       	push   $0xf0103996
f0101471:	68 73 35 10 f0       	push   $0xf0103573
f0101476:	68 19 03 00 00       	push   $0x319
f010147b:	e9 28 fb ff ff       	jmp    f0100fa8 <mem_init+0x13b>
	assert(pp0->pp_ref == 1);
f0101480:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0101485:	74 14                	je     f010149b <mem_init+0x62e>
f0101487:	68 a7 39 10 f0       	push   $0xf01039a7
f010148c:	68 73 35 10 f0       	push   $0xf0103573
f0101491:	68 1a 03 00 00       	push   $0x31a
f0101496:	e9 0d fb ff ff       	jmp    f0100fa8 <mem_init+0x13b>

	// should be able to map pp2 at PGSIZE because pp0 is already allocated for page table
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f010149b:	6a 02                	push   $0x2
f010149d:	68 00 10 00 00       	push   $0x1000
f01014a2:	57                   	push   %edi
f01014a3:	ff 35 48 0e 11 f0    	pushl  0xf0110e48
f01014a9:	e8 64 f9 ff ff       	call   f0100e12 <page_insert>
f01014ae:	83 c4 10             	add    $0x10,%esp
f01014b1:	85 c0                	test   %eax,%eax
f01014b3:	74 14                	je     f01014c9 <mem_init+0x65c>
f01014b5:	68 b8 39 10 f0       	push   $0xf01039b8
f01014ba:	68 73 35 10 f0       	push   $0xf0103573
f01014bf:	68 1d 03 00 00       	push   $0x31d
f01014c4:	e9 df fa ff ff       	jmp    f0100fa8 <mem_init+0x13b>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f01014c9:	a1 48 0e 11 f0       	mov    0xf0110e48,%eax
f01014ce:	ba 00 10 00 00       	mov    $0x1000,%edx
f01014d3:	e8 0a f4 ff ff       	call   f01008e2 <check_va2pa>
f01014d8:	89 c5                	mov    %eax,%ebp
f01014da:	89 f8                	mov    %edi,%eax
f01014dc:	e8 77 f3 ff ff       	call   f0100858 <page2pa>
f01014e1:	39 c5                	cmp    %eax,%ebp
f01014e3:	74 14                	je     f01014f9 <mem_init+0x68c>
f01014e5:	68 f1 39 10 f0       	push   $0xf01039f1
f01014ea:	68 73 35 10 f0       	push   $0xf0103573
f01014ef:	68 1e 03 00 00       	push   $0x31e
f01014f4:	e9 af fa ff ff       	jmp    f0100fa8 <mem_init+0x13b>
	assert(pp2->pp_ref == 1);
f01014f9:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f01014fe:	74 14                	je     f0101514 <mem_init+0x6a7>
f0101500:	68 21 3a 10 f0       	push   $0xf0103a21
f0101505:	68 73 35 10 f0       	push   $0xf0103573
f010150a:	68 1f 03 00 00       	push   $0x31f
f010150f:	e9 94 fa ff ff       	jmp    f0100fa8 <mem_init+0x13b>

	// should be no free memory
	assert(!page_alloc(0));
f0101514:	83 ec 0c             	sub    $0xc,%esp
f0101517:	6a 00                	push   $0x0
f0101519:	e8 0a f7 ff ff       	call   f0100c28 <page_alloc>
f010151e:	83 c4 10             	add    $0x10,%esp
f0101521:	85 c0                	test   %eax,%eax
f0101523:	74 14                	je     f0101539 <mem_init+0x6cc>
f0101525:	68 40 38 10 f0       	push   $0xf0103840
f010152a:	68 73 35 10 f0       	push   $0xf0103573
f010152f:	68 22 03 00 00       	push   $0x322
f0101534:	e9 6f fa ff ff       	jmp    f0100fa8 <mem_init+0x13b>

	// should be able to map pp2 at PGSIZE because it's already there
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101539:	6a 02                	push   $0x2
f010153b:	68 00 10 00 00       	push   $0x1000
f0101540:	57                   	push   %edi
f0101541:	ff 35 48 0e 11 f0    	pushl  0xf0110e48
f0101547:	e8 c6 f8 ff ff       	call   f0100e12 <page_insert>
f010154c:	83 c4 10             	add    $0x10,%esp
f010154f:	85 c0                	test   %eax,%eax
f0101551:	74 14                	je     f0101567 <mem_init+0x6fa>
f0101553:	68 b8 39 10 f0       	push   $0xf01039b8
f0101558:	68 73 35 10 f0       	push   $0xf0103573
f010155d:	68 25 03 00 00       	push   $0x325
f0101562:	e9 41 fa ff ff       	jmp    f0100fa8 <mem_init+0x13b>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101567:	a1 48 0e 11 f0       	mov    0xf0110e48,%eax
f010156c:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101571:	e8 6c f3 ff ff       	call   f01008e2 <check_va2pa>
f0101576:	89 c5                	mov    %eax,%ebp
f0101578:	89 f8                	mov    %edi,%eax
f010157a:	e8 d9 f2 ff ff       	call   f0100858 <page2pa>
f010157f:	39 c5                	cmp    %eax,%ebp
f0101581:	74 14                	je     f0101597 <mem_init+0x72a>
f0101583:	68 f1 39 10 f0       	push   $0xf01039f1
f0101588:	68 73 35 10 f0       	push   $0xf0103573
f010158d:	68 26 03 00 00       	push   $0x326
f0101592:	e9 11 fa ff ff       	jmp    f0100fa8 <mem_init+0x13b>
	assert(pp2->pp_ref == 1);
f0101597:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f010159c:	74 14                	je     f01015b2 <mem_init+0x745>
f010159e:	68 21 3a 10 f0       	push   $0xf0103a21
f01015a3:	68 73 35 10 f0       	push   $0xf0103573
f01015a8:	68 27 03 00 00       	push   $0x327
f01015ad:	e9 f6 f9 ff ff       	jmp    f0100fa8 <mem_init+0x13b>

	// pp2 should NOT be on the free list
	// could happen in ref counts are handled sloppily in page_insert
	assert(!page_alloc(0));
f01015b2:	83 ec 0c             	sub    $0xc,%esp
f01015b5:	6a 00                	push   $0x0
f01015b7:	e8 6c f6 ff ff       	call   f0100c28 <page_alloc>
f01015bc:	83 c4 10             	add    $0x10,%esp
f01015bf:	85 c0                	test   %eax,%eax
f01015c1:	74 14                	je     f01015d7 <mem_init+0x76a>
f01015c3:	68 40 38 10 f0       	push   $0xf0103840
f01015c8:	68 73 35 10 f0       	push   $0xf0103573
f01015cd:	68 2b 03 00 00       	push   $0x32b
f01015d2:	e9 d1 f9 ff ff       	jmp    f0100fa8 <mem_init+0x13b>

	// check that pgdir_walk returns a pointer to the pte
	ptep = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(PGSIZE)]));
f01015d7:	a1 48 0e 11 f0       	mov    0xf0110e48,%eax
f01015dc:	ba 2e 03 00 00       	mov    $0x32e,%edx
f01015e1:	8b 08                	mov    (%eax),%ecx
f01015e3:	b8 36 35 10 f0       	mov    $0xf0103536,%eax
f01015e8:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
f01015ee:	e8 ad f2 ff ff       	call   f01008a0 <_kaddr>
f01015f3:	89 44 24 1c          	mov    %eax,0x1c(%esp)
	assert(pgdir_walk(kern_pgdir, (void*)PGSIZE, 0) == ptep+PTX(PGSIZE));
f01015f7:	52                   	push   %edx
f01015f8:	6a 00                	push   $0x0
f01015fa:	68 00 10 00 00       	push   $0x1000
f01015ff:	ff 35 48 0e 11 f0    	pushl  0xf0110e48
f0101605:	e8 b8 f6 ff ff       	call   f0100cc2 <pgdir_walk>
f010160a:	8b 54 24 2c          	mov    0x2c(%esp),%edx
f010160e:	83 c4 10             	add    $0x10,%esp
f0101611:	83 c2 04             	add    $0x4,%edx
f0101614:	39 d0                	cmp    %edx,%eax
f0101616:	74 14                	je     f010162c <mem_init+0x7bf>
f0101618:	68 32 3a 10 f0       	push   $0xf0103a32
f010161d:	68 73 35 10 f0       	push   $0xf0103573
f0101622:	68 2f 03 00 00       	push   $0x32f
f0101627:	e9 7c f9 ff ff       	jmp    f0100fa8 <mem_init+0x13b>

	// should be able to change permissions too.
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W|PTE_U) == 0);
f010162c:	6a 06                	push   $0x6
f010162e:	68 00 10 00 00       	push   $0x1000
f0101633:	57                   	push   %edi
f0101634:	ff 35 48 0e 11 f0    	pushl  0xf0110e48
f010163a:	e8 d3 f7 ff ff       	call   f0100e12 <page_insert>
f010163f:	83 c4 10             	add    $0x10,%esp
f0101642:	85 c0                	test   %eax,%eax
f0101644:	74 14                	je     f010165a <mem_init+0x7ed>
f0101646:	68 6f 3a 10 f0       	push   $0xf0103a6f
f010164b:	68 73 35 10 f0       	push   $0xf0103573
f0101650:	68 32 03 00 00       	push   $0x332
f0101655:	e9 4e f9 ff ff       	jmp    f0100fa8 <mem_init+0x13b>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f010165a:	a1 48 0e 11 f0       	mov    0xf0110e48,%eax
f010165f:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101664:	e8 79 f2 ff ff       	call   f01008e2 <check_va2pa>
f0101669:	89 c5                	mov    %eax,%ebp
f010166b:	89 f8                	mov    %edi,%eax
f010166d:	e8 e6 f1 ff ff       	call   f0100858 <page2pa>
f0101672:	39 c5                	cmp    %eax,%ebp
f0101674:	74 14                	je     f010168a <mem_init+0x81d>
f0101676:	68 f1 39 10 f0       	push   $0xf01039f1
f010167b:	68 73 35 10 f0       	push   $0xf0103573
f0101680:	68 33 03 00 00       	push   $0x333
f0101685:	e9 1e f9 ff ff       	jmp    f0100fa8 <mem_init+0x13b>
	assert(pp2->pp_ref == 1);
f010168a:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f010168f:	74 14                	je     f01016a5 <mem_init+0x838>
f0101691:	68 21 3a 10 f0       	push   $0xf0103a21
f0101696:	68 73 35 10 f0       	push   $0xf0103573
f010169b:	68 34 03 00 00       	push   $0x334
f01016a0:	e9 03 f9 ff ff       	jmp    f0100fa8 <mem_init+0x13b>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U);
f01016a5:	50                   	push   %eax
f01016a6:	6a 00                	push   $0x0
f01016a8:	68 00 10 00 00       	push   $0x1000
f01016ad:	ff 35 48 0e 11 f0    	pushl  0xf0110e48
f01016b3:	e8 0a f6 ff ff       	call   f0100cc2 <pgdir_walk>
f01016b8:	83 c4 10             	add    $0x10,%esp
f01016bb:	f6 00 04             	testb  $0x4,(%eax)
f01016be:	75 14                	jne    f01016d4 <mem_init+0x867>
f01016c0:	68 ae 3a 10 f0       	push   $0xf0103aae
f01016c5:	68 73 35 10 f0       	push   $0xf0103573
f01016ca:	68 35 03 00 00       	push   $0x335
f01016cf:	e9 d4 f8 ff ff       	jmp    f0100fa8 <mem_init+0x13b>
	assert(kern_pgdir[0] & PTE_U);
f01016d4:	a1 48 0e 11 f0       	mov    0xf0110e48,%eax
f01016d9:	f6 00 04             	testb  $0x4,(%eax)
f01016dc:	75 14                	jne    f01016f2 <mem_init+0x885>
f01016de:	68 e1 3a 10 f0       	push   $0xf0103ae1
f01016e3:	68 73 35 10 f0       	push   $0xf0103573
f01016e8:	68 36 03 00 00       	push   $0x336
f01016ed:	e9 b6 f8 ff ff       	jmp    f0100fa8 <mem_init+0x13b>

	// should be able to remap with fewer permissions
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f01016f2:	6a 02                	push   $0x2
f01016f4:	68 00 10 00 00       	push   $0x1000
f01016f9:	57                   	push   %edi
f01016fa:	50                   	push   %eax
f01016fb:	e8 12 f7 ff ff       	call   f0100e12 <page_insert>
f0101700:	83 c4 10             	add    $0x10,%esp
f0101703:	85 c0                	test   %eax,%eax
f0101705:	74 14                	je     f010171b <mem_init+0x8ae>
f0101707:	68 b8 39 10 f0       	push   $0xf01039b8
f010170c:	68 73 35 10 f0       	push   $0xf0103573
f0101711:	68 39 03 00 00       	push   $0x339
f0101716:	e9 8d f8 ff ff       	jmp    f0100fa8 <mem_init+0x13b>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_W);
f010171b:	55                   	push   %ebp
f010171c:	6a 00                	push   $0x0
f010171e:	68 00 10 00 00       	push   $0x1000
f0101723:	ff 35 48 0e 11 f0    	pushl  0xf0110e48
f0101729:	e8 94 f5 ff ff       	call   f0100cc2 <pgdir_walk>
f010172e:	83 c4 10             	add    $0x10,%esp
f0101731:	f6 00 02             	testb  $0x2,(%eax)
f0101734:	75 14                	jne    f010174a <mem_init+0x8dd>
f0101736:	68 f7 3a 10 f0       	push   $0xf0103af7
f010173b:	68 73 35 10 f0       	push   $0xf0103573
f0101740:	68 3a 03 00 00       	push   $0x33a
f0101745:	e9 5e f8 ff ff       	jmp    f0100fa8 <mem_init+0x13b>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f010174a:	51                   	push   %ecx
f010174b:	6a 00                	push   $0x0
f010174d:	68 00 10 00 00       	push   $0x1000
f0101752:	ff 35 48 0e 11 f0    	pushl  0xf0110e48
f0101758:	e8 65 f5 ff ff       	call   f0100cc2 <pgdir_walk>
f010175d:	83 c4 10             	add    $0x10,%esp
f0101760:	f6 00 04             	testb  $0x4,(%eax)
f0101763:	74 14                	je     f0101779 <mem_init+0x90c>
f0101765:	68 2a 3b 10 f0       	push   $0xf0103b2a
f010176a:	68 73 35 10 f0       	push   $0xf0103573
f010176f:	68 3b 03 00 00       	push   $0x33b
f0101774:	e9 2f f8 ff ff       	jmp    f0100fa8 <mem_init+0x13b>

	// should not be able to map at PTSIZE because need free page for page table
	assert(page_insert(kern_pgdir, pp0, (void*) PTSIZE, PTE_W) < 0);
f0101779:	6a 02                	push   $0x2
f010177b:	68 00 00 40 00       	push   $0x400000
f0101780:	56                   	push   %esi
f0101781:	ff 35 48 0e 11 f0    	pushl  0xf0110e48
f0101787:	e8 86 f6 ff ff       	call   f0100e12 <page_insert>
f010178c:	83 c4 10             	add    $0x10,%esp
f010178f:	85 c0                	test   %eax,%eax
f0101791:	78 14                	js     f01017a7 <mem_init+0x93a>
f0101793:	68 60 3b 10 f0       	push   $0xf0103b60
f0101798:	68 73 35 10 f0       	push   $0xf0103573
f010179d:	68 3e 03 00 00       	push   $0x33e
f01017a2:	e9 01 f8 ff ff       	jmp    f0100fa8 <mem_init+0x13b>

	// insert pp1 at PGSIZE (replacing pp2)
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W) == 0);
f01017a7:	6a 02                	push   $0x2
f01017a9:	68 00 10 00 00       	push   $0x1000
f01017ae:	53                   	push   %ebx
f01017af:	ff 35 48 0e 11 f0    	pushl  0xf0110e48
f01017b5:	e8 58 f6 ff ff       	call   f0100e12 <page_insert>
f01017ba:	83 c4 10             	add    $0x10,%esp
f01017bd:	85 c0                	test   %eax,%eax
f01017bf:	74 14                	je     f01017d5 <mem_init+0x968>
f01017c1:	68 98 3b 10 f0       	push   $0xf0103b98
f01017c6:	68 73 35 10 f0       	push   $0xf0103573
f01017cb:	68 41 03 00 00       	push   $0x341
f01017d0:	e9 d3 f7 ff ff       	jmp    f0100fa8 <mem_init+0x13b>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f01017d5:	52                   	push   %edx
f01017d6:	6a 00                	push   $0x0
f01017d8:	68 00 10 00 00       	push   $0x1000
f01017dd:	ff 35 48 0e 11 f0    	pushl  0xf0110e48
f01017e3:	e8 da f4 ff ff       	call   f0100cc2 <pgdir_walk>
f01017e8:	83 c4 10             	add    $0x10,%esp
f01017eb:	f6 00 04             	testb  $0x4,(%eax)
f01017ee:	74 14                	je     f0101804 <mem_init+0x997>
f01017f0:	68 2a 3b 10 f0       	push   $0xf0103b2a
f01017f5:	68 73 35 10 f0       	push   $0xf0103573
f01017fa:	68 42 03 00 00       	push   $0x342
f01017ff:	e9 a4 f7 ff ff       	jmp    f0100fa8 <mem_init+0x13b>

	// should have pp1 at both 0 and PGSIZE, pp2 nowhere, ...
	assert(check_va2pa(kern_pgdir, 0) == page2pa(pp1));
f0101804:	a1 48 0e 11 f0       	mov    0xf0110e48,%eax
f0101809:	31 d2                	xor    %edx,%edx
f010180b:	e8 d2 f0 ff ff       	call   f01008e2 <check_va2pa>
f0101810:	89 c5                	mov    %eax,%ebp
f0101812:	89 d8                	mov    %ebx,%eax
f0101814:	e8 3f f0 ff ff       	call   f0100858 <page2pa>
f0101819:	39 c5                	cmp    %eax,%ebp
f010181b:	74 14                	je     f0101831 <mem_init+0x9c4>
f010181d:	68 d1 3b 10 f0       	push   $0xf0103bd1
f0101822:	68 73 35 10 f0       	push   $0xf0103573
f0101827:	68 45 03 00 00       	push   $0x345
f010182c:	e9 77 f7 ff ff       	jmp    f0100fa8 <mem_init+0x13b>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0101831:	a1 48 0e 11 f0       	mov    0xf0110e48,%eax
f0101836:	ba 00 10 00 00       	mov    $0x1000,%edx
f010183b:	e8 a2 f0 ff ff       	call   f01008e2 <check_va2pa>
f0101840:	89 c5                	mov    %eax,%ebp
f0101842:	89 d8                	mov    %ebx,%eax
f0101844:	e8 0f f0 ff ff       	call   f0100858 <page2pa>
f0101849:	39 c5                	cmp    %eax,%ebp
f010184b:	74 14                	je     f0101861 <mem_init+0x9f4>
f010184d:	68 fc 3b 10 f0       	push   $0xf0103bfc
f0101852:	68 73 35 10 f0       	push   $0xf0103573
f0101857:	68 46 03 00 00       	push   $0x346
f010185c:	e9 47 f7 ff ff       	jmp    f0100fa8 <mem_init+0x13b>
	// ... and ref counts should reflect this
	assert(pp1->pp_ref == 2);
f0101861:	66 83 7b 04 02       	cmpw   $0x2,0x4(%ebx)
f0101866:	74 14                	je     f010187c <mem_init+0xa0f>
f0101868:	68 2c 3c 10 f0       	push   $0xf0103c2c
f010186d:	68 73 35 10 f0       	push   $0xf0103573
f0101872:	68 48 03 00 00       	push   $0x348
f0101877:	e9 2c f7 ff ff       	jmp    f0100fa8 <mem_init+0x13b>
	assert(pp2->pp_ref == 0);
f010187c:	66 83 7f 04 00       	cmpw   $0x0,0x4(%edi)
f0101881:	74 14                	je     f0101897 <mem_init+0xa2a>
f0101883:	68 3d 3c 10 f0       	push   $0xf0103c3d
f0101888:	68 73 35 10 f0       	push   $0xf0103573
f010188d:	68 49 03 00 00       	push   $0x349
f0101892:	e9 11 f7 ff ff       	jmp    f0100fa8 <mem_init+0x13b>

	// pp2 should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp2);
f0101897:	83 ec 0c             	sub    $0xc,%esp
f010189a:	6a 00                	push   $0x0
f010189c:	e8 87 f3 ff ff       	call   f0100c28 <page_alloc>
f01018a1:	83 c4 10             	add    $0x10,%esp
f01018a4:	85 c0                	test   %eax,%eax
f01018a6:	89 c5                	mov    %eax,%ebp
f01018a8:	74 04                	je     f01018ae <mem_init+0xa41>
f01018aa:	39 f8                	cmp    %edi,%eax
f01018ac:	74 14                	je     f01018c2 <mem_init+0xa55>
f01018ae:	68 4e 3c 10 f0       	push   $0xf0103c4e
f01018b3:	68 73 35 10 f0       	push   $0xf0103573
f01018b8:	68 4c 03 00 00       	push   $0x34c
f01018bd:	e9 e6 f6 ff ff       	jmp    f0100fa8 <mem_init+0x13b>

	// unmapping pp1 at 0 should keep pp1 at PGSIZE
	page_remove(kern_pgdir, 0x0);
f01018c2:	50                   	push   %eax
f01018c3:	50                   	push   %eax
f01018c4:	6a 00                	push   $0x0
f01018c6:	ff 35 48 0e 11 f0    	pushl  0xf0110e48
f01018cc:	e8 05 f5 ff ff       	call   f0100dd6 <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f01018d1:	a1 48 0e 11 f0       	mov    0xf0110e48,%eax
f01018d6:	31 d2                	xor    %edx,%edx
f01018d8:	e8 05 f0 ff ff       	call   f01008e2 <check_va2pa>
f01018dd:	83 c4 10             	add    $0x10,%esp
f01018e0:	40                   	inc    %eax
f01018e1:	74 14                	je     f01018f7 <mem_init+0xa8a>
f01018e3:	68 70 3c 10 f0       	push   $0xf0103c70
f01018e8:	68 73 35 10 f0       	push   $0xf0103573
f01018ed:	68 50 03 00 00       	push   $0x350
f01018f2:	e9 b1 f6 ff ff       	jmp    f0100fa8 <mem_init+0x13b>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f01018f7:	a1 48 0e 11 f0       	mov    0xf0110e48,%eax
f01018fc:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101901:	e8 dc ef ff ff       	call   f01008e2 <check_va2pa>
f0101906:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010190a:	89 d8                	mov    %ebx,%eax
f010190c:	e8 47 ef ff ff       	call   f0100858 <page2pa>
f0101911:	39 44 24 0c          	cmp    %eax,0xc(%esp)
f0101915:	74 14                	je     f010192b <mem_init+0xabe>
f0101917:	68 fc 3b 10 f0       	push   $0xf0103bfc
f010191c:	68 73 35 10 f0       	push   $0xf0103573
f0101921:	68 51 03 00 00       	push   $0x351
f0101926:	e9 7d f6 ff ff       	jmp    f0100fa8 <mem_init+0x13b>
	assert(pp1->pp_ref == 1);
f010192b:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0101930:	74 14                	je     f0101946 <mem_init+0xad9>
f0101932:	68 96 39 10 f0       	push   $0xf0103996
f0101937:	68 73 35 10 f0       	push   $0xf0103573
f010193c:	68 52 03 00 00       	push   $0x352
f0101941:	e9 62 f6 ff ff       	jmp    f0100fa8 <mem_init+0x13b>
	assert(pp2->pp_ref == 0);
f0101946:	66 83 7f 04 00       	cmpw   $0x0,0x4(%edi)
f010194b:	74 14                	je     f0101961 <mem_init+0xaf4>
f010194d:	68 3d 3c 10 f0       	push   $0xf0103c3d
f0101952:	68 73 35 10 f0       	push   $0xf0103573
f0101957:	68 53 03 00 00       	push   $0x353
f010195c:	e9 47 f6 ff ff       	jmp    f0100fa8 <mem_init+0x13b>

	// test re-inserting pp1 at PGSIZE
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, 0) == 0);
f0101961:	6a 00                	push   $0x0
f0101963:	68 00 10 00 00       	push   $0x1000
f0101968:	53                   	push   %ebx
f0101969:	ff 35 48 0e 11 f0    	pushl  0xf0110e48
f010196f:	e8 9e f4 ff ff       	call   f0100e12 <page_insert>
f0101974:	83 c4 10             	add    $0x10,%esp
f0101977:	85 c0                	test   %eax,%eax
f0101979:	74 14                	je     f010198f <mem_init+0xb22>
f010197b:	68 93 3c 10 f0       	push   $0xf0103c93
f0101980:	68 73 35 10 f0       	push   $0xf0103573
f0101985:	68 56 03 00 00       	push   $0x356
f010198a:	e9 19 f6 ff ff       	jmp    f0100fa8 <mem_init+0x13b>
	assert(pp1->pp_ref);
f010198f:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f0101994:	75 14                	jne    f01019aa <mem_init+0xb3d>
f0101996:	68 c8 3c 10 f0       	push   $0xf0103cc8
f010199b:	68 73 35 10 f0       	push   $0xf0103573
f01019a0:	68 57 03 00 00       	push   $0x357
f01019a5:	e9 fe f5 ff ff       	jmp    f0100fa8 <mem_init+0x13b>
	assert(pp1->pp_link == NULL);
f01019aa:	83 3b 00             	cmpl   $0x0,(%ebx)
f01019ad:	74 14                	je     f01019c3 <mem_init+0xb56>
f01019af:	68 d4 3c 10 f0       	push   $0xf0103cd4
f01019b4:	68 73 35 10 f0       	push   $0xf0103573
f01019b9:	68 58 03 00 00       	push   $0x358
f01019be:	e9 e5 f5 ff ff       	jmp    f0100fa8 <mem_init+0x13b>

	// unmapping pp1 at PGSIZE should free it
	page_remove(kern_pgdir, (void*) PGSIZE);
f01019c3:	51                   	push   %ecx
f01019c4:	51                   	push   %ecx
f01019c5:	68 00 10 00 00       	push   $0x1000
f01019ca:	ff 35 48 0e 11 f0    	pushl  0xf0110e48
f01019d0:	e8 01 f4 ff ff       	call   f0100dd6 <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f01019d5:	a1 48 0e 11 f0       	mov    0xf0110e48,%eax
f01019da:	31 d2                	xor    %edx,%edx
f01019dc:	e8 01 ef ff ff       	call   f01008e2 <check_va2pa>
f01019e1:	83 c4 10             	add    $0x10,%esp
f01019e4:	40                   	inc    %eax
f01019e5:	74 14                	je     f01019fb <mem_init+0xb8e>
f01019e7:	68 70 3c 10 f0       	push   $0xf0103c70
f01019ec:	68 73 35 10 f0       	push   $0xf0103573
f01019f1:	68 5c 03 00 00       	push   $0x35c
f01019f6:	e9 ad f5 ff ff       	jmp    f0100fa8 <mem_init+0x13b>
	assert(check_va2pa(kern_pgdir, PGSIZE) == ~0);
f01019fb:	a1 48 0e 11 f0       	mov    0xf0110e48,%eax
f0101a00:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101a05:	e8 d8 ee ff ff       	call   f01008e2 <check_va2pa>
f0101a0a:	40                   	inc    %eax
f0101a0b:	74 14                	je     f0101a21 <mem_init+0xbb4>
f0101a0d:	68 e9 3c 10 f0       	push   $0xf0103ce9
f0101a12:	68 73 35 10 f0       	push   $0xf0103573
f0101a17:	68 5d 03 00 00       	push   $0x35d
f0101a1c:	e9 87 f5 ff ff       	jmp    f0100fa8 <mem_init+0x13b>
	assert(pp1->pp_ref == 0);
f0101a21:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f0101a26:	74 14                	je     f0101a3c <mem_init+0xbcf>
f0101a28:	68 0f 3d 10 f0       	push   $0xf0103d0f
f0101a2d:	68 73 35 10 f0       	push   $0xf0103573
f0101a32:	68 5e 03 00 00       	push   $0x35e
f0101a37:	e9 6c f5 ff ff       	jmp    f0100fa8 <mem_init+0x13b>
	assert(pp2->pp_ref == 0);
f0101a3c:	66 83 7d 04 00       	cmpw   $0x0,0x4(%ebp)
f0101a41:	74 14                	je     f0101a57 <mem_init+0xbea>
f0101a43:	68 3d 3c 10 f0       	push   $0xf0103c3d
f0101a48:	68 73 35 10 f0       	push   $0xf0103573
f0101a4d:	68 5f 03 00 00       	push   $0x35f
f0101a52:	e9 51 f5 ff ff       	jmp    f0100fa8 <mem_init+0x13b>

	// so it should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp1);
f0101a57:	83 ec 0c             	sub    $0xc,%esp
f0101a5a:	6a 00                	push   $0x0
f0101a5c:	e8 c7 f1 ff ff       	call   f0100c28 <page_alloc>
f0101a61:	83 c4 10             	add    $0x10,%esp
f0101a64:	85 c0                	test   %eax,%eax
f0101a66:	89 c7                	mov    %eax,%edi
f0101a68:	74 04                	je     f0101a6e <mem_init+0xc01>
f0101a6a:	39 d8                	cmp    %ebx,%eax
f0101a6c:	74 14                	je     f0101a82 <mem_init+0xc15>
f0101a6e:	68 20 3d 10 f0       	push   $0xf0103d20
f0101a73:	68 73 35 10 f0       	push   $0xf0103573
f0101a78:	68 62 03 00 00       	push   $0x362
f0101a7d:	e9 26 f5 ff ff       	jmp    f0100fa8 <mem_init+0x13b>

	// should be no free memory
	assert(!page_alloc(0));
f0101a82:	83 ec 0c             	sub    $0xc,%esp
f0101a85:	6a 00                	push   $0x0
f0101a87:	e8 9c f1 ff ff       	call   f0100c28 <page_alloc>
f0101a8c:	83 c4 10             	add    $0x10,%esp
f0101a8f:	85 c0                	test   %eax,%eax
f0101a91:	74 14                	je     f0101aa7 <mem_init+0xc3a>
f0101a93:	68 40 38 10 f0       	push   $0xf0103840
f0101a98:	68 73 35 10 f0       	push   $0xf0103573
f0101a9d:	68 65 03 00 00       	push   $0x365
f0101aa2:	e9 01 f5 ff ff       	jmp    f0100fa8 <mem_init+0x13b>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0101aa7:	8b 1d 48 0e 11 f0    	mov    0xf0110e48,%ebx
f0101aad:	89 f0                	mov    %esi,%eax
f0101aaf:	e8 a4 ed ff ff       	call   f0100858 <page2pa>
f0101ab4:	8b 13                	mov    (%ebx),%edx
f0101ab6:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0101abc:	39 c2                	cmp    %eax,%edx
f0101abe:	74 14                	je     f0101ad4 <mem_init+0xc67>
f0101ac0:	68 41 39 10 f0       	push   $0xf0103941
f0101ac5:	68 73 35 10 f0       	push   $0xf0103573
f0101aca:	68 68 03 00 00       	push   $0x368
f0101acf:	e9 d4 f4 ff ff       	jmp    f0100fa8 <mem_init+0x13b>
	kern_pgdir[0] = 0;
	assert(pp0->pp_ref == 1);
f0101ad4:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
	// should be no free memory
	assert(!page_alloc(0));

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
	kern_pgdir[0] = 0;
f0101ad9:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	assert(pp0->pp_ref == 1);
f0101adf:	74 14                	je     f0101af5 <mem_init+0xc88>
f0101ae1:	68 a7 39 10 f0       	push   $0xf01039a7
f0101ae6:	68 73 35 10 f0       	push   $0xf0103573
f0101aeb:	68 6a 03 00 00       	push   $0x36a
f0101af0:	e9 b3 f4 ff ff       	jmp    f0100fa8 <mem_init+0x13b>
	pp0->pp_ref = 0;

	// check pointer arithmetic in pgdir_walk
	page_free(pp0);
f0101af5:	83 ec 0c             	sub    $0xc,%esp

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
	kern_pgdir[0] = 0;
	assert(pp0->pp_ref == 1);
	pp0->pp_ref = 0;
f0101af8:	66 c7 46 04 00 00    	movw   $0x0,0x4(%esi)

	// check pointer arithmetic in pgdir_walk
	page_free(pp0);
f0101afe:	56                   	push   %esi
f0101aff:	e8 65 f1 ff ff       	call   f0100c69 <page_free>
	va = (void*)(PGSIZE * NPDENTRIES + PGSIZE);
	ptep = pgdir_walk(kern_pgdir, va, 1);
f0101b04:	83 c4 0c             	add    $0xc,%esp
f0101b07:	6a 01                	push   $0x1
f0101b09:	68 00 10 40 00       	push   $0x401000
f0101b0e:	ff 35 48 0e 11 f0    	pushl  0xf0110e48
f0101b14:	e8 a9 f1 ff ff       	call   f0100cc2 <pgdir_walk>
	ptep1 = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(va)]));
f0101b19:	ba 71 03 00 00       	mov    $0x371,%edx
	pp0->pp_ref = 0;

	// check pointer arithmetic in pgdir_walk
	page_free(pp0);
	va = (void*)(PGSIZE * NPDENTRIES + PGSIZE);
	ptep = pgdir_walk(kern_pgdir, va, 1);
f0101b1e:	89 44 24 2c          	mov    %eax,0x2c(%esp)
	ptep1 = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(va)]));
f0101b22:	a1 48 0e 11 f0       	mov    0xf0110e48,%eax
f0101b27:	8b 48 04             	mov    0x4(%eax),%ecx
f0101b2a:	b8 36 35 10 f0       	mov    $0xf0103536,%eax
f0101b2f:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
f0101b35:	e8 66 ed ff ff       	call   f01008a0 <_kaddr>
	assert(ptep == ptep1 + PTX(va));
f0101b3a:	83 c4 10             	add    $0x10,%esp
f0101b3d:	83 c0 04             	add    $0x4,%eax
f0101b40:	39 44 24 1c          	cmp    %eax,0x1c(%esp)
f0101b44:	74 14                	je     f0101b5a <mem_init+0xced>
f0101b46:	68 42 3d 10 f0       	push   $0xf0103d42
f0101b4b:	68 73 35 10 f0       	push   $0xf0103573
f0101b50:	68 72 03 00 00       	push   $0x372
f0101b55:	e9 4e f4 ff ff       	jmp    f0100fa8 <mem_init+0x13b>
	kern_pgdir[PDX(va)] = 0;
f0101b5a:	a1 48 0e 11 f0       	mov    0xf0110e48,%eax
f0101b5f:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
	pp0->pp_ref = 0;

	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
f0101b66:	89 f0                	mov    %esi,%eax
	va = (void*)(PGSIZE * NPDENTRIES + PGSIZE);
	ptep = pgdir_walk(kern_pgdir, va, 1);
	ptep1 = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(va)]));
	assert(ptep == ptep1 + PTX(va));
	kern_pgdir[PDX(va)] = 0;
	pp0->pp_ref = 0;
f0101b68:	66 c7 46 04 00 00    	movw   $0x0,0x4(%esi)

	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
f0101b6e:	e8 56 ed ff ff       	call   f01008c9 <page2kva>
f0101b73:	52                   	push   %edx
f0101b74:	68 00 10 00 00       	push   $0x1000
f0101b79:	68 ff 00 00 00       	push   $0xff
f0101b7e:	50                   	push   %eax
f0101b7f:	e8 3b 0f 00 00       	call   f0102abf <memset>
	page_free(pp0);
f0101b84:	89 34 24             	mov    %esi,(%esp)
f0101b87:	e8 dd f0 ff ff       	call   f0100c69 <page_free>
	pgdir_walk(kern_pgdir, 0x0, 1);
f0101b8c:	83 c4 0c             	add    $0xc,%esp
f0101b8f:	6a 01                	push   $0x1
f0101b91:	6a 00                	push   $0x0
f0101b93:	ff 35 48 0e 11 f0    	pushl  0xf0110e48
f0101b99:	e8 24 f1 ff ff       	call   f0100cc2 <pgdir_walk>
	ptep = (pte_t *) page2kva(pp0);
f0101b9e:	89 f0                	mov    %esi,%eax
f0101ba0:	e8 24 ed ff ff       	call   f01008c9 <page2kva>
	for(i=0; i<NPTENTRIES; i++)
f0101ba5:	31 d2                	xor    %edx,%edx

	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
	page_free(pp0);
	pgdir_walk(kern_pgdir, 0x0, 1);
	ptep = (pte_t *) page2kva(pp0);
f0101ba7:	89 44 24 2c          	mov    %eax,0x2c(%esp)
f0101bab:	83 c4 10             	add    $0x10,%esp
	for(i=0; i<NPTENTRIES; i++)
		assert((ptep[i] & PTE_P) == 0);
f0101bae:	f6 04 90 01          	testb  $0x1,(%eax,%edx,4)
f0101bb2:	74 14                	je     f0101bc8 <mem_init+0xd5b>
f0101bb4:	68 5a 3d 10 f0       	push   $0xf0103d5a
f0101bb9:	68 73 35 10 f0       	push   $0xf0103573
f0101bbe:	68 7c 03 00 00       	push   $0x37c
f0101bc3:	e9 e0 f3 ff ff       	jmp    f0100fa8 <mem_init+0x13b>
	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
	page_free(pp0);
	pgdir_walk(kern_pgdir, 0x0, 1);
	ptep = (pte_t *) page2kva(pp0);
	for(i=0; i<NPTENTRIES; i++)
f0101bc8:	42                   	inc    %edx
f0101bc9:	81 fa 00 04 00 00    	cmp    $0x400,%edx
f0101bcf:	75 dd                	jne    f0101bae <mem_init+0xd41>
		assert((ptep[i] & PTE_P) == 0);
	kern_pgdir[0] = 0;
f0101bd1:	a1 48 0e 11 f0       	mov    0xf0110e48,%eax
f0101bd6:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	pp0->pp_ref = 0;

	// give free list back
	page_free_list = fl;
f0101bdc:	8b 44 24 08          	mov    0x8(%esp),%eax

	// free the pages we took
	page_free(pp0);
f0101be0:	83 ec 0c             	sub    $0xc,%esp
	pgdir_walk(kern_pgdir, 0x0, 1);
	ptep = (pte_t *) page2kva(pp0);
	for(i=0; i<NPTENTRIES; i++)
		assert((ptep[i] & PTE_P) == 0);
	kern_pgdir[0] = 0;
	pp0->pp_ref = 0;
f0101be3:	66 c7 46 04 00 00    	movw   $0x0,0x4(%esi)

	// give free list back
	page_free_list = fl;

	// free the pages we took
	page_free(pp0);
f0101be9:	56                   	push   %esi
		assert((ptep[i] & PTE_P) == 0);
	kern_pgdir[0] = 0;
	pp0->pp_ref = 0;

	// give free list back
	page_free_list = fl;
f0101bea:	a3 1c 02 11 f0       	mov    %eax,0xf011021c

	// free the pages we took
	page_free(pp0);
f0101bef:	e8 75 f0 ff ff       	call   f0100c69 <page_free>
	page_free(pp1);
f0101bf4:	89 3c 24             	mov    %edi,(%esp)
f0101bf7:	e8 6d f0 ff ff       	call   f0100c69 <page_free>
	page_free(pp2);
f0101bfc:	89 2c 24             	mov    %ebp,(%esp)
f0101bff:	e8 65 f0 ff ff       	call   f0100c69 <page_free>

	cprintf("check_page() succeeded!\n");
f0101c04:	c7 04 24 71 3d 10 f0 	movl   $0xf0103d71,(%esp)
f0101c0b:	e8 2e ec ff ff       	call   f010083e <cprintf>
	// Permissions:
	//    - the new image at UPAGES -- kernel R, user R
	//      (ie. perm = PTE_U | PTE_P)
	//    - pages itself -- kernel RW, user NONE
	// Your code goes here:
    boot_map_region(kern_pgdir, UPAGES, ROUNDUP((sizeof(struct PageInfo) * npages), PGSIZE), PADDR(pages), (PTE_U | PTE_P));
f0101c10:	8b 15 4c 0e 11 f0    	mov    0xf0110e4c,%edx
f0101c16:	b8 b0 00 00 00       	mov    $0xb0,%eax
f0101c1b:	e8 46 ef ff ff       	call   f0100b66 <_paddr.clone.0>
f0101c20:	8b 15 44 0e 11 f0    	mov    0xf0110e44,%edx
f0101c26:	5e                   	pop    %esi
f0101c27:	5f                   	pop    %edi
f0101c28:	8d 0c d5 ff 0f 00 00 	lea    0xfff(,%edx,8),%ecx
f0101c2f:	ba 00 00 00 ef       	mov    $0xef000000,%edx
f0101c34:	6a 05                	push   $0x5
f0101c36:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
f0101c3c:	50                   	push   %eax
f0101c3d:	a1 48 0e 11 f0       	mov    0xf0110e48,%eax
f0101c42:	e8 e8 f0 ff ff       	call   f0100d2f <boot_map_region>
	//       the kernel overflows its stack, it will fault rather than
	//       overwrite memory.  Known as a "guard page".
	//     Permissions: kernel RW, user NONE
	// Your code goes here:
    /* TODO */
    boot_map_region(kern_pgdir,KSTACKTOP - KSTKSIZE,KSTKSIZE,PADDR(bootstack),PTE_W);
f0101c47:	ba 00 80 10 f0       	mov    $0xf0108000,%edx
f0101c4c:	b8 bf 00 00 00       	mov    $0xbf,%eax
f0101c51:	e8 10 ef ff ff       	call   f0100b66 <_paddr.clone.0>
f0101c56:	ba 00 80 ff ef       	mov    $0xefff8000,%edx
f0101c5b:	59                   	pop    %ecx
f0101c5c:	b9 00 80 00 00       	mov    $0x8000,%ecx
f0101c61:	5b                   	pop    %ebx
f0101c62:	6a 02                	push   $0x2
f0101c64:	50                   	push   %eax
f0101c65:	a1 48 0e 11 f0       	mov    0xf0110e48,%eax
f0101c6a:	e8 c0 f0 ff ff       	call   f0100d2f <boot_map_region>
	// We might not have 2^32 - KERNBASE bytes of physical memory, but
	// we just set up the mapping anyway.
	// Permissions: kernel RW, user NONE
	// Your code goes here:
    /* TODO */
    boot_map_region(kern_pgdir,KERNBASE,0xffffffff-KERNBASE,0,PTE_W);
f0101c6f:	b9 ff ff ff 0f       	mov    $0xfffffff,%ecx
f0101c74:	58                   	pop    %eax
f0101c75:	5a                   	pop    %edx
f0101c76:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
f0101c7b:	a1 48 0e 11 f0       	mov    0xf0110e48,%eax
f0101c80:	6a 02                	push   $0x2
f0101c82:	6a 00                	push   $0x0
f0101c84:	e8 a6 f0 ff ff       	call   f0100d2f <boot_map_region>
	//////////////////////////////////////////////////////////////////////
	// Map VA range [IOPHYSMEM, EXTPHYSMEM) to PA range [IOPHYSMEM, EXTPHYSMEM)
    boot_map_region(kern_pgdir, IOPHYSMEM, ROUNDUP((EXTPHYSMEM - IOPHYSMEM), PGSIZE), IOPHYSMEM, (PTE_W) | (PTE_P));
f0101c89:	a1 48 0e 11 f0       	mov    0xf0110e48,%eax
f0101c8e:	b9 00 00 06 00       	mov    $0x60000,%ecx
f0101c93:	5f                   	pop    %edi
f0101c94:	ba 00 00 0a 00       	mov    $0xa0000,%edx
f0101c99:	5d                   	pop    %ebp
f0101c9a:	6a 03                	push   $0x3
f0101c9c:	68 00 00 0a 00       	push   $0xa0000
f0101ca1:	e8 89 f0 ff ff       	call   f0100d2f <boot_map_region>
	// somewhere between KERNBASE and KERNBASE+4MB right now, which is
	// mapped the same way by both page tables.
	//
	// If the machine reboots at this point, you've probably set up your
	// kern_pgdir wrong.
	lcr3(PADDR(kern_pgdir));
f0101ca6:	8b 15 48 0e 11 f0    	mov    0xf0110e48,%edx
f0101cac:	b8 d8 00 00 00       	mov    $0xd8,%eax
f0101cb1:	e8 b0 ee ff ff       	call   f0100b66 <_paddr.clone.0>
}

static __inline void
lcr3(uint32_t val)
{
	__asm __volatile("movl %0,%%cr3" : : "r" (val));
f0101cb6:	0f 22 d8             	mov    %eax,%cr3

	check_page_free_list(0);
f0101cb9:	31 c0                	xor    %eax,%eax
f0101cbb:	e8 6d ec ff ff       	call   f010092d <check_page_free_list>

static __inline uint32_t
rcr0(void)
{
	uint32_t val;
	__asm __volatile("movl %%cr0,%0" : "=r" (val));
f0101cc0:	0f 20 c0             	mov    %cr0,%eax

	// entry.S set the really important flags in cr0 (including enabling
	// paging).  Here we configure the rest of the flags that we care about.
	cr0 = rcr0();
	cr0 |= CR0_PE|CR0_PG|CR0_AM|CR0_WP|CR0_NE|CR0_MP;
f0101cc3:	0d 23 00 05 80       	or     $0x80050023,%eax
	cr0 &= ~(CR0_TS|CR0_EM);
f0101cc8:	83 e0 f3             	and    $0xfffffff3,%eax
}

static __inline void
lcr0(uint32_t val)
{
	__asm __volatile("movl %0,%%cr0" : : "r" (val));
f0101ccb:	0f 22 c0             	mov    %eax,%cr0
	uintptr_t va;
	int i;

	// check that we can read and write installed pages
	pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0101cce:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101cd5:	e8 4e ef ff ff       	call   f0100c28 <page_alloc>
f0101cda:	83 c4 10             	add    $0x10,%esp
f0101cdd:	85 c0                	test   %eax,%eax
f0101cdf:	89 c7                	mov    %eax,%edi
f0101ce1:	75 14                	jne    f0101cf7 <mem_init+0xe8a>
f0101ce3:	68 75 37 10 f0       	push   $0xf0103775
f0101ce8:	68 73 35 10 f0       	push   $0xf0103573
f0101ced:	68 97 03 00 00       	push   $0x397
f0101cf2:	e9 b1 f2 ff ff       	jmp    f0100fa8 <mem_init+0x13b>
	assert((pp1 = page_alloc(0)));
f0101cf7:	83 ec 0c             	sub    $0xc,%esp
f0101cfa:	6a 00                	push   $0x0
f0101cfc:	e8 27 ef ff ff       	call   f0100c28 <page_alloc>
f0101d01:	83 c4 10             	add    $0x10,%esp
f0101d04:	85 c0                	test   %eax,%eax
f0101d06:	89 c6                	mov    %eax,%esi
f0101d08:	75 14                	jne    f0101d1e <mem_init+0xeb1>
f0101d0a:	68 8b 37 10 f0       	push   $0xf010378b
f0101d0f:	68 73 35 10 f0       	push   $0xf0103573
f0101d14:	68 98 03 00 00       	push   $0x398
f0101d19:	e9 8a f2 ff ff       	jmp    f0100fa8 <mem_init+0x13b>
	assert((pp2 = page_alloc(0)));
f0101d1e:	83 ec 0c             	sub    $0xc,%esp
f0101d21:	6a 00                	push   $0x0
f0101d23:	e8 00 ef ff ff       	call   f0100c28 <page_alloc>
f0101d28:	83 c4 10             	add    $0x10,%esp
f0101d2b:	85 c0                	test   %eax,%eax
f0101d2d:	89 c3                	mov    %eax,%ebx
f0101d2f:	75 14                	jne    f0101d45 <mem_init+0xed8>
f0101d31:	68 a1 37 10 f0       	push   $0xf01037a1
f0101d36:	68 73 35 10 f0       	push   $0xf0103573
f0101d3b:	68 99 03 00 00       	push   $0x399
f0101d40:	e9 63 f2 ff ff       	jmp    f0100fa8 <mem_init+0x13b>
	page_free(pp0);
f0101d45:	83 ec 0c             	sub    $0xc,%esp
f0101d48:	57                   	push   %edi
f0101d49:	e8 1b ef ff ff       	call   f0100c69 <page_free>
	memset(page2kva(pp1), 1, PGSIZE);
f0101d4e:	89 f0                	mov    %esi,%eax
f0101d50:	e8 74 eb ff ff       	call   f01008c9 <page2kva>
f0101d55:	83 c4 0c             	add    $0xc,%esp
f0101d58:	68 00 10 00 00       	push   $0x1000
f0101d5d:	6a 01                	push   $0x1
f0101d5f:	50                   	push   %eax
f0101d60:	e8 5a 0d 00 00       	call   f0102abf <memset>
	memset(page2kva(pp2), 2, PGSIZE);
f0101d65:	89 d8                	mov    %ebx,%eax
f0101d67:	e8 5d eb ff ff       	call   f01008c9 <page2kva>
f0101d6c:	83 c4 0c             	add    $0xc,%esp
f0101d6f:	68 00 10 00 00       	push   $0x1000
f0101d74:	6a 02                	push   $0x2
f0101d76:	50                   	push   %eax
f0101d77:	e8 43 0d 00 00       	call   f0102abf <memset>
	page_insert(kern_pgdir, pp1, (void*) EXTPHYSMEM, PTE_W);
f0101d7c:	6a 02                	push   $0x2
f0101d7e:	68 00 00 10 00       	push   $0x100000
f0101d83:	56                   	push   %esi
f0101d84:	ff 35 48 0e 11 f0    	pushl  0xf0110e48
f0101d8a:	e8 83 f0 ff ff       	call   f0100e12 <page_insert>
	assert(pp1->pp_ref == 1);
f0101d8f:	83 c4 20             	add    $0x20,%esp
f0101d92:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0101d97:	74 14                	je     f0101dad <mem_init+0xf40>
f0101d99:	68 96 39 10 f0       	push   $0xf0103996
f0101d9e:	68 73 35 10 f0       	push   $0xf0103573
f0101da3:	68 9e 03 00 00       	push   $0x39e
f0101da8:	e9 fb f1 ff ff       	jmp    f0100fa8 <mem_init+0x13b>
	assert(*(uint32_t *)EXTPHYSMEM == 0x01010101U);
f0101dad:	81 3d 00 00 10 00 01 	cmpl   $0x1010101,0x100000
f0101db4:	01 01 01 
f0101db7:	74 14                	je     f0101dcd <mem_init+0xf60>
f0101db9:	68 8a 3d 10 f0       	push   $0xf0103d8a
f0101dbe:	68 73 35 10 f0       	push   $0xf0103573
f0101dc3:	68 9f 03 00 00       	push   $0x39f
f0101dc8:	e9 db f1 ff ff       	jmp    f0100fa8 <mem_init+0x13b>
	page_insert(kern_pgdir, pp2, (void*) EXTPHYSMEM, PTE_W);
f0101dcd:	6a 02                	push   $0x2
f0101dcf:	68 00 00 10 00       	push   $0x100000
f0101dd4:	53                   	push   %ebx
f0101dd5:	ff 35 48 0e 11 f0    	pushl  0xf0110e48
f0101ddb:	e8 32 f0 ff ff       	call   f0100e12 <page_insert>
	assert(*(uint32_t *)EXTPHYSMEM == 0x02020202U);
f0101de0:	83 c4 10             	add    $0x10,%esp
f0101de3:	81 3d 00 00 10 00 02 	cmpl   $0x2020202,0x100000
f0101dea:	02 02 02 
f0101ded:	74 14                	je     f0101e03 <mem_init+0xf96>
f0101def:	68 b1 3d 10 f0       	push   $0xf0103db1
f0101df4:	68 73 35 10 f0       	push   $0xf0103573
f0101df9:	68 a1 03 00 00       	push   $0x3a1
f0101dfe:	e9 a5 f1 ff ff       	jmp    f0100fa8 <mem_init+0x13b>
	assert(pp2->pp_ref == 1);
f0101e03:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0101e08:	74 14                	je     f0101e1e <mem_init+0xfb1>
f0101e0a:	68 21 3a 10 f0       	push   $0xf0103a21
f0101e0f:	68 73 35 10 f0       	push   $0xf0103573
f0101e14:	68 a2 03 00 00       	push   $0x3a2
f0101e19:	e9 8a f1 ff ff       	jmp    f0100fa8 <mem_init+0x13b>
	assert(pp1->pp_ref == 0);
f0101e1e:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0101e23:	74 14                	je     f0101e39 <mem_init+0xfcc>
f0101e25:	68 0f 3d 10 f0       	push   $0xf0103d0f
f0101e2a:	68 73 35 10 f0       	push   $0xf0103573
f0101e2f:	68 a3 03 00 00       	push   $0x3a3
f0101e34:	e9 6f f1 ff ff       	jmp    f0100fa8 <mem_init+0x13b>
	*(uint32_t *)EXTPHYSMEM = 0x03030303U;
	assert(*(uint32_t *)page2kva(pp2) == 0x03030303U);
f0101e39:	89 d8                	mov    %ebx,%eax
	assert(*(uint32_t *)EXTPHYSMEM == 0x01010101U);
	page_insert(kern_pgdir, pp2, (void*) EXTPHYSMEM, PTE_W);
	assert(*(uint32_t *)EXTPHYSMEM == 0x02020202U);
	assert(pp2->pp_ref == 1);
	assert(pp1->pp_ref == 0);
	*(uint32_t *)EXTPHYSMEM = 0x03030303U;
f0101e3b:	c7 05 00 00 10 00 03 	movl   $0x3030303,0x100000
f0101e42:	03 03 03 
	assert(*(uint32_t *)page2kva(pp2) == 0x03030303U);
f0101e45:	e8 7f ea ff ff       	call   f01008c9 <page2kva>
f0101e4a:	81 38 03 03 03 03    	cmpl   $0x3030303,(%eax)
f0101e50:	74 14                	je     f0101e66 <mem_init+0xff9>
f0101e52:	68 d8 3d 10 f0       	push   $0xf0103dd8
f0101e57:	68 73 35 10 f0       	push   $0xf0103573
f0101e5c:	68 a5 03 00 00       	push   $0x3a5
f0101e61:	e9 42 f1 ff ff       	jmp    f0100fa8 <mem_init+0x13b>
	page_remove(kern_pgdir, (void*) EXTPHYSMEM);
f0101e66:	56                   	push   %esi
f0101e67:	56                   	push   %esi
f0101e68:	68 00 00 10 00       	push   $0x100000
f0101e6d:	ff 35 48 0e 11 f0    	pushl  0xf0110e48
f0101e73:	e8 5e ef ff ff       	call   f0100dd6 <page_remove>
	assert(pp2->pp_ref == 0);
f0101e78:	83 c4 10             	add    $0x10,%esp
f0101e7b:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f0101e80:	74 14                	je     f0101e96 <mem_init+0x1029>
f0101e82:	68 3d 3c 10 f0       	push   $0xf0103c3d
f0101e87:	68 73 35 10 f0       	push   $0xf0103573
f0101e8c:	68 a7 03 00 00       	push   $0x3a7
f0101e91:	e9 12 f1 ff ff       	jmp    f0100fa8 <mem_init+0x13b>

	cprintf("check_page_installed_pgdir() succeeded!\n");
f0101e96:	83 ec 0c             	sub    $0xc,%esp
f0101e99:	68 02 3e 10 f0       	push   $0xf0103e02
f0101e9e:	e8 9b e9 ff ff       	call   f010083e <cprintf>
	cr0 &= ~(CR0_TS|CR0_EM);
	lcr0(cr0);

	// Some more checks, only possible after kern_pgdir is installed.
	check_page_installed_pgdir();
}
f0101ea3:	83 c4 3c             	add    $0x3c,%esp
f0101ea6:	5b                   	pop    %ebx
f0101ea7:	5e                   	pop    %esi
f0101ea8:	5f                   	pop    %edi
f0101ea9:	5d                   	pop    %ebp
f0101eaa:	c3                   	ret    

f0101eab <tlb_invalidate>:
}

static __inline void
invlpg(void *addr)
{
	__asm __volatile("invlpg (%0)" : : "r" (addr) : "memory");
f0101eab:	8b 44 24 08          	mov    0x8(%esp),%eax
f0101eaf:	0f 01 38             	invlpg (%eax)
tlb_invalidate(pde_t *pgdir, void *va)
{
	// Flush the entry only if we're modifying the current address space.
	// For now, there is only one address space, so always invalidate.
	invlpg(va);
}
f0101eb2:	c3                   	ret    
	...

f0101eb4 <_panic>:
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: mesg", and then enters the kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt,...)
{
f0101eb4:	56                   	push   %esi
f0101eb5:	53                   	push   %ebx
f0101eb6:	83 ec 04             	sub    $0x4,%esp
	va_list ap;

	if (panicstr)
f0101eb9:	83 3d 50 0e 11 f0 00 	cmpl   $0x0,0xf0110e50
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: mesg", and then enters the kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt,...)
{
f0101ec0:	8b 5c 24 18          	mov    0x18(%esp),%ebx
	va_list ap;

	if (panicstr)
f0101ec4:	75 37                	jne    f0101efd <_panic+0x49>
		goto dead;
	panicstr = fmt;
f0101ec6:	89 1d 50 0e 11 f0    	mov    %ebx,0xf0110e50

	// Be extra sure that the machine is in as reasonable state
	__asm __volatile("cli; cld");
f0101ecc:	fa                   	cli    
f0101ecd:	fc                   	cld    

	va_start(ap, fmt);
f0101ece:	8d 74 24 1c          	lea    0x1c(%esp),%esi
	cprintf("kernel panic at %s:%d: ", file, line);
f0101ed2:	51                   	push   %ecx
f0101ed3:	ff 74 24 18          	pushl  0x18(%esp)
f0101ed7:	ff 74 24 18          	pushl  0x18(%esp)
f0101edb:	68 2b 3e 10 f0       	push   $0xf0103e2b
f0101ee0:	e8 59 e9 ff ff       	call   f010083e <cprintf>
	vcprintf(fmt, ap);
f0101ee5:	58                   	pop    %eax
f0101ee6:	5a                   	pop    %edx
f0101ee7:	56                   	push   %esi
f0101ee8:	53                   	push   %ebx
f0101ee9:	e8 26 e9 ff ff       	call   f0100814 <vcprintf>
	cprintf("\n");
f0101eee:	c7 04 24 9a 32 10 f0 	movl   $0xf010329a,(%esp)
f0101ef5:	e8 44 e9 ff ff       	call   f010083e <cprintf>
	va_end(ap);
f0101efa:	83 c4 10             	add    $0x10,%esp
f0101efd:	eb fe                	jmp    f0101efd <_panic+0x49>

f0101eff <_warn>:
}

/* like panic, but don't */
void
_warn(const char *file, int line, const char *fmt,...)
{
f0101eff:	53                   	push   %ebx
f0101f00:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
f0101f03:	8d 5c 24 1c          	lea    0x1c(%esp),%ebx
	cprintf("kernel warning at %s:%d: ", file, line);
f0101f07:	51                   	push   %ecx
f0101f08:	ff 74 24 18          	pushl  0x18(%esp)
f0101f0c:	ff 74 24 18          	pushl  0x18(%esp)
f0101f10:	68 43 3e 10 f0       	push   $0xf0103e43
f0101f15:	e8 24 e9 ff ff       	call   f010083e <cprintf>
	vcprintf(fmt, ap);
f0101f1a:	58                   	pop    %eax
f0101f1b:	5a                   	pop    %edx
f0101f1c:	53                   	push   %ebx
f0101f1d:	ff 74 24 24          	pushl  0x24(%esp)
f0101f21:	e8 ee e8 ff ff       	call   f0100814 <vcprintf>
	cprintf("\n");
f0101f26:	c7 04 24 9a 32 10 f0 	movl   $0xf010329a,(%esp)
f0101f2d:	e8 0c e9 ff ff       	call   f010083e <cprintf>
	va_end(ap);
}
f0101f32:	83 c4 18             	add    $0x18,%esp
f0101f35:	5b                   	pop    %ebx
f0101f36:	c3                   	ret    
	...

f0101f38 <mc146818_read>:
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0101f38:	8b 44 24 04          	mov    0x4(%esp),%eax
f0101f3c:	ba 70 00 00 00       	mov    $0x70,%edx
f0101f41:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0101f42:	b2 71                	mov    $0x71,%dl
f0101f44:	ec                   	in     (%dx),%al

unsigned
mc146818_read(unsigned reg)
{
	outb(IO_RTC, reg);
	return inb(IO_RTC+1);
f0101f45:	0f b6 c0             	movzbl %al,%eax
}
f0101f48:	c3                   	ret    

f0101f49 <mc146818_write>:
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0101f49:	ba 70 00 00 00       	mov    $0x70,%edx
f0101f4e:	8b 44 24 04          	mov    0x4(%esp),%eax
f0101f52:	ee                   	out    %al,(%dx)
f0101f53:	b2 71                	mov    $0x71,%dl
f0101f55:	8b 44 24 08          	mov    0x8(%esp),%eax
f0101f59:	ee                   	out    %al,(%dx)
void
mc146818_write(unsigned reg, unsigned datum)
{
	outb(IO_RTC, reg);
	outb(IO_RTC+1, datum);
}
f0101f5a:	c3                   	ret    
	...

f0101f5c <mon_kerninfo>:
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
	return 0;
}

int mon_kerninfo(int argc, char **argv)
{
f0101f5c:	53                   	push   %ebx
   */
    extern int etext;
    extern int data_start;
    extern int end;
    extern int kernel_load_addr;
    cprintf("Kernel code base start=0x%10x size = %ld\n",&kernel_load_addr,(int)&etext-(int)&kernel_load_addr);
f0101f5d:	b8 85 2f 10 f0       	mov    $0xf0102f85,%eax
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
	return 0;
}

int mon_kerninfo(int argc, char **argv)
{
f0101f62:	83 ec 0c             	sub    $0xc,%esp
   */
    extern int etext;
    extern int data_start;
    extern int end;
    extern int kernel_load_addr;
    cprintf("Kernel code base start=0x%10x size = %ld\n",&kernel_load_addr,(int)&etext-(int)&kernel_load_addr);
f0101f65:	2d 00 00 10 f0       	sub    $0xf0100000,%eax
f0101f6a:	50                   	push   %eax
    cprintf("Kernel data base start=0x%10x size = %ld\n",&data_start,(int)&end-(int)&data_start);
f0101f6b:	bb 54 0e 11 f0       	mov    $0xf0110e54,%ebx
   */
    extern int etext;
    extern int data_start;
    extern int end;
    extern int kernel_load_addr;
    cprintf("Kernel code base start=0x%10x size = %ld\n",&kernel_load_addr,(int)&etext-(int)&kernel_load_addr);
f0101f70:	68 00 00 10 f0       	push   $0xf0100000
f0101f75:	68 5d 3e 10 f0       	push   $0xf0103e5d
f0101f7a:	e8 bf e8 ff ff       	call   f010083e <cprintf>
    cprintf("Kernel data base start=0x%10x size = %ld\n",&data_start,(int)&end-(int)&data_start);
f0101f7f:	89 d8                	mov    %ebx,%eax
f0101f81:	83 c4 0c             	add    $0xc,%esp
f0101f84:	2d 00 50 10 f0       	sub    $0xf0105000,%eax
f0101f89:	50                   	push   %eax
f0101f8a:	68 00 50 10 f0       	push   $0xf0105000
f0101f8f:	68 87 3e 10 f0       	push   $0xf0103e87
f0101f94:	e8 a5 e8 ff ff       	call   f010083e <cprintf>
    cprintf("Kernel executable memory footprint: %ldKB\n",((int)&end-(int)&kernel_load_addr)/1024);
f0101f99:	b9 00 04 00 00       	mov    $0x400,%ecx
f0101f9e:	58                   	pop    %eax
f0101f9f:	89 d8                	mov    %ebx,%eax
f0101fa1:	2d 00 00 10 f0       	sub    $0xf0100000,%eax
f0101fa6:	5a                   	pop    %edx
f0101fa7:	99                   	cltd   
f0101fa8:	f7 f9                	idiv   %ecx
f0101faa:	50                   	push   %eax
f0101fab:	68 b1 3e 10 f0       	push   $0xf0103eb1
f0101fb0:	e8 89 e8 ff ff       	call   f010083e <cprintf>
	return 0;
}
f0101fb5:	31 c0                	xor    %eax,%eax
f0101fb7:	83 c4 18             	add    $0x18,%esp
f0101fba:	5b                   	pop    %ebx
f0101fbb:	c3                   	ret    

f0101fbc <mon_help>:
}
#define NCOMMANDS (sizeof(commands)/sizeof(commands[0]))


int mon_help(int argc, char **argv)
{
f0101fbc:	83 ec 10             	sub    $0x10,%esp
	int i;

	for (i = 0; i < NCOMMANDS; i++)
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
f0101fbf:	68 dc 3e 10 f0       	push   $0xf0103edc
f0101fc4:	68 fa 3e 10 f0       	push   $0xf0103efa
f0101fc9:	68 ff 3e 10 f0       	push   $0xf0103eff
f0101fce:	e8 6b e8 ff ff       	call   f010083e <cprintf>
f0101fd3:	83 c4 0c             	add    $0xc,%esp
f0101fd6:	68 08 3f 10 f0       	push   $0xf0103f08
f0101fdb:	68 2d 3f 10 f0       	push   $0xf0103f2d
f0101fe0:	68 ff 3e 10 f0       	push   $0xf0103eff
f0101fe5:	e8 54 e8 ff ff       	call   f010083e <cprintf>
f0101fea:	83 c4 0c             	add    $0xc,%esp
f0101fed:	68 36 3f 10 f0       	push   $0xf0103f36
f0101ff2:	68 4a 3f 10 f0       	push   $0xf0103f4a
f0101ff7:	68 ff 3e 10 f0       	push   $0xf0103eff
f0101ffc:	e8 3d e8 ff ff       	call   f010083e <cprintf>
f0102001:	83 c4 0c             	add    $0xc,%esp
f0102004:	68 55 3f 10 f0       	push   $0xf0103f55
f0102009:	68 6a 3f 10 f0       	push   $0xf0103f6a
f010200e:	68 ff 3e 10 f0       	push   $0xf0103eff
f0102013:	e8 26 e8 ff ff       	call   f010083e <cprintf>
	return 0;
}
f0102018:	31 c0                	xor    %eax,%eax
f010201a:	83 c4 1c             	add    $0x1c,%esp
f010201d:	c3                   	ret    

f010201e <print_tick>:
    cprintf("Kernel data base start=0x%10x size = %ld\n",&data_start,(int)&end-(int)&data_start);
    cprintf("Kernel executable memory footprint: %ldKB\n",((int)&end-(int)&kernel_load_addr)/1024);
	return 0;
}
int print_tick(int argc, char **argv)
{
f010201e:	83 ec 0c             	sub    $0xc,%esp
	cprintf("Now tick = %d\n", get_tick());
f0102021:	e8 8b 01 00 00       	call   f01021b1 <get_tick>
f0102026:	c7 44 24 10 73 3f 10 	movl   $0xf0103f73,0x10(%esp)
f010202d:	f0 
f010202e:	89 44 24 14          	mov    %eax,0x14(%esp)
}
f0102032:	83 c4 0c             	add    $0xc,%esp
    cprintf("Kernel executable memory footprint: %ldKB\n",((int)&end-(int)&kernel_load_addr)/1024);
	return 0;
}
int print_tick(int argc, char **argv)
{
	cprintf("Now tick = %d\n", get_tick());
f0102035:	e9 04 e8 ff ff       	jmp    f010083e <cprintf>

f010203a <chgcolor>:
	{ "help", "Display this list of commands", mon_help },
	{ "kerninfo", "Display information about the kernel", mon_kerninfo },
	{ "print_tick", "Display system tick", print_tick },
    { "chgcolor","change color of text", chgcolor }
};
int chgcolor(int argc, char *argv[]){
f010203a:	53                   	push   %ebx
f010203b:	83 ec 08             	sub    $0x8,%esp
    if(argc == 1)
f010203e:	83 7c 24 10 01       	cmpl   $0x1,0x10(%esp)
	{ "help", "Display this list of commands", mon_help },
	{ "kerninfo", "Display information about the kernel", mon_kerninfo },
	{ "print_tick", "Display system tick", print_tick },
    { "chgcolor","change color of text", chgcolor }
};
int chgcolor(int argc, char *argv[]){
f0102043:	8b 5c 24 14          	mov    0x14(%esp),%ebx
    if(argc == 1)
f0102047:	75 0a                	jne    f0102053 <chgcolor+0x19>
        cprintf("NO input text colors!\n");
f0102049:	83 ec 0c             	sub    $0xc,%esp
f010204c:	68 82 3f 10 f0       	push   $0xf0103f82
f0102051:	eb 1e                	jmp    f0102071 <chgcolor+0x37>
    else{
        settextcolor((unsigned char)(*argv[1]),0);
f0102053:	52                   	push   %edx
f0102054:	52                   	push   %edx
f0102055:	6a 00                	push   $0x0
f0102057:	8b 43 04             	mov    0x4(%ebx),%eax
f010205a:	0f b6 00             	movzbl (%eax),%eax
f010205d:	50                   	push   %eax
f010205e:	e8 94 e4 ff ff       	call   f01004f7 <settextcolor>
        cprintf("Change color %c!\n",*argv[1]);
f0102063:	59                   	pop    %ecx
f0102064:	58                   	pop    %eax
f0102065:	8b 43 04             	mov    0x4(%ebx),%eax
f0102068:	0f be 00             	movsbl (%eax),%eax
f010206b:	50                   	push   %eax
f010206c:	68 99 3f 10 f0       	push   $0xf0103f99
f0102071:	e8 c8 e7 ff ff       	call   f010083e <cprintf>
    }   
    return 0;
                            
}
f0102076:	31 c0                	xor    %eax,%eax
f0102078:	83 c4 18             	add    $0x18,%esp
f010207b:	5b                   	pop    %ebx
f010207c:	c3                   	ret    

f010207d <shell>:
	}
	cprintf("Unknown command '%s'\n", argv[0]);
	return 0;
}
void shell()
{
f010207d:	55                   	push   %ebp
f010207e:	57                   	push   %edi
f010207f:	56                   	push   %esi
f0102080:	53                   	push   %ebx
f0102081:	83 ec 58             	sub    $0x58,%esp
	char *buf;
	cprintf("Welcome to the OSDI course!\n");
f0102084:	68 ab 3f 10 f0       	push   $0xf0103fab
f0102089:	e8 b0 e7 ff ff       	call   f010083e <cprintf>
	cprintf("Type 'help' for a list of commands.\n");
f010208e:	c7 04 24 c8 3f 10 f0 	movl   $0xf0103fc8,(%esp)
f0102095:	e8 a4 e7 ff ff       	call   f010083e <cprintf>
f010209a:	83 c4 10             	add    $0x10,%esp
	// Lookup and invoke the command
	if (argc == 0)
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
		if (strcmp(argv[0], commands[i].name) == 0)
			return commands[i].func(argc, argv);
f010209d:	89 e5                	mov    %esp,%ebp
	cprintf("Welcome to the OSDI course!\n");
	cprintf("Type 'help' for a list of commands.\n");

	while(1)
	{
		buf = readline("OSDI> ");
f010209f:	83 ec 0c             	sub    $0xc,%esp
f01020a2:	68 ed 3f 10 f0       	push   $0xf0103fed
f01020a7:	e8 94 07 00 00       	call   f0102840 <readline>
		if (buf != NULL)
f01020ac:	83 c4 10             	add    $0x10,%esp
f01020af:	85 c0                	test   %eax,%eax
	cprintf("Welcome to the OSDI course!\n");
	cprintf("Type 'help' for a list of commands.\n");

	while(1)
	{
		buf = readline("OSDI> ");
f01020b1:	89 c3                	mov    %eax,%ebx
		if (buf != NULL)
f01020b3:	74 ea                	je     f010209f <shell+0x22>
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
f01020b5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
	int argc;
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
f01020bc:	31 f6                	xor    %esi,%esi
f01020be:	eb 04                	jmp    f01020c4 <shell+0x47>
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
			*buf++ = 0;
f01020c0:	c6 03 00             	movb   $0x0,(%ebx)
f01020c3:	43                   	inc    %ebx
	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
f01020c4:	8a 03                	mov    (%ebx),%al
f01020c6:	84 c0                	test   %al,%al
f01020c8:	74 17                	je     f01020e1 <shell+0x64>
f01020ca:	57                   	push   %edi
f01020cb:	0f be c0             	movsbl %al,%eax
f01020ce:	57                   	push   %edi
f01020cf:	50                   	push   %eax
f01020d0:	68 f4 3f 10 f0       	push   $0xf0103ff4
f01020d5:	e8 87 09 00 00       	call   f0102a61 <strchr>
f01020da:	83 c4 10             	add    $0x10,%esp
f01020dd:	85 c0                	test   %eax,%eax
f01020df:	75 df                	jne    f01020c0 <shell+0x43>
			*buf++ = 0;
		if (*buf == 0)
f01020e1:	80 3b 00             	cmpb   $0x0,(%ebx)
f01020e4:	74 36                	je     f010211c <shell+0x9f>
			break;

		// save and scan past next arg
		if (argc == MAXARGS-1) {
f01020e6:	83 fe 0f             	cmp    $0xf,%esi
f01020e9:	75 0b                	jne    f01020f6 <shell+0x79>
			cprintf("Too many arguments (max %d)\n", MAXARGS);
f01020eb:	51                   	push   %ecx
f01020ec:	51                   	push   %ecx
f01020ed:	6a 10                	push   $0x10
f01020ef:	68 f9 3f 10 f0       	push   $0xf0103ff9
f01020f4:	eb 7d                	jmp    f0102173 <shell+0xf6>
			return 0;
		}
		argv[argc++] = buf;
f01020f6:	89 1c b4             	mov    %ebx,(%esp,%esi,4)
f01020f9:	46                   	inc    %esi
f01020fa:	eb 01                	jmp    f01020fd <shell+0x80>
		while (*buf && !strchr(WHITESPACE, *buf))
			buf++;
f01020fc:	43                   	inc    %ebx
		if (argc == MAXARGS-1) {
			cprintf("Too many arguments (max %d)\n", MAXARGS);
			return 0;
		}
		argv[argc++] = buf;
		while (*buf && !strchr(WHITESPACE, *buf))
f01020fd:	8a 03                	mov    (%ebx),%al
f01020ff:	84 c0                	test   %al,%al
f0102101:	74 c1                	je     f01020c4 <shell+0x47>
f0102103:	52                   	push   %edx
f0102104:	0f be c0             	movsbl %al,%eax
f0102107:	52                   	push   %edx
f0102108:	50                   	push   %eax
f0102109:	68 f4 3f 10 f0       	push   $0xf0103ff4
f010210e:	e8 4e 09 00 00       	call   f0102a61 <strchr>
f0102113:	83 c4 10             	add    $0x10,%esp
f0102116:	85 c0                	test   %eax,%eax
f0102118:	74 e2                	je     f01020fc <shell+0x7f>
f010211a:	eb a8                	jmp    f01020c4 <shell+0x47>
			buf++;
	}
	argv[argc] = 0;

	// Lookup and invoke the command
	if (argc == 0)
f010211c:	85 f6                	test   %esi,%esi
		}
		argv[argc++] = buf;
		while (*buf && !strchr(WHITESPACE, *buf))
			buf++;
	}
	argv[argc] = 0;
f010211e:	c7 04 b4 00 00 00 00 	movl   $0x0,(%esp,%esi,4)

	// Lookup and invoke the command
	if (argc == 0)
f0102125:	0f 84 74 ff ff ff    	je     f010209f <shell+0x22>
f010212b:	bf 2c 40 10 f0       	mov    $0xf010402c,%edi
f0102130:	31 db                	xor    %ebx,%ebx
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
		if (strcmp(argv[0], commands[i].name) == 0)
f0102132:	50                   	push   %eax
f0102133:	50                   	push   %eax
f0102134:	ff 37                	pushl  (%edi)
f0102136:	83 c7 0c             	add    $0xc,%edi
f0102139:	ff 74 24 0c          	pushl  0xc(%esp)
f010213d:	e8 a8 08 00 00       	call   f01029ea <strcmp>
f0102142:	83 c4 10             	add    $0x10,%esp
f0102145:	85 c0                	test   %eax,%eax
f0102147:	75 19                	jne    f0102162 <shell+0xe5>
			return commands[i].func(argc, argv);
f0102149:	6b db 0c             	imul   $0xc,%ebx,%ebx
f010214c:	57                   	push   %edi
f010214d:	57                   	push   %edi
f010214e:	55                   	push   %ebp
f010214f:	56                   	push   %esi
f0102150:	ff 93 34 40 10 f0    	call   *-0xfefbfcc(%ebx)
	while(1)
	{
		buf = readline("OSDI> ");
		if (buf != NULL)
		{
			if (runcmd(buf) < 0)
f0102156:	83 c4 10             	add    $0x10,%esp
f0102159:	85 c0                	test   %eax,%eax
f010215b:	78 23                	js     f0102180 <shell+0x103>
f010215d:	e9 3d ff ff ff       	jmp    f010209f <shell+0x22>
	argv[argc] = 0;

	// Lookup and invoke the command
	if (argc == 0)
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
f0102162:	43                   	inc    %ebx
f0102163:	83 fb 04             	cmp    $0x4,%ebx
f0102166:	75 ca                	jne    f0102132 <shell+0xb5>
		if (strcmp(argv[0], commands[i].name) == 0)
			return commands[i].func(argc, argv);
	}
	cprintf("Unknown command '%s'\n", argv[0]);
f0102168:	51                   	push   %ecx
f0102169:	51                   	push   %ecx
f010216a:	ff 74 24 08          	pushl  0x8(%esp)
f010216e:	68 16 40 10 f0       	push   $0xf0104016
f0102173:	e8 c6 e6 ff ff       	call   f010083e <cprintf>
f0102178:	83 c4 10             	add    $0x10,%esp
f010217b:	e9 1f ff ff ff       	jmp    f010209f <shell+0x22>
		{
			if (runcmd(buf) < 0)
				break;
		}
	}
}
f0102180:	83 c4 4c             	add    $0x4c,%esp
f0102183:	5b                   	pop    %ebx
f0102184:	5e                   	pop    %esi
f0102185:	5f                   	pop    %edi
f0102186:	5d                   	pop    %ebp
f0102187:	c3                   	ret    

f0102188 <set_timer>:

static unsigned long jiffies = 0;

void set_timer(int hz)
{
    int divisor = 1193180 / hz;       /* Calculate our divisor */
f0102188:	b9 dc 34 12 00       	mov    $0x1234dc,%ecx
f010218d:	89 c8                	mov    %ecx,%eax
f010218f:	99                   	cltd   
f0102190:	f7 7c 24 04          	idivl  0x4(%esp)
f0102194:	ba 43 00 00 00       	mov    $0x43,%edx
f0102199:	89 c1                	mov    %eax,%ecx
f010219b:	b0 36                	mov    $0x36,%al
f010219d:	ee                   	out    %al,(%dx)
f010219e:	b2 40                	mov    $0x40,%dl
f01021a0:	88 c8                	mov    %cl,%al
f01021a2:	ee                   	out    %al,(%dx)
    outb(0x43, 0x36);             /* Set our command byte 0x36 */
    outb(0x40, divisor & 0xFF);   /* Set low byte of divisor */
    outb(0x40, divisor >> 8);     /* Set high byte of divisor */
f01021a3:	89 c8                	mov    %ecx,%eax
f01021a5:	c1 f8 08             	sar    $0x8,%eax
f01021a8:	ee                   	out    %al,(%dx)
}
f01021a9:	c3                   	ret    

f01021aa <timer_handler>:
/* 
 * Timer interrupt handler
 */
void timer_handler()
{
	jiffies++;
f01021aa:	ff 05 28 02 11 f0    	incl   0xf0110228
}
f01021b0:	c3                   	ret    

f01021b1 <get_tick>:

unsigned long get_tick()
{
	return jiffies;
}
f01021b1:	a1 28 02 11 f0       	mov    0xf0110228,%eax
f01021b6:	c3                   	ret    

f01021b7 <timer_init>:
void timer_init()
{
f01021b7:	83 ec 0c             	sub    $0xc,%esp
	set_timer(TIME_HZ);
f01021ba:	6a 64                	push   $0x64
f01021bc:	e8 c7 ff ff ff       	call   f0102188 <set_timer>

	/* Enable interrupt */
	irq_setmask_8259A(irq_mask_8259A & ~(1<<IRQ_TIMER));
f01021c1:	50                   	push   %eax
f01021c2:	50                   	push   %eax
f01021c3:	0f b7 05 00 50 10 f0 	movzwl 0xf0105000,%eax
f01021ca:	25 fe ff 00 00       	and    $0xfffe,%eax
f01021cf:	50                   	push   %eax
f01021d0:	e8 b3 de ff ff       	call   f0100088 <irq_setmask_8259A>
}
f01021d5:	83 c4 1c             	add    $0x1c,%esp
f01021d8:	c3                   	ret    
f01021d9:	00 00                	add    %al,(%eax)
f01021db:	00 00                	add    %al,(%eax)
f01021dd:	00 00                	add    %al,(%eax)
	...

f01021e0 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
f01021e0:	55                   	push   %ebp
f01021e1:	57                   	push   %edi
f01021e2:	56                   	push   %esi
f01021e3:	53                   	push   %ebx
f01021e4:	83 ec 3c             	sub    $0x3c,%esp
f01021e7:	89 c5                	mov    %eax,%ebp
f01021e9:	89 d6                	mov    %edx,%esi
f01021eb:	8b 44 24 50          	mov    0x50(%esp),%eax
f01021ef:	89 44 24 24          	mov    %eax,0x24(%esp)
f01021f3:	8b 54 24 54          	mov    0x54(%esp),%edx
f01021f7:	89 54 24 20          	mov    %edx,0x20(%esp)
f01021fb:	8b 5c 24 5c          	mov    0x5c(%esp),%ebx
f01021ff:	8b 7c 24 60          	mov    0x60(%esp),%edi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
f0102203:	b8 00 00 00 00       	mov    $0x0,%eax
f0102208:	39 d0                	cmp    %edx,%eax
f010220a:	72 13                	jb     f010221f <printnum+0x3f>
f010220c:	8b 4c 24 24          	mov    0x24(%esp),%ecx
f0102210:	39 4c 24 58          	cmp    %ecx,0x58(%esp)
f0102214:	76 09                	jbe    f010221f <printnum+0x3f>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
f0102216:	83 eb 01             	sub    $0x1,%ebx
f0102219:	85 db                	test   %ebx,%ebx
f010221b:	7f 63                	jg     f0102280 <printnum+0xa0>
f010221d:	eb 71                	jmp    f0102290 <printnum+0xb0>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
f010221f:	89 7c 24 10          	mov    %edi,0x10(%esp)
f0102223:	83 eb 01             	sub    $0x1,%ebx
f0102226:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f010222a:	8b 5c 24 58          	mov    0x58(%esp),%ebx
f010222e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f0102232:	8b 44 24 08          	mov    0x8(%esp),%eax
f0102236:	8b 54 24 0c          	mov    0xc(%esp),%edx
f010223a:	89 44 24 28          	mov    %eax,0x28(%esp)
f010223e:	89 54 24 2c          	mov    %edx,0x2c(%esp)
f0102242:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
f0102249:	00 
f010224a:	8b 54 24 24          	mov    0x24(%esp),%edx
f010224e:	89 14 24             	mov    %edx,(%esp)
f0102251:	8b 4c 24 20          	mov    0x20(%esp),%ecx
f0102255:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f0102259:	e8 d2 0a 00 00       	call   f0102d30 <__udivdi3>
f010225e:	8b 4c 24 28          	mov    0x28(%esp),%ecx
f0102262:	8b 5c 24 2c          	mov    0x2c(%esp),%ebx
f0102266:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f010226a:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f010226e:	89 04 24             	mov    %eax,(%esp)
f0102271:	89 54 24 04          	mov    %edx,0x4(%esp)
f0102275:	89 f2                	mov    %esi,%edx
f0102277:	89 e8                	mov    %ebp,%eax
f0102279:	e8 62 ff ff ff       	call   f01021e0 <printnum>
f010227e:	eb 10                	jmp    f0102290 <printnum+0xb0>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
f0102280:	89 74 24 04          	mov    %esi,0x4(%esp)
f0102284:	89 3c 24             	mov    %edi,(%esp)
f0102287:	ff d5                	call   *%ebp
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
f0102289:	83 eb 01             	sub    $0x1,%ebx
f010228c:	85 db                	test   %ebx,%ebx
f010228e:	7f f0                	jg     f0102280 <printnum+0xa0>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f0102290:	89 74 24 04          	mov    %esi,0x4(%esp)
f0102294:	8b 74 24 04          	mov    0x4(%esp),%esi
f0102298:	8b 44 24 58          	mov    0x58(%esp),%eax
f010229c:	89 44 24 08          	mov    %eax,0x8(%esp)
f01022a0:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
f01022a7:	00 
f01022a8:	8b 54 24 24          	mov    0x24(%esp),%edx
f01022ac:	89 14 24             	mov    %edx,(%esp)
f01022af:	8b 4c 24 20          	mov    0x20(%esp),%ecx
f01022b3:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f01022b7:	e8 84 0b 00 00       	call   f0102e40 <__umoddi3>
f01022bc:	89 74 24 04          	mov    %esi,0x4(%esp)
f01022c0:	0f be 80 5c 40 10 f0 	movsbl -0xfefbfa4(%eax),%eax
f01022c7:	89 04 24             	mov    %eax,(%esp)
f01022ca:	ff d5                	call   *%ebp
}
f01022cc:	83 c4 3c             	add    $0x3c,%esp
f01022cf:	5b                   	pop    %ebx
f01022d0:	5e                   	pop    %esi
f01022d1:	5f                   	pop    %edi
f01022d2:	5d                   	pop    %ebp
f01022d3:	c3                   	ret    

f01022d4 <getuint>:
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
f01022d4:	83 fa 01             	cmp    $0x1,%edx
f01022d7:	7e 0d                	jle    f01022e6 <getuint+0x12>
		return va_arg(*ap, unsigned long long);
f01022d9:	8b 10                	mov    (%eax),%edx
f01022db:	8d 4a 08             	lea    0x8(%edx),%ecx
f01022de:	89 08                	mov    %ecx,(%eax)
f01022e0:	8b 02                	mov    (%edx),%eax
f01022e2:	8b 52 04             	mov    0x4(%edx),%edx
f01022e5:	c3                   	ret    
	else if (lflag)
f01022e6:	85 d2                	test   %edx,%edx
f01022e8:	74 0f                	je     f01022f9 <getuint+0x25>
		return va_arg(*ap, unsigned long);
f01022ea:	8b 10                	mov    (%eax),%edx
f01022ec:	8d 4a 04             	lea    0x4(%edx),%ecx
f01022ef:	89 08                	mov    %ecx,(%eax)
f01022f1:	8b 02                	mov    (%edx),%eax
f01022f3:	ba 00 00 00 00       	mov    $0x0,%edx
f01022f8:	c3                   	ret    
	else
		return va_arg(*ap, unsigned int);
f01022f9:	8b 10                	mov    (%eax),%edx
f01022fb:	8d 4a 04             	lea    0x4(%edx),%ecx
f01022fe:	89 08                	mov    %ecx,(%eax)
f0102300:	8b 02                	mov    (%edx),%eax
f0102302:	ba 00 00 00 00       	mov    $0x0,%edx
}
f0102307:	c3                   	ret    

f0102308 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f0102308:	8b 44 24 08          	mov    0x8(%esp),%eax
	b->cnt++;
f010230c:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
f0102310:	8b 10                	mov    (%eax),%edx
f0102312:	3b 50 04             	cmp    0x4(%eax),%edx
f0102315:	73 0b                	jae    f0102322 <sprintputch+0x1a>
		*b->buf++ = ch;
f0102317:	8b 4c 24 04          	mov    0x4(%esp),%ecx
f010231b:	88 0a                	mov    %cl,(%edx)
f010231d:	83 c2 01             	add    $0x1,%edx
f0102320:	89 10                	mov    %edx,(%eax)
f0102322:	f3 c3                	repz ret 

f0102324 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
f0102324:	83 ec 1c             	sub    $0x1c,%esp
	va_list ap;

	va_start(ap, fmt);
f0102327:	8d 44 24 2c          	lea    0x2c(%esp),%eax
	vprintfmt(putch, putdat, fmt, ap);
f010232b:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010232f:	8b 44 24 28          	mov    0x28(%esp),%eax
f0102333:	89 44 24 08          	mov    %eax,0x8(%esp)
f0102337:	8b 44 24 24          	mov    0x24(%esp),%eax
f010233b:	89 44 24 04          	mov    %eax,0x4(%esp)
f010233f:	8b 44 24 20          	mov    0x20(%esp),%eax
f0102343:	89 04 24             	mov    %eax,(%esp)
f0102346:	e8 04 00 00 00       	call   f010234f <vprintfmt>
	va_end(ap);
}
f010234b:	83 c4 1c             	add    $0x1c,%esp
f010234e:	c3                   	ret    

f010234f <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
f010234f:	55                   	push   %ebp
f0102350:	57                   	push   %edi
f0102351:	56                   	push   %esi
f0102352:	53                   	push   %ebx
f0102353:	83 ec 4c             	sub    $0x4c,%esp
f0102356:	8b 6c 24 60          	mov    0x60(%esp),%ebp
f010235a:	8b 7c 24 64          	mov    0x64(%esp),%edi
f010235e:	8b 5c 24 68          	mov    0x68(%esp),%ebx
f0102362:	eb 11                	jmp    f0102375 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
f0102364:	85 c0                	test   %eax,%eax
f0102366:	0f 84 40 04 00 00    	je     f01027ac <vprintfmt+0x45d>
				return;
			putch(ch, putdat);
f010236c:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0102370:	89 04 24             	mov    %eax,(%esp)
f0102373:	ff d5                	call   *%ebp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
f0102375:	0f b6 03             	movzbl (%ebx),%eax
f0102378:	83 c3 01             	add    $0x1,%ebx
f010237b:	83 f8 25             	cmp    $0x25,%eax
f010237e:	75 e4                	jne    f0102364 <vprintfmt+0x15>
f0102380:	c6 44 24 28 20       	movb   $0x20,0x28(%esp)
f0102385:	c7 44 24 2c 00 00 00 	movl   $0x0,0x2c(%esp)
f010238c:	00 
f010238d:	be ff ff ff ff       	mov    $0xffffffff,%esi
f0102392:	c7 44 24 30 ff ff ff 	movl   $0xffffffff,0x30(%esp)
f0102399:	ff 
f010239a:	b9 00 00 00 00       	mov    $0x0,%ecx
f010239f:	89 74 24 34          	mov    %esi,0x34(%esp)
f01023a3:	eb 34                	jmp    f01023d9 <vprintfmt+0x8a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01023a5:	8b 5c 24 24          	mov    0x24(%esp),%ebx

		// flag to pad on the right
		case '-':
			padc = '-';
f01023a9:	c6 44 24 28 2d       	movb   $0x2d,0x28(%esp)
f01023ae:	eb 29                	jmp    f01023d9 <vprintfmt+0x8a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01023b0:	8b 5c 24 24          	mov    0x24(%esp),%ebx
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
f01023b4:	c6 44 24 28 30       	movb   $0x30,0x28(%esp)
f01023b9:	eb 1e                	jmp    f01023d9 <vprintfmt+0x8a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01023bb:	8b 5c 24 24          	mov    0x24(%esp),%ebx
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
f01023bf:	c7 44 24 30 00 00 00 	movl   $0x0,0x30(%esp)
f01023c6:	00 
f01023c7:	eb 10                	jmp    f01023d9 <vprintfmt+0x8a>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
f01023c9:	8b 44 24 34          	mov    0x34(%esp),%eax
f01023cd:	89 44 24 30          	mov    %eax,0x30(%esp)
f01023d1:	c7 44 24 34 ff ff ff 	movl   $0xffffffff,0x34(%esp)
f01023d8:	ff 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01023d9:	0f b6 03             	movzbl (%ebx),%eax
f01023dc:	0f b6 d0             	movzbl %al,%edx
f01023df:	8d 73 01             	lea    0x1(%ebx),%esi
f01023e2:	89 74 24 24          	mov    %esi,0x24(%esp)
f01023e6:	83 e8 23             	sub    $0x23,%eax
f01023e9:	3c 55                	cmp    $0x55,%al
f01023eb:	0f 87 9c 03 00 00    	ja     f010278d <vprintfmt+0x43e>
f01023f1:	0f b6 c0             	movzbl %al,%eax
f01023f4:	ff 24 85 20 41 10 f0 	jmp    *-0xfefbee0(,%eax,4)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
f01023fb:	83 ea 30             	sub    $0x30,%edx
f01023fe:	89 54 24 34          	mov    %edx,0x34(%esp)
				ch = *fmt;
f0102402:	8b 54 24 24          	mov    0x24(%esp),%edx
f0102406:	0f be 02             	movsbl (%edx),%eax
				if (ch < '0' || ch > '9')
f0102409:	8d 50 d0             	lea    -0x30(%eax),%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f010240c:	8b 5c 24 24          	mov    0x24(%esp),%ebx
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
f0102410:	83 fa 09             	cmp    $0x9,%edx
f0102413:	77 5b                	ja     f0102470 <vprintfmt+0x121>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0102415:	8b 74 24 34          	mov    0x34(%esp),%esi
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
f0102419:	83 c3 01             	add    $0x1,%ebx
				precision = precision * 10 + ch - '0';
f010241c:	8d 14 b6             	lea    (%esi,%esi,4),%edx
f010241f:	8d 74 50 d0          	lea    -0x30(%eax,%edx,2),%esi
				ch = *fmt;
f0102423:	0f be 03             	movsbl (%ebx),%eax
				if (ch < '0' || ch > '9')
f0102426:	8d 50 d0             	lea    -0x30(%eax),%edx
f0102429:	83 fa 09             	cmp    $0x9,%edx
f010242c:	76 eb                	jbe    f0102419 <vprintfmt+0xca>
f010242e:	89 74 24 34          	mov    %esi,0x34(%esp)
f0102432:	eb 3c                	jmp    f0102470 <vprintfmt+0x121>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
f0102434:	8b 44 24 6c          	mov    0x6c(%esp),%eax
f0102438:	8d 50 04             	lea    0x4(%eax),%edx
f010243b:	89 54 24 6c          	mov    %edx,0x6c(%esp)
f010243f:	8b 00                	mov    (%eax),%eax
f0102441:	89 44 24 34          	mov    %eax,0x34(%esp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0102445:	8b 5c 24 24          	mov    0x24(%esp),%ebx
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
f0102449:	eb 25                	jmp    f0102470 <vprintfmt+0x121>

		case '.':
			if (width < 0)
f010244b:	83 7c 24 30 00       	cmpl   $0x0,0x30(%esp)
f0102450:	0f 88 65 ff ff ff    	js     f01023bb <vprintfmt+0x6c>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0102456:	8b 5c 24 24          	mov    0x24(%esp),%ebx
f010245a:	e9 7a ff ff ff       	jmp    f01023d9 <vprintfmt+0x8a>
f010245f:	8b 5c 24 24          	mov    0x24(%esp),%ebx
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
f0102463:	c7 44 24 2c 01 00 00 	movl   $0x1,0x2c(%esp)
f010246a:	00 
			goto reswitch;
f010246b:	e9 69 ff ff ff       	jmp    f01023d9 <vprintfmt+0x8a>

		process_precision:
			if (width < 0)
f0102470:	83 7c 24 30 00       	cmpl   $0x0,0x30(%esp)
f0102475:	0f 89 5e ff ff ff    	jns    f01023d9 <vprintfmt+0x8a>
f010247b:	e9 49 ff ff ff       	jmp    f01023c9 <vprintfmt+0x7a>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
f0102480:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0102483:	8b 5c 24 24          	mov    0x24(%esp),%ebx
f0102487:	e9 4d ff ff ff       	jmp    f01023d9 <vprintfmt+0x8a>
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
f010248c:	8b 44 24 6c          	mov    0x6c(%esp),%eax
f0102490:	8d 50 04             	lea    0x4(%eax),%edx
f0102493:	89 54 24 6c          	mov    %edx,0x6c(%esp)
f0102497:	89 7c 24 04          	mov    %edi,0x4(%esp)
f010249b:	8b 00                	mov    (%eax),%eax
f010249d:	89 04 24             	mov    %eax,(%esp)
f01024a0:	ff d5                	call   *%ebp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01024a2:	8b 5c 24 24          	mov    0x24(%esp),%ebx
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
f01024a6:	e9 ca fe ff ff       	jmp    f0102375 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
f01024ab:	8b 44 24 6c          	mov    0x6c(%esp),%eax
f01024af:	8d 50 04             	lea    0x4(%eax),%edx
f01024b2:	89 54 24 6c          	mov    %edx,0x6c(%esp)
f01024b6:	8b 00                	mov    (%eax),%eax
f01024b8:	89 c2                	mov    %eax,%edx
f01024ba:	c1 fa 1f             	sar    $0x1f,%edx
f01024bd:	31 d0                	xor    %edx,%eax
f01024bf:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f01024c1:	83 f8 08             	cmp    $0x8,%eax
f01024c4:	7f 0b                	jg     f01024d1 <vprintfmt+0x182>
f01024c6:	8b 14 85 80 42 10 f0 	mov    -0xfefbd80(,%eax,4),%edx
f01024cd:	85 d2                	test   %edx,%edx
f01024cf:	75 21                	jne    f01024f2 <vprintfmt+0x1a3>
				printfmt(putch, putdat, "error %d", err);
f01024d1:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01024d5:	c7 44 24 08 74 40 10 	movl   $0xf0104074,0x8(%esp)
f01024dc:	f0 
f01024dd:	89 7c 24 04          	mov    %edi,0x4(%esp)
f01024e1:	89 2c 24             	mov    %ebp,(%esp)
f01024e4:	e8 3b fe ff ff       	call   f0102324 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01024e9:	8b 5c 24 24          	mov    0x24(%esp),%ebx
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
f01024ed:	e9 83 fe ff ff       	jmp    f0102375 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
f01024f2:	89 54 24 0c          	mov    %edx,0xc(%esp)
f01024f6:	c7 44 24 08 85 35 10 	movl   $0xf0103585,0x8(%esp)
f01024fd:	f0 
f01024fe:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0102502:	89 2c 24             	mov    %ebp,(%esp)
f0102505:	e8 1a fe ff ff       	call   f0102324 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f010250a:	8b 5c 24 24          	mov    0x24(%esp),%ebx
f010250e:	e9 62 fe ff ff       	jmp    f0102375 <vprintfmt+0x26>
f0102513:	8b 74 24 34          	mov    0x34(%esp),%esi
f0102517:	8b 5c 24 24          	mov    0x24(%esp),%ebx
f010251b:	8b 44 24 30          	mov    0x30(%esp),%eax
f010251f:	89 44 24 38          	mov    %eax,0x38(%esp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
f0102523:	8b 44 24 6c          	mov    0x6c(%esp),%eax
f0102527:	8d 50 04             	lea    0x4(%eax),%edx
f010252a:	89 54 24 6c          	mov    %edx,0x6c(%esp)
f010252e:	8b 00                	mov    (%eax),%eax
				p = "(null)";
f0102530:	85 c0                	test   %eax,%eax
f0102532:	ba 6d 40 10 f0       	mov    $0xf010406d,%edx
f0102537:	0f 45 d0             	cmovne %eax,%edx
f010253a:	89 54 24 34          	mov    %edx,0x34(%esp)
			if (width > 0 && padc != '-')
f010253e:	83 7c 24 38 00       	cmpl   $0x0,0x38(%esp)
f0102543:	7e 07                	jle    f010254c <vprintfmt+0x1fd>
f0102545:	80 7c 24 28 2d       	cmpb   $0x2d,0x28(%esp)
f010254a:	75 14                	jne    f0102560 <vprintfmt+0x211>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f010254c:	8b 54 24 34          	mov    0x34(%esp),%edx
f0102550:	0f be 02             	movsbl (%edx),%eax
f0102553:	85 c0                	test   %eax,%eax
f0102555:	0f 85 ac 00 00 00    	jne    f0102607 <vprintfmt+0x2b8>
f010255b:	e9 97 00 00 00       	jmp    f01025f7 <vprintfmt+0x2a8>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f0102560:	89 74 24 04          	mov    %esi,0x4(%esp)
f0102564:	8b 44 24 34          	mov    0x34(%esp),%eax
f0102568:	89 04 24             	mov    %eax,(%esp)
f010256b:	e8 99 03 00 00       	call   f0102909 <strnlen>
f0102570:	8b 54 24 38          	mov    0x38(%esp),%edx
f0102574:	29 c2                	sub    %eax,%edx
f0102576:	89 54 24 30          	mov    %edx,0x30(%esp)
f010257a:	85 d2                	test   %edx,%edx
f010257c:	7e ce                	jle    f010254c <vprintfmt+0x1fd>
					putch(padc, putdat);
f010257e:	0f be 44 24 28       	movsbl 0x28(%esp),%eax
f0102583:	89 74 24 38          	mov    %esi,0x38(%esp)
f0102587:	89 5c 24 3c          	mov    %ebx,0x3c(%esp)
f010258b:	89 d3                	mov    %edx,%ebx
f010258d:	89 c6                	mov    %eax,%esi
f010258f:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0102593:	89 34 24             	mov    %esi,(%esp)
f0102596:	ff d5                	call   *%ebp
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f0102598:	83 eb 01             	sub    $0x1,%ebx
f010259b:	85 db                	test   %ebx,%ebx
f010259d:	7f f0                	jg     f010258f <vprintfmt+0x240>
f010259f:	8b 74 24 38          	mov    0x38(%esp),%esi
f01025a3:	8b 5c 24 3c          	mov    0x3c(%esp),%ebx
f01025a7:	c7 44 24 30 00 00 00 	movl   $0x0,0x30(%esp)
f01025ae:	00 
f01025af:	eb 9b                	jmp    f010254c <vprintfmt+0x1fd>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
f01025b1:	83 7c 24 2c 00       	cmpl   $0x0,0x2c(%esp)
f01025b6:	74 19                	je     f01025d1 <vprintfmt+0x282>
f01025b8:	8d 50 e0             	lea    -0x20(%eax),%edx
f01025bb:	83 fa 5e             	cmp    $0x5e,%edx
f01025be:	76 11                	jbe    f01025d1 <vprintfmt+0x282>
					putch('?', putdat);
f01025c0:	89 7c 24 04          	mov    %edi,0x4(%esp)
f01025c4:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
f01025cb:	ff 54 24 28          	call   *0x28(%esp)
f01025cf:	eb 0b                	jmp    f01025dc <vprintfmt+0x28d>
				else
					putch(ch, putdat);
f01025d1:	89 7c 24 04          	mov    %edi,0x4(%esp)
f01025d5:	89 04 24             	mov    %eax,(%esp)
f01025d8:	ff 54 24 28          	call   *0x28(%esp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f01025dc:	83 ed 01             	sub    $0x1,%ebp
f01025df:	0f be 03             	movsbl (%ebx),%eax
f01025e2:	85 c0                	test   %eax,%eax
f01025e4:	74 05                	je     f01025eb <vprintfmt+0x29c>
f01025e6:	83 c3 01             	add    $0x1,%ebx
f01025e9:	eb 31                	jmp    f010261c <vprintfmt+0x2cd>
f01025eb:	89 6c 24 30          	mov    %ebp,0x30(%esp)
f01025ef:	8b 6c 24 28          	mov    0x28(%esp),%ebp
f01025f3:	8b 5c 24 38          	mov    0x38(%esp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
f01025f7:	83 7c 24 30 00       	cmpl   $0x0,0x30(%esp)
f01025fc:	7f 35                	jg     f0102633 <vprintfmt+0x2e4>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01025fe:	8b 5c 24 24          	mov    0x24(%esp),%ebx
f0102602:	e9 6e fd ff ff       	jmp    f0102375 <vprintfmt+0x26>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f0102607:	8b 54 24 34          	mov    0x34(%esp),%edx
f010260b:	83 c2 01             	add    $0x1,%edx
f010260e:	89 6c 24 28          	mov    %ebp,0x28(%esp)
f0102612:	8b 6c 24 30          	mov    0x30(%esp),%ebp
f0102616:	89 5c 24 38          	mov    %ebx,0x38(%esp)
f010261a:	89 d3                	mov    %edx,%ebx
f010261c:	85 f6                	test   %esi,%esi
f010261e:	78 91                	js     f01025b1 <vprintfmt+0x262>
f0102620:	83 ee 01             	sub    $0x1,%esi
f0102623:	79 8c                	jns    f01025b1 <vprintfmt+0x262>
f0102625:	89 6c 24 30          	mov    %ebp,0x30(%esp)
f0102629:	8b 6c 24 28          	mov    0x28(%esp),%ebp
f010262d:	8b 5c 24 38          	mov    0x38(%esp),%ebx
f0102631:	eb c4                	jmp    f01025f7 <vprintfmt+0x2a8>
f0102633:	89 de                	mov    %ebx,%esi
f0102635:	8b 5c 24 30          	mov    0x30(%esp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
f0102639:	89 7c 24 04          	mov    %edi,0x4(%esp)
f010263d:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
f0102644:	ff d5                	call   *%ebp
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
f0102646:	83 eb 01             	sub    $0x1,%ebx
f0102649:	85 db                	test   %ebx,%ebx
f010264b:	7f ec                	jg     f0102639 <vprintfmt+0x2ea>
f010264d:	89 f3                	mov    %esi,%ebx
f010264f:	e9 21 fd ff ff       	jmp    f0102375 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
f0102654:	83 f9 01             	cmp    $0x1,%ecx
f0102657:	7e 12                	jle    f010266b <vprintfmt+0x31c>
		return va_arg(*ap, long long);
f0102659:	8b 44 24 6c          	mov    0x6c(%esp),%eax
f010265d:	8d 50 08             	lea    0x8(%eax),%edx
f0102660:	89 54 24 6c          	mov    %edx,0x6c(%esp)
f0102664:	8b 18                	mov    (%eax),%ebx
f0102666:	8b 70 04             	mov    0x4(%eax),%esi
f0102669:	eb 2a                	jmp    f0102695 <vprintfmt+0x346>
	else if (lflag)
f010266b:	85 c9                	test   %ecx,%ecx
f010266d:	74 14                	je     f0102683 <vprintfmt+0x334>
		return va_arg(*ap, long);
f010266f:	8b 44 24 6c          	mov    0x6c(%esp),%eax
f0102673:	8d 50 04             	lea    0x4(%eax),%edx
f0102676:	89 54 24 6c          	mov    %edx,0x6c(%esp)
f010267a:	8b 18                	mov    (%eax),%ebx
f010267c:	89 de                	mov    %ebx,%esi
f010267e:	c1 fe 1f             	sar    $0x1f,%esi
f0102681:	eb 12                	jmp    f0102695 <vprintfmt+0x346>
	else
		return va_arg(*ap, int);
f0102683:	8b 44 24 6c          	mov    0x6c(%esp),%eax
f0102687:	8d 50 04             	lea    0x4(%eax),%edx
f010268a:	89 54 24 6c          	mov    %edx,0x6c(%esp)
f010268e:	8b 18                	mov    (%eax),%ebx
f0102690:	89 de                	mov    %ebx,%esi
f0102692:	c1 fe 1f             	sar    $0x1f,%esi
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
f0102695:	b8 0a 00 00 00       	mov    $0xa,%eax
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
f010269a:	85 f6                	test   %esi,%esi
f010269c:	0f 89 ab 00 00 00    	jns    f010274d <vprintfmt+0x3fe>
				putch('-', putdat);
f01026a2:	89 7c 24 04          	mov    %edi,0x4(%esp)
f01026a6:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
f01026ad:	ff d5                	call   *%ebp
				num = -(long long) num;
f01026af:	f7 db                	neg    %ebx
f01026b1:	83 d6 00             	adc    $0x0,%esi
f01026b4:	f7 de                	neg    %esi
			}
			base = 10;
f01026b6:	b8 0a 00 00 00       	mov    $0xa,%eax
f01026bb:	e9 8d 00 00 00       	jmp    f010274d <vprintfmt+0x3fe>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
f01026c0:	89 ca                	mov    %ecx,%edx
f01026c2:	8d 44 24 6c          	lea    0x6c(%esp),%eax
f01026c6:	e8 09 fc ff ff       	call   f01022d4 <getuint>
f01026cb:	89 c3                	mov    %eax,%ebx
f01026cd:	89 d6                	mov    %edx,%esi
			base = 10;
f01026cf:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
f01026d4:	eb 77                	jmp    f010274d <vprintfmt+0x3fe>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
f01026d6:	89 7c 24 04          	mov    %edi,0x4(%esp)
f01026da:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
f01026e1:	ff d5                	call   *%ebp
			putch('X', putdat);
f01026e3:	89 7c 24 04          	mov    %edi,0x4(%esp)
f01026e7:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
f01026ee:	ff d5                	call   *%ebp
			putch('X', putdat);
f01026f0:	89 7c 24 04          	mov    %edi,0x4(%esp)
f01026f4:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
f01026fb:	ff d5                	call   *%ebp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01026fd:	8b 5c 24 24          	mov    0x24(%esp),%ebx
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
			putch('X', putdat);
			putch('X', putdat);
			break;
f0102701:	e9 6f fc ff ff       	jmp    f0102375 <vprintfmt+0x26>

		// pointer
		case 'p':
			putch('0', putdat);
f0102706:	89 7c 24 04          	mov    %edi,0x4(%esp)
f010270a:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
f0102711:	ff d5                	call   *%ebp
			putch('x', putdat);
f0102713:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0102717:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
f010271e:	ff d5                	call   *%ebp
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
f0102720:	8b 44 24 6c          	mov    0x6c(%esp),%eax
f0102724:	8d 50 04             	lea    0x4(%eax),%edx
f0102727:	89 54 24 6c          	mov    %edx,0x6c(%esp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
f010272b:	8b 18                	mov    (%eax),%ebx
f010272d:	be 00 00 00 00       	mov    $0x0,%esi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
f0102732:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
f0102737:	eb 14                	jmp    f010274d <vprintfmt+0x3fe>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
f0102739:	89 ca                	mov    %ecx,%edx
f010273b:	8d 44 24 6c          	lea    0x6c(%esp),%eax
f010273f:	e8 90 fb ff ff       	call   f01022d4 <getuint>
f0102744:	89 c3                	mov    %eax,%ebx
f0102746:	89 d6                	mov    %edx,%esi
			base = 16;
f0102748:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
f010274d:	0f be 54 24 28       	movsbl 0x28(%esp),%edx
f0102752:	89 54 24 10          	mov    %edx,0x10(%esp)
f0102756:	8b 54 24 30          	mov    0x30(%esp),%edx
f010275a:	89 54 24 0c          	mov    %edx,0xc(%esp)
f010275e:	89 44 24 08          	mov    %eax,0x8(%esp)
f0102762:	89 1c 24             	mov    %ebx,(%esp)
f0102765:	89 74 24 04          	mov    %esi,0x4(%esp)
f0102769:	89 fa                	mov    %edi,%edx
f010276b:	89 e8                	mov    %ebp,%eax
f010276d:	e8 6e fa ff ff       	call   f01021e0 <printnum>
			break;
f0102772:	8b 5c 24 24          	mov    0x24(%esp),%ebx
f0102776:	e9 fa fb ff ff       	jmp    f0102375 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
f010277b:	89 7c 24 04          	mov    %edi,0x4(%esp)
f010277f:	89 14 24             	mov    %edx,(%esp)
f0102782:	ff d5                	call   *%ebp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0102784:	8b 5c 24 24          	mov    0x24(%esp),%ebx
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
f0102788:	e9 e8 fb ff ff       	jmp    f0102375 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
f010278d:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0102791:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
f0102798:	ff d5                	call   *%ebp
			for (fmt--; fmt[-1] != '%'; fmt--)
f010279a:	eb 02                	jmp    f010279e <vprintfmt+0x44f>
f010279c:	89 c3                	mov    %eax,%ebx
f010279e:	8d 43 ff             	lea    -0x1(%ebx),%eax
f01027a1:	80 7b ff 25          	cmpb   $0x25,-0x1(%ebx)
f01027a5:	75 f5                	jne    f010279c <vprintfmt+0x44d>
f01027a7:	e9 c9 fb ff ff       	jmp    f0102375 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
f01027ac:	83 c4 4c             	add    $0x4c,%esp
f01027af:	5b                   	pop    %ebx
f01027b0:	5e                   	pop    %esi
f01027b1:	5f                   	pop    %edi
f01027b2:	5d                   	pop    %ebp
f01027b3:	c3                   	ret    

f01027b4 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f01027b4:	83 ec 2c             	sub    $0x2c,%esp
f01027b7:	8b 44 24 30          	mov    0x30(%esp),%eax
f01027bb:	8b 54 24 34          	mov    0x34(%esp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
f01027bf:	89 44 24 14          	mov    %eax,0x14(%esp)
f01027c3:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
f01027c7:	89 4c 24 18          	mov    %ecx,0x18(%esp)
f01027cb:	c7 44 24 1c 00 00 00 	movl   $0x0,0x1c(%esp)
f01027d2:	00 

	if (buf == NULL || n < 1)
f01027d3:	85 c0                	test   %eax,%eax
f01027d5:	74 35                	je     f010280c <vsnprintf+0x58>
f01027d7:	85 d2                	test   %edx,%edx
f01027d9:	7e 31                	jle    f010280c <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
f01027db:	8b 44 24 3c          	mov    0x3c(%esp),%eax
f01027df:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01027e3:	8b 44 24 38          	mov    0x38(%esp),%eax
f01027e7:	89 44 24 08          	mov    %eax,0x8(%esp)
f01027eb:	8d 44 24 14          	lea    0x14(%esp),%eax
f01027ef:	89 44 24 04          	mov    %eax,0x4(%esp)
f01027f3:	c7 04 24 08 23 10 f0 	movl   $0xf0102308,(%esp)
f01027fa:	e8 50 fb ff ff       	call   f010234f <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f01027ff:	8b 44 24 14          	mov    0x14(%esp),%eax
f0102803:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f0102806:	8b 44 24 1c          	mov    0x1c(%esp),%eax
f010280a:	eb 05                	jmp    f0102811 <vsnprintf+0x5d>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
f010280c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
f0102811:	83 c4 2c             	add    $0x2c,%esp
f0102814:	c3                   	ret    

f0102815 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
f0102815:	83 ec 1c             	sub    $0x1c,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
f0102818:	8d 44 24 2c          	lea    0x2c(%esp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
f010281c:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0102820:	8b 44 24 28          	mov    0x28(%esp),%eax
f0102824:	89 44 24 08          	mov    %eax,0x8(%esp)
f0102828:	8b 44 24 24          	mov    0x24(%esp),%eax
f010282c:	89 44 24 04          	mov    %eax,0x4(%esp)
f0102830:	8b 44 24 20          	mov    0x20(%esp),%eax
f0102834:	89 04 24             	mov    %eax,(%esp)
f0102837:	e8 78 ff ff ff       	call   f01027b4 <vsnprintf>
	va_end(ap);

	return rc;
}
f010283c:	83 c4 1c             	add    $0x1c,%esp
f010283f:	c3                   	ret    

f0102840 <readline>:

#define BUFLEN 1024
static char buf[BUFLEN];

char *readline(const char *prompt)
{
f0102840:	56                   	push   %esi
f0102841:	53                   	push   %ebx
f0102842:	83 ec 14             	sub    $0x14,%esp
f0102845:	8b 44 24 20          	mov    0x20(%esp),%eax
	int i, c, echoing;

	if (prompt != NULL)
f0102849:	85 c0                	test   %eax,%eax
f010284b:	74 10                	je     f010285d <readline+0x1d>
		cprintf("%s", prompt);
f010284d:	89 44 24 04          	mov    %eax,0x4(%esp)
f0102851:	c7 04 24 85 35 10 f0 	movl   $0xf0103585,(%esp)
f0102858:	e8 e1 df ff ff       	call   f010083e <cprintf>

#define BUFLEN 1024
static char buf[BUFLEN];

char *readline(const char *prompt)
{
f010285d:	be 00 00 00 00       	mov    $0x0,%esi
	if (prompt != NULL)
		cprintf("%s", prompt);

	i = 0;
	while (1) {
		c = getc();
f0102862:	e8 9c da ff ff       	call   f0100303 <getc>
f0102867:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
f0102869:	85 c0                	test   %eax,%eax
f010286b:	79 17                	jns    f0102884 <readline+0x44>
			cprintf("read error: %e\n", c);
f010286d:	89 44 24 04          	mov    %eax,0x4(%esp)
f0102871:	c7 04 24 a4 42 10 f0 	movl   $0xf01042a4,(%esp)
f0102878:	e8 c1 df ff ff       	call   f010083e <cprintf>
			return NULL;
f010287d:	b8 00 00 00 00       	mov    $0x0,%eax
f0102882:	eb 64                	jmp    f01028e8 <readline+0xa8>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f0102884:	83 f8 08             	cmp    $0x8,%eax
f0102887:	74 05                	je     f010288e <readline+0x4e>
f0102889:	83 f8 7f             	cmp    $0x7f,%eax
f010288c:	75 15                	jne    f01028a3 <readline+0x63>
f010288e:	85 f6                	test   %esi,%esi
f0102890:	7e 11                	jle    f01028a3 <readline+0x63>
			putch('\b');
f0102892:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
f0102899:	e8 63 db ff ff       	call   f0100401 <putch>
			i--;
f010289e:	83 ee 01             	sub    $0x1,%esi
f01028a1:	eb bf                	jmp    f0102862 <readline+0x22>
		} else if (c >= ' ' && i < BUFLEN-1) {
f01028a3:	83 fb 1f             	cmp    $0x1f,%ebx
f01028a6:	7e 1e                	jle    f01028c6 <readline+0x86>
f01028a8:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
f01028ae:	7f 16                	jg     f01028c6 <readline+0x86>
			putch(c);
f01028b0:	0f b6 c3             	movzbl %bl,%eax
f01028b3:	89 04 24             	mov    %eax,(%esp)
f01028b6:	e8 46 db ff ff       	call   f0100401 <putch>
			buf[i++] = c;
f01028bb:	88 9e 40 02 11 f0    	mov    %bl,-0xfeefdc0(%esi)
f01028c1:	83 c6 01             	add    $0x1,%esi
f01028c4:	eb 9c                	jmp    f0102862 <readline+0x22>
		} else if (c == '\n' || c == '\r') {
f01028c6:	83 fb 0a             	cmp    $0xa,%ebx
f01028c9:	74 05                	je     f01028d0 <readline+0x90>
f01028cb:	83 fb 0d             	cmp    $0xd,%ebx
f01028ce:	75 92                	jne    f0102862 <readline+0x22>
			putch('\n');
f01028d0:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
f01028d7:	e8 25 db ff ff       	call   f0100401 <putch>
			buf[i] = 0;
f01028dc:	c6 86 40 02 11 f0 00 	movb   $0x0,-0xfeefdc0(%esi)
			return buf;
f01028e3:	b8 40 02 11 f0       	mov    $0xf0110240,%eax
		}
	}
}
f01028e8:	83 c4 14             	add    $0x14,%esp
f01028eb:	5b                   	pop    %ebx
f01028ec:	5e                   	pop    %esi
f01028ed:	c3                   	ret    
	...

f01028f0 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
f01028f0:	8b 54 24 04          	mov    0x4(%esp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
f01028f4:	b8 00 00 00 00       	mov    $0x0,%eax
f01028f9:	80 3a 00             	cmpb   $0x0,(%edx)
f01028fc:	74 09                	je     f0102907 <strlen+0x17>
		n++;
f01028fe:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
f0102901:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
f0102905:	75 f7                	jne    f01028fe <strlen+0xe>
		n++;
	return n;
}
f0102907:	f3 c3                	repz ret 

f0102909 <strnlen>:

int
strnlen(const char *s, size_t size)
{
f0102909:	8b 4c 24 04          	mov    0x4(%esp),%ecx
f010290d:	8b 54 24 08          	mov    0x8(%esp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0102911:	b8 00 00 00 00       	mov    $0x0,%eax
f0102916:	85 d2                	test   %edx,%edx
f0102918:	74 12                	je     f010292c <strnlen+0x23>
f010291a:	80 39 00             	cmpb   $0x0,(%ecx)
f010291d:	74 0d                	je     f010292c <strnlen+0x23>
		n++;
f010291f:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0102922:	39 d0                	cmp    %edx,%eax
f0102924:	74 06                	je     f010292c <strnlen+0x23>
f0102926:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
f010292a:	75 f3                	jne    f010291f <strnlen+0x16>
		n++;
	return n;
}
f010292c:	f3 c3                	repz ret 

f010292e <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f010292e:	53                   	push   %ebx
f010292f:	8b 44 24 08          	mov    0x8(%esp),%eax
f0102933:	8b 5c 24 0c          	mov    0xc(%esp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
f0102937:	ba 00 00 00 00       	mov    $0x0,%edx
f010293c:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
f0102940:	88 0c 10             	mov    %cl,(%eax,%edx,1)
f0102943:	83 c2 01             	add    $0x1,%edx
f0102946:	84 c9                	test   %cl,%cl
f0102948:	75 f2                	jne    f010293c <strcpy+0xe>
		/* do nothing */;
	return ret;
}
f010294a:	5b                   	pop    %ebx
f010294b:	c3                   	ret    

f010294c <strcat>:

char *
strcat(char *dst, const char *src)
{
f010294c:	53                   	push   %ebx
f010294d:	83 ec 08             	sub    $0x8,%esp
f0102950:	8b 5c 24 10          	mov    0x10(%esp),%ebx
	int len = strlen(dst);
f0102954:	89 1c 24             	mov    %ebx,(%esp)
f0102957:	e8 94 ff ff ff       	call   f01028f0 <strlen>
	strcpy(dst + len, src);
f010295c:	8b 54 24 14          	mov    0x14(%esp),%edx
f0102960:	89 54 24 04          	mov    %edx,0x4(%esp)
f0102964:	8d 04 03             	lea    (%ebx,%eax,1),%eax
f0102967:	89 04 24             	mov    %eax,(%esp)
f010296a:	e8 bf ff ff ff       	call   f010292e <strcpy>
	return dst;
}
f010296f:	89 d8                	mov    %ebx,%eax
f0102971:	83 c4 08             	add    $0x8,%esp
f0102974:	5b                   	pop    %ebx
f0102975:	c3                   	ret    

f0102976 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
f0102976:	56                   	push   %esi
f0102977:	53                   	push   %ebx
f0102978:	8b 44 24 0c          	mov    0xc(%esp),%eax
f010297c:	8b 54 24 10          	mov    0x10(%esp),%edx
f0102980:	8b 74 24 14          	mov    0x14(%esp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0102984:	85 f6                	test   %esi,%esi
f0102986:	74 18                	je     f01029a0 <strncpy+0x2a>
f0102988:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
f010298d:	0f b6 1a             	movzbl (%edx),%ebx
f0102990:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
f0102993:	80 3a 01             	cmpb   $0x1,(%edx)
f0102996:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0102999:	83 c1 01             	add    $0x1,%ecx
f010299c:	39 ce                	cmp    %ecx,%esi
f010299e:	77 ed                	ja     f010298d <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
f01029a0:	5b                   	pop    %ebx
f01029a1:	5e                   	pop    %esi
f01029a2:	c3                   	ret    

f01029a3 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
f01029a3:	57                   	push   %edi
f01029a4:	56                   	push   %esi
f01029a5:	53                   	push   %ebx
f01029a6:	8b 7c 24 10          	mov    0x10(%esp),%edi
f01029aa:	8b 5c 24 14          	mov    0x14(%esp),%ebx
f01029ae:	8b 74 24 18          	mov    0x18(%esp),%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f01029b2:	89 f8                	mov    %edi,%eax
f01029b4:	85 f6                	test   %esi,%esi
f01029b6:	74 2c                	je     f01029e4 <strlcpy+0x41>
		while (--size > 0 && *src != '\0')
f01029b8:	83 fe 01             	cmp    $0x1,%esi
f01029bb:	74 24                	je     f01029e1 <strlcpy+0x3e>
f01029bd:	0f b6 0b             	movzbl (%ebx),%ecx
f01029c0:	84 c9                	test   %cl,%cl
f01029c2:	74 1d                	je     f01029e1 <strlcpy+0x3e>
f01029c4:	ba 00 00 00 00       	mov    $0x0,%edx
	}
	return ret;
}

size_t
strlcpy(char *dst, const char *src, size_t size)
f01029c9:	83 ee 02             	sub    $0x2,%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
f01029cc:	88 08                	mov    %cl,(%eax)
f01029ce:	83 c0 01             	add    $0x1,%eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
f01029d1:	39 f2                	cmp    %esi,%edx
f01029d3:	74 0c                	je     f01029e1 <strlcpy+0x3e>
f01029d5:	0f b6 4c 13 01       	movzbl 0x1(%ebx,%edx,1),%ecx
f01029da:	83 c2 01             	add    $0x1,%edx
f01029dd:	84 c9                	test   %cl,%cl
f01029df:	75 eb                	jne    f01029cc <strlcpy+0x29>
			*dst++ = *src++;
		*dst = '\0';
f01029e1:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
f01029e4:	29 f8                	sub    %edi,%eax
}
f01029e6:	5b                   	pop    %ebx
f01029e7:	5e                   	pop    %esi
f01029e8:	5f                   	pop    %edi
f01029e9:	c3                   	ret    

f01029ea <strcmp>:

int
strcmp(const char *p, const char *q)
{
f01029ea:	8b 4c 24 04          	mov    0x4(%esp),%ecx
f01029ee:	8b 54 24 08          	mov    0x8(%esp),%edx
	while (*p && *p == *q)
f01029f2:	0f b6 01             	movzbl (%ecx),%eax
f01029f5:	84 c0                	test   %al,%al
f01029f7:	74 15                	je     f0102a0e <strcmp+0x24>
f01029f9:	3a 02                	cmp    (%edx),%al
f01029fb:	75 11                	jne    f0102a0e <strcmp+0x24>
		p++, q++;
f01029fd:	83 c1 01             	add    $0x1,%ecx
f0102a00:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
f0102a03:	0f b6 01             	movzbl (%ecx),%eax
f0102a06:	84 c0                	test   %al,%al
f0102a08:	74 04                	je     f0102a0e <strcmp+0x24>
f0102a0a:	3a 02                	cmp    (%edx),%al
f0102a0c:	74 ef                	je     f01029fd <strcmp+0x13>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
f0102a0e:	0f b6 c0             	movzbl %al,%eax
f0102a11:	0f b6 12             	movzbl (%edx),%edx
f0102a14:	29 d0                	sub    %edx,%eax
}
f0102a16:	c3                   	ret    

f0102a17 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
f0102a17:	53                   	push   %ebx
f0102a18:	8b 4c 24 08          	mov    0x8(%esp),%ecx
f0102a1c:	8b 5c 24 0c          	mov    0xc(%esp),%ebx
f0102a20:	8b 54 24 10          	mov    0x10(%esp),%edx
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
f0102a24:	b8 00 00 00 00       	mov    $0x0,%eax
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
f0102a29:	85 d2                	test   %edx,%edx
f0102a2b:	74 28                	je     f0102a55 <strncmp+0x3e>
f0102a2d:	0f b6 01             	movzbl (%ecx),%eax
f0102a30:	84 c0                	test   %al,%al
f0102a32:	74 23                	je     f0102a57 <strncmp+0x40>
f0102a34:	3a 03                	cmp    (%ebx),%al
f0102a36:	75 1f                	jne    f0102a57 <strncmp+0x40>
f0102a38:	83 ea 01             	sub    $0x1,%edx
f0102a3b:	74 13                	je     f0102a50 <strncmp+0x39>
		n--, p++, q++;
f0102a3d:	83 c1 01             	add    $0x1,%ecx
f0102a40:	83 c3 01             	add    $0x1,%ebx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
f0102a43:	0f b6 01             	movzbl (%ecx),%eax
f0102a46:	84 c0                	test   %al,%al
f0102a48:	74 0d                	je     f0102a57 <strncmp+0x40>
f0102a4a:	3a 03                	cmp    (%ebx),%al
f0102a4c:	74 ea                	je     f0102a38 <strncmp+0x21>
f0102a4e:	eb 07                	jmp    f0102a57 <strncmp+0x40>
		n--, p++, q++;
	if (n == 0)
		return 0;
f0102a50:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
f0102a55:	5b                   	pop    %ebx
f0102a56:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f0102a57:	0f b6 01             	movzbl (%ecx),%eax
f0102a5a:	0f b6 13             	movzbl (%ebx),%edx
f0102a5d:	29 d0                	sub    %edx,%eax
f0102a5f:	eb f4                	jmp    f0102a55 <strncmp+0x3e>

f0102a61 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f0102a61:	8b 44 24 04          	mov    0x4(%esp),%eax
f0102a65:	0f b6 4c 24 08       	movzbl 0x8(%esp),%ecx
	for (; *s; s++)
f0102a6a:	0f b6 10             	movzbl (%eax),%edx
f0102a6d:	84 d2                	test   %dl,%dl
f0102a6f:	74 21                	je     f0102a92 <strchr+0x31>
		if (*s == c)
f0102a71:	38 ca                	cmp    %cl,%dl
f0102a73:	75 0d                	jne    f0102a82 <strchr+0x21>
f0102a75:	f3 c3                	repz ret 
f0102a77:	38 ca                	cmp    %cl,%dl
f0102a79:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0102a80:	74 15                	je     f0102a97 <strchr+0x36>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
f0102a82:	83 c0 01             	add    $0x1,%eax
f0102a85:	0f b6 10             	movzbl (%eax),%edx
f0102a88:	84 d2                	test   %dl,%dl
f0102a8a:	75 eb                	jne    f0102a77 <strchr+0x16>
		if (*s == c)
			return (char *) s;
	return 0;
f0102a8c:	b8 00 00 00 00       	mov    $0x0,%eax
f0102a91:	c3                   	ret    
f0102a92:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0102a97:	f3 c3                	repz ret 

f0102a99 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f0102a99:	8b 44 24 04          	mov    0x4(%esp),%eax
f0102a9d:	0f b6 4c 24 08       	movzbl 0x8(%esp),%ecx
	for (; *s; s++)
f0102aa2:	0f b6 10             	movzbl (%eax),%edx
f0102aa5:	84 d2                	test   %dl,%dl
f0102aa7:	74 14                	je     f0102abd <strfind+0x24>
		if (*s == c)
f0102aa9:	38 ca                	cmp    %cl,%dl
f0102aab:	75 06                	jne    f0102ab3 <strfind+0x1a>
f0102aad:	f3 c3                	repz ret 
f0102aaf:	38 ca                	cmp    %cl,%dl
f0102ab1:	74 0a                	je     f0102abd <strfind+0x24>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
f0102ab3:	83 c0 01             	add    $0x1,%eax
f0102ab6:	0f b6 10             	movzbl (%eax),%edx
f0102ab9:	84 d2                	test   %dl,%dl
f0102abb:	75 f2                	jne    f0102aaf <strfind+0x16>
		if (*s == c)
			break;
	return (char *) s;
}
f0102abd:	f3 c3                	repz ret 

f0102abf <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
f0102abf:	83 ec 0c             	sub    $0xc,%esp
f0102ac2:	89 1c 24             	mov    %ebx,(%esp)
f0102ac5:	89 74 24 04          	mov    %esi,0x4(%esp)
f0102ac9:	89 7c 24 08          	mov    %edi,0x8(%esp)
f0102acd:	8b 7c 24 10          	mov    0x10(%esp),%edi
f0102ad1:	8b 44 24 14          	mov    0x14(%esp),%eax
f0102ad5:	8b 4c 24 18          	mov    0x18(%esp),%ecx
	char *p;

	if (n == 0)
f0102ad9:	85 c9                	test   %ecx,%ecx
f0102adb:	74 30                	je     f0102b0d <memset+0x4e>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
f0102add:	f7 c7 03 00 00 00    	test   $0x3,%edi
f0102ae3:	75 25                	jne    f0102b0a <memset+0x4b>
f0102ae5:	f6 c1 03             	test   $0x3,%cl
f0102ae8:	75 20                	jne    f0102b0a <memset+0x4b>
		c &= 0xFF;
f0102aea:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
f0102aed:	89 d3                	mov    %edx,%ebx
f0102aef:	c1 e3 08             	shl    $0x8,%ebx
f0102af2:	89 d6                	mov    %edx,%esi
f0102af4:	c1 e6 18             	shl    $0x18,%esi
f0102af7:	89 d0                	mov    %edx,%eax
f0102af9:	c1 e0 10             	shl    $0x10,%eax
f0102afc:	09 f0                	or     %esi,%eax
f0102afe:	09 d0                	or     %edx,%eax
f0102b00:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
f0102b02:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
f0102b05:	fc                   	cld    
f0102b06:	f3 ab                	rep stos %eax,%es:(%edi)
f0102b08:	eb 03                	jmp    f0102b0d <memset+0x4e>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
f0102b0a:	fc                   	cld    
f0102b0b:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
f0102b0d:	89 f8                	mov    %edi,%eax
f0102b0f:	8b 1c 24             	mov    (%esp),%ebx
f0102b12:	8b 74 24 04          	mov    0x4(%esp),%esi
f0102b16:	8b 7c 24 08          	mov    0x8(%esp),%edi
f0102b1a:	83 c4 0c             	add    $0xc,%esp
f0102b1d:	c3                   	ret    

f0102b1e <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
f0102b1e:	83 ec 08             	sub    $0x8,%esp
f0102b21:	89 34 24             	mov    %esi,(%esp)
f0102b24:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0102b28:	8b 44 24 0c          	mov    0xc(%esp),%eax
f0102b2c:	8b 74 24 10          	mov    0x10(%esp),%esi
f0102b30:	8b 4c 24 14          	mov    0x14(%esp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
f0102b34:	39 c6                	cmp    %eax,%esi
f0102b36:	73 36                	jae    f0102b6e <memmove+0x50>
f0102b38:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
f0102b3b:	39 d0                	cmp    %edx,%eax
f0102b3d:	73 2f                	jae    f0102b6e <memmove+0x50>
		s += n;
		d += n;
f0102b3f:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0102b42:	f6 c2 03             	test   $0x3,%dl
f0102b45:	75 1b                	jne    f0102b62 <memmove+0x44>
f0102b47:	f7 c7 03 00 00 00    	test   $0x3,%edi
f0102b4d:	75 13                	jne    f0102b62 <memmove+0x44>
f0102b4f:	f6 c1 03             	test   $0x3,%cl
f0102b52:	75 0e                	jne    f0102b62 <memmove+0x44>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
f0102b54:	83 ef 04             	sub    $0x4,%edi
f0102b57:	8d 72 fc             	lea    -0x4(%edx),%esi
f0102b5a:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
f0102b5d:	fd                   	std    
f0102b5e:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0102b60:	eb 09                	jmp    f0102b6b <memmove+0x4d>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
f0102b62:	83 ef 01             	sub    $0x1,%edi
f0102b65:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
f0102b68:	fd                   	std    
f0102b69:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
f0102b6b:	fc                   	cld    
f0102b6c:	eb 20                	jmp    f0102b8e <memmove+0x70>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0102b6e:	f7 c6 03 00 00 00    	test   $0x3,%esi
f0102b74:	75 13                	jne    f0102b89 <memmove+0x6b>
f0102b76:	a8 03                	test   $0x3,%al
f0102b78:	75 0f                	jne    f0102b89 <memmove+0x6b>
f0102b7a:	f6 c1 03             	test   $0x3,%cl
f0102b7d:	75 0a                	jne    f0102b89 <memmove+0x6b>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
f0102b7f:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
f0102b82:	89 c7                	mov    %eax,%edi
f0102b84:	fc                   	cld    
f0102b85:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0102b87:	eb 05                	jmp    f0102b8e <memmove+0x70>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
f0102b89:	89 c7                	mov    %eax,%edi
f0102b8b:	fc                   	cld    
f0102b8c:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
f0102b8e:	8b 34 24             	mov    (%esp),%esi
f0102b91:	8b 7c 24 04          	mov    0x4(%esp),%edi
f0102b95:	83 c4 08             	add    $0x8,%esp
f0102b98:	c3                   	ret    

f0102b99 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
f0102b99:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
f0102b9c:	8b 44 24 18          	mov    0x18(%esp),%eax
f0102ba0:	89 44 24 08          	mov    %eax,0x8(%esp)
f0102ba4:	8b 44 24 14          	mov    0x14(%esp),%eax
f0102ba8:	89 44 24 04          	mov    %eax,0x4(%esp)
f0102bac:	8b 44 24 10          	mov    0x10(%esp),%eax
f0102bb0:	89 04 24             	mov    %eax,(%esp)
f0102bb3:	e8 66 ff ff ff       	call   f0102b1e <memmove>
}
f0102bb8:	83 c4 0c             	add    $0xc,%esp
f0102bbb:	c3                   	ret    

f0102bbc <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
f0102bbc:	57                   	push   %edi
f0102bbd:	56                   	push   %esi
f0102bbe:	53                   	push   %ebx
f0102bbf:	8b 5c 24 10          	mov    0x10(%esp),%ebx
f0102bc3:	8b 74 24 14          	mov    0x14(%esp),%esi
f0102bc7:	8b 7c 24 18          	mov    0x18(%esp),%edi
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
f0102bcb:	b8 00 00 00 00       	mov    $0x0,%eax
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f0102bd0:	85 ff                	test   %edi,%edi
f0102bd2:	74 38                	je     f0102c0c <memcmp+0x50>
		if (*s1 != *s2)
f0102bd4:	0f b6 03             	movzbl (%ebx),%eax
f0102bd7:	0f b6 0e             	movzbl (%esi),%ecx
f0102bda:	38 c8                	cmp    %cl,%al
f0102bdc:	74 1d                	je     f0102bfb <memcmp+0x3f>
f0102bde:	eb 11                	jmp    f0102bf1 <memcmp+0x35>
f0102be0:	0f b6 44 13 01       	movzbl 0x1(%ebx,%edx,1),%eax
f0102be5:	0f b6 4c 16 01       	movzbl 0x1(%esi,%edx,1),%ecx
f0102bea:	83 c2 01             	add    $0x1,%edx
f0102bed:	38 c8                	cmp    %cl,%al
f0102bef:	74 12                	je     f0102c03 <memcmp+0x47>
			return (int) *s1 - (int) *s2;
f0102bf1:	0f b6 c0             	movzbl %al,%eax
f0102bf4:	0f b6 c9             	movzbl %cl,%ecx
f0102bf7:	29 c8                	sub    %ecx,%eax
f0102bf9:	eb 11                	jmp    f0102c0c <memcmp+0x50>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f0102bfb:	83 ef 01             	sub    $0x1,%edi
f0102bfe:	ba 00 00 00 00       	mov    $0x0,%edx
f0102c03:	39 fa                	cmp    %edi,%edx
f0102c05:	75 d9                	jne    f0102be0 <memcmp+0x24>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
f0102c07:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0102c0c:	5b                   	pop    %ebx
f0102c0d:	5e                   	pop    %esi
f0102c0e:	5f                   	pop    %edi
f0102c0f:	c3                   	ret    

f0102c10 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
f0102c10:	8b 44 24 04          	mov    0x4(%esp),%eax
	const void *ends = (const char *) s + n;
f0102c14:	89 c2                	mov    %eax,%edx
f0102c16:	03 54 24 0c          	add    0xc(%esp),%edx
	for (; s < ends; s++)
f0102c1a:	39 d0                	cmp    %edx,%eax
f0102c1c:	73 16                	jae    f0102c34 <memfind+0x24>
		if (*(const unsigned char *) s == (unsigned char) c)
f0102c1e:	0f b6 4c 24 08       	movzbl 0x8(%esp),%ecx
f0102c23:	38 08                	cmp    %cl,(%eax)
f0102c25:	75 06                	jne    f0102c2d <memfind+0x1d>
f0102c27:	f3 c3                	repz ret 
f0102c29:	38 08                	cmp    %cl,(%eax)
f0102c2b:	74 07                	je     f0102c34 <memfind+0x24>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
f0102c2d:	83 c0 01             	add    $0x1,%eax
f0102c30:	39 c2                	cmp    %eax,%edx
f0102c32:	77 f5                	ja     f0102c29 <memfind+0x19>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
f0102c34:	f3 c3                	repz ret 

f0102c36 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f0102c36:	55                   	push   %ebp
f0102c37:	57                   	push   %edi
f0102c38:	56                   	push   %esi
f0102c39:	53                   	push   %ebx
f0102c3a:	8b 54 24 14          	mov    0x14(%esp),%edx
f0102c3e:	8b 74 24 18          	mov    0x18(%esp),%esi
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f0102c42:	0f b6 02             	movzbl (%edx),%eax
f0102c45:	3c 20                	cmp    $0x20,%al
f0102c47:	74 04                	je     f0102c4d <strtol+0x17>
f0102c49:	3c 09                	cmp    $0x9,%al
f0102c4b:	75 0e                	jne    f0102c5b <strtol+0x25>
		s++;
f0102c4d:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f0102c50:	0f b6 02             	movzbl (%edx),%eax
f0102c53:	3c 20                	cmp    $0x20,%al
f0102c55:	74 f6                	je     f0102c4d <strtol+0x17>
f0102c57:	3c 09                	cmp    $0x9,%al
f0102c59:	74 f2                	je     f0102c4d <strtol+0x17>
		s++;

	// plus/minus sign
	if (*s == '+')
f0102c5b:	3c 2b                	cmp    $0x2b,%al
f0102c5d:	75 0a                	jne    f0102c69 <strtol+0x33>
		s++;
f0102c5f:	83 c2 01             	add    $0x1,%edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
f0102c62:	bf 00 00 00 00       	mov    $0x0,%edi
f0102c67:	eb 10                	jmp    f0102c79 <strtol+0x43>
f0102c69:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
f0102c6e:	3c 2d                	cmp    $0x2d,%al
f0102c70:	75 07                	jne    f0102c79 <strtol+0x43>
		s++, neg = 1;
f0102c72:	83 c2 01             	add    $0x1,%edx
f0102c75:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f0102c79:	83 7c 24 1c 00       	cmpl   $0x0,0x1c(%esp)
f0102c7e:	0f 94 c0             	sete   %al
f0102c81:	74 07                	je     f0102c8a <strtol+0x54>
f0102c83:	83 7c 24 1c 10       	cmpl   $0x10,0x1c(%esp)
f0102c88:	75 18                	jne    f0102ca2 <strtol+0x6c>
f0102c8a:	80 3a 30             	cmpb   $0x30,(%edx)
f0102c8d:	75 13                	jne    f0102ca2 <strtol+0x6c>
f0102c8f:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
f0102c93:	75 0d                	jne    f0102ca2 <strtol+0x6c>
		s += 2, base = 16;
f0102c95:	83 c2 02             	add    $0x2,%edx
f0102c98:	c7 44 24 1c 10 00 00 	movl   $0x10,0x1c(%esp)
f0102c9f:	00 
f0102ca0:	eb 1c                	jmp    f0102cbe <strtol+0x88>
	else if (base == 0 && s[0] == '0')
f0102ca2:	84 c0                	test   %al,%al
f0102ca4:	74 18                	je     f0102cbe <strtol+0x88>
		s++, base = 8;
	else if (base == 0)
		base = 10;
f0102ca6:	c7 44 24 1c 0a 00 00 	movl   $0xa,0x1c(%esp)
f0102cad:	00 
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f0102cae:	80 3a 30             	cmpb   $0x30,(%edx)
f0102cb1:	75 0b                	jne    f0102cbe <strtol+0x88>
		s++, base = 8;
f0102cb3:	83 c2 01             	add    $0x1,%edx
f0102cb6:	c7 44 24 1c 08 00 00 	movl   $0x8,0x1c(%esp)
f0102cbd:	00 
	else if (base == 0)
		base = 10;
f0102cbe:	b8 00 00 00 00       	mov    $0x0,%eax

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
f0102cc3:	0f b6 0a             	movzbl (%edx),%ecx
f0102cc6:	8d 69 d0             	lea    -0x30(%ecx),%ebp
f0102cc9:	89 eb                	mov    %ebp,%ebx
f0102ccb:	80 fb 09             	cmp    $0x9,%bl
f0102cce:	77 08                	ja     f0102cd8 <strtol+0xa2>
			dig = *s - '0';
f0102cd0:	0f be c9             	movsbl %cl,%ecx
f0102cd3:	83 e9 30             	sub    $0x30,%ecx
f0102cd6:	eb 22                	jmp    f0102cfa <strtol+0xc4>
		else if (*s >= 'a' && *s <= 'z')
f0102cd8:	8d 69 9f             	lea    -0x61(%ecx),%ebp
f0102cdb:	89 eb                	mov    %ebp,%ebx
f0102cdd:	80 fb 19             	cmp    $0x19,%bl
f0102ce0:	77 08                	ja     f0102cea <strtol+0xb4>
			dig = *s - 'a' + 10;
f0102ce2:	0f be c9             	movsbl %cl,%ecx
f0102ce5:	83 e9 57             	sub    $0x57,%ecx
f0102ce8:	eb 10                	jmp    f0102cfa <strtol+0xc4>
		else if (*s >= 'A' && *s <= 'Z')
f0102cea:	8d 69 bf             	lea    -0x41(%ecx),%ebp
f0102ced:	89 eb                	mov    %ebp,%ebx
f0102cef:	80 fb 19             	cmp    $0x19,%bl
f0102cf2:	77 19                	ja     f0102d0d <strtol+0xd7>
			dig = *s - 'A' + 10;
f0102cf4:	0f be c9             	movsbl %cl,%ecx
f0102cf7:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
f0102cfa:	3b 4c 24 1c          	cmp    0x1c(%esp),%ecx
f0102cfe:	7d 11                	jge    f0102d11 <strtol+0xdb>
			break;
		s++, val = (val * base) + dig;
f0102d00:	83 c2 01             	add    $0x1,%edx
f0102d03:	0f af 44 24 1c       	imul   0x1c(%esp),%eax
f0102d08:	8d 04 01             	lea    (%ecx,%eax,1),%eax
		// we don't properly detect overflow!
	}
f0102d0b:	eb b6                	jmp    f0102cc3 <strtol+0x8d>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
f0102d0d:	89 c1                	mov    %eax,%ecx
f0102d0f:	eb 02                	jmp    f0102d13 <strtol+0xdd>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
f0102d11:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
f0102d13:	85 f6                	test   %esi,%esi
f0102d15:	74 02                	je     f0102d19 <strtol+0xe3>
		*endptr = (char *) s;
f0102d17:	89 16                	mov    %edx,(%esi)
	return (neg ? -val : val);
f0102d19:	89 ca                	mov    %ecx,%edx
f0102d1b:	f7 da                	neg    %edx
f0102d1d:	85 ff                	test   %edi,%edi
f0102d1f:	0f 45 c2             	cmovne %edx,%eax
}
f0102d22:	5b                   	pop    %ebx
f0102d23:	5e                   	pop    %esi
f0102d24:	5f                   	pop    %edi
f0102d25:	5d                   	pop    %ebp
f0102d26:	c3                   	ret    
	...

f0102d30 <__udivdi3>:
f0102d30:	55                   	push   %ebp
f0102d31:	89 e5                	mov    %esp,%ebp
f0102d33:	57                   	push   %edi
f0102d34:	56                   	push   %esi
f0102d35:	8d 64 24 e0          	lea    -0x20(%esp),%esp
f0102d39:	8b 45 14             	mov    0x14(%ebp),%eax
f0102d3c:	8b 75 08             	mov    0x8(%ebp),%esi
f0102d3f:	8b 4d 10             	mov    0x10(%ebp),%ecx
f0102d42:	85 c0                	test   %eax,%eax
f0102d44:	89 75 e8             	mov    %esi,-0x18(%ebp)
f0102d47:	8b 7d 0c             	mov    0xc(%ebp),%edi
f0102d4a:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f0102d4d:	75 39                	jne    f0102d88 <__udivdi3+0x58>
f0102d4f:	39 f9                	cmp    %edi,%ecx
f0102d51:	77 65                	ja     f0102db8 <__udivdi3+0x88>
f0102d53:	85 c9                	test   %ecx,%ecx
f0102d55:	75 0b                	jne    f0102d62 <__udivdi3+0x32>
f0102d57:	b8 01 00 00 00       	mov    $0x1,%eax
f0102d5c:	31 d2                	xor    %edx,%edx
f0102d5e:	f7 f1                	div    %ecx
f0102d60:	89 c1                	mov    %eax,%ecx
f0102d62:	89 f8                	mov    %edi,%eax
f0102d64:	31 d2                	xor    %edx,%edx
f0102d66:	f7 f1                	div    %ecx
f0102d68:	89 c7                	mov    %eax,%edi
f0102d6a:	89 f0                	mov    %esi,%eax
f0102d6c:	f7 f1                	div    %ecx
f0102d6e:	89 fa                	mov    %edi,%edx
f0102d70:	89 c6                	mov    %eax,%esi
f0102d72:	89 75 f0             	mov    %esi,-0x10(%ebp)
f0102d75:	89 55 f4             	mov    %edx,-0xc(%ebp)
f0102d78:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0102d7b:	8b 55 f4             	mov    -0xc(%ebp),%edx
f0102d7e:	8d 64 24 20          	lea    0x20(%esp),%esp
f0102d82:	5e                   	pop    %esi
f0102d83:	5f                   	pop    %edi
f0102d84:	5d                   	pop    %ebp
f0102d85:	c3                   	ret    
f0102d86:	66 90                	xchg   %ax,%ax
f0102d88:	31 d2                	xor    %edx,%edx
f0102d8a:	31 f6                	xor    %esi,%esi
f0102d8c:	39 f8                	cmp    %edi,%eax
f0102d8e:	77 e2                	ja     f0102d72 <__udivdi3+0x42>
f0102d90:	0f bd d0             	bsr    %eax,%edx
f0102d93:	83 f2 1f             	xor    $0x1f,%edx
f0102d96:	89 55 ec             	mov    %edx,-0x14(%ebp)
f0102d99:	75 2d                	jne    f0102dc8 <__udivdi3+0x98>
f0102d9b:	8b 4d e8             	mov    -0x18(%ebp),%ecx
f0102d9e:	39 4d f0             	cmp    %ecx,-0x10(%ebp)
f0102da1:	76 06                	jbe    f0102da9 <__udivdi3+0x79>
f0102da3:	39 f8                	cmp    %edi,%eax
f0102da5:	89 f2                	mov    %esi,%edx
f0102da7:	73 c9                	jae    f0102d72 <__udivdi3+0x42>
f0102da9:	31 d2                	xor    %edx,%edx
f0102dab:	be 01 00 00 00       	mov    $0x1,%esi
f0102db0:	eb c0                	jmp    f0102d72 <__udivdi3+0x42>
f0102db2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0102db8:	89 f0                	mov    %esi,%eax
f0102dba:	89 fa                	mov    %edi,%edx
f0102dbc:	f7 f1                	div    %ecx
f0102dbe:	31 d2                	xor    %edx,%edx
f0102dc0:	89 c6                	mov    %eax,%esi
f0102dc2:	eb ae                	jmp    f0102d72 <__udivdi3+0x42>
f0102dc4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0102dc8:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
f0102dcc:	89 c2                	mov    %eax,%edx
f0102dce:	b8 20 00 00 00       	mov    $0x20,%eax
f0102dd3:	2b 45 ec             	sub    -0x14(%ebp),%eax
f0102dd6:	d3 e2                	shl    %cl,%edx
f0102dd8:	89 c1                	mov    %eax,%ecx
f0102dda:	8b 75 f0             	mov    -0x10(%ebp),%esi
f0102ddd:	d3 ee                	shr    %cl,%esi
f0102ddf:	09 d6                	or     %edx,%esi
f0102de1:	89 fa                	mov    %edi,%edx
f0102de3:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
f0102de7:	89 75 e4             	mov    %esi,-0x1c(%ebp)
f0102dea:	8b 75 f0             	mov    -0x10(%ebp),%esi
f0102ded:	d3 e6                	shl    %cl,%esi
f0102def:	89 c1                	mov    %eax,%ecx
f0102df1:	89 75 f0             	mov    %esi,-0x10(%ebp)
f0102df4:	8b 75 e8             	mov    -0x18(%ebp),%esi
f0102df7:	d3 ea                	shr    %cl,%edx
f0102df9:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
f0102dfd:	d3 e7                	shl    %cl,%edi
f0102dff:	89 c1                	mov    %eax,%ecx
f0102e01:	d3 ee                	shr    %cl,%esi
f0102e03:	09 fe                	or     %edi,%esi
f0102e05:	89 f0                	mov    %esi,%eax
f0102e07:	f7 75 e4             	divl   -0x1c(%ebp)
f0102e0a:	89 d7                	mov    %edx,%edi
f0102e0c:	89 c6                	mov    %eax,%esi
f0102e0e:	f7 65 f0             	mull   -0x10(%ebp)
f0102e11:	39 d7                	cmp    %edx,%edi
f0102e13:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f0102e16:	72 12                	jb     f0102e2a <__udivdi3+0xfa>
f0102e18:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
f0102e1c:	8b 55 e8             	mov    -0x18(%ebp),%edx
f0102e1f:	d3 e2                	shl    %cl,%edx
f0102e21:	39 c2                	cmp    %eax,%edx
f0102e23:	73 08                	jae    f0102e2d <__udivdi3+0xfd>
f0102e25:	3b 7d e4             	cmp    -0x1c(%ebp),%edi
f0102e28:	75 03                	jne    f0102e2d <__udivdi3+0xfd>
f0102e2a:	8d 76 ff             	lea    -0x1(%esi),%esi
f0102e2d:	31 d2                	xor    %edx,%edx
f0102e2f:	e9 3e ff ff ff       	jmp    f0102d72 <__udivdi3+0x42>
	...

f0102e40 <__umoddi3>:
f0102e40:	55                   	push   %ebp
f0102e41:	89 e5                	mov    %esp,%ebp
f0102e43:	57                   	push   %edi
f0102e44:	56                   	push   %esi
f0102e45:	8d 64 24 e0          	lea    -0x20(%esp),%esp
f0102e49:	8b 7d 14             	mov    0x14(%ebp),%edi
f0102e4c:	8b 45 08             	mov    0x8(%ebp),%eax
f0102e4f:	8b 4d 10             	mov    0x10(%ebp),%ecx
f0102e52:	8b 75 0c             	mov    0xc(%ebp),%esi
f0102e55:	85 ff                	test   %edi,%edi
f0102e57:	89 45 e8             	mov    %eax,-0x18(%ebp)
f0102e5a:	89 4d f4             	mov    %ecx,-0xc(%ebp)
f0102e5d:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0102e60:	89 f2                	mov    %esi,%edx
f0102e62:	75 14                	jne    f0102e78 <__umoddi3+0x38>
f0102e64:	39 f1                	cmp    %esi,%ecx
f0102e66:	76 40                	jbe    f0102ea8 <__umoddi3+0x68>
f0102e68:	f7 f1                	div    %ecx
f0102e6a:	89 d0                	mov    %edx,%eax
f0102e6c:	31 d2                	xor    %edx,%edx
f0102e6e:	8d 64 24 20          	lea    0x20(%esp),%esp
f0102e72:	5e                   	pop    %esi
f0102e73:	5f                   	pop    %edi
f0102e74:	5d                   	pop    %ebp
f0102e75:	c3                   	ret    
f0102e76:	66 90                	xchg   %ax,%ax
f0102e78:	39 f7                	cmp    %esi,%edi
f0102e7a:	77 4c                	ja     f0102ec8 <__umoddi3+0x88>
f0102e7c:	0f bd c7             	bsr    %edi,%eax
f0102e7f:	83 f0 1f             	xor    $0x1f,%eax
f0102e82:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0102e85:	75 51                	jne    f0102ed8 <__umoddi3+0x98>
f0102e87:	3b 4d f0             	cmp    -0x10(%ebp),%ecx
f0102e8a:	0f 87 e8 00 00 00    	ja     f0102f78 <__umoddi3+0x138>
f0102e90:	89 f2                	mov    %esi,%edx
f0102e92:	8b 75 f0             	mov    -0x10(%ebp),%esi
f0102e95:	29 ce                	sub    %ecx,%esi
f0102e97:	19 fa                	sbb    %edi,%edx
f0102e99:	89 75 f0             	mov    %esi,-0x10(%ebp)
f0102e9c:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0102e9f:	8d 64 24 20          	lea    0x20(%esp),%esp
f0102ea3:	5e                   	pop    %esi
f0102ea4:	5f                   	pop    %edi
f0102ea5:	5d                   	pop    %ebp
f0102ea6:	c3                   	ret    
f0102ea7:	90                   	nop
f0102ea8:	85 c9                	test   %ecx,%ecx
f0102eaa:	75 0b                	jne    f0102eb7 <__umoddi3+0x77>
f0102eac:	b8 01 00 00 00       	mov    $0x1,%eax
f0102eb1:	31 d2                	xor    %edx,%edx
f0102eb3:	f7 f1                	div    %ecx
f0102eb5:	89 c1                	mov    %eax,%ecx
f0102eb7:	89 f0                	mov    %esi,%eax
f0102eb9:	31 d2                	xor    %edx,%edx
f0102ebb:	f7 f1                	div    %ecx
f0102ebd:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0102ec0:	f7 f1                	div    %ecx
f0102ec2:	eb a6                	jmp    f0102e6a <__umoddi3+0x2a>
f0102ec4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0102ec8:	89 f2                	mov    %esi,%edx
f0102eca:	8d 64 24 20          	lea    0x20(%esp),%esp
f0102ece:	5e                   	pop    %esi
f0102ecf:	5f                   	pop    %edi
f0102ed0:	5d                   	pop    %ebp
f0102ed1:	c3                   	ret    
f0102ed2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0102ed8:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
f0102edc:	c7 45 f0 20 00 00 00 	movl   $0x20,-0x10(%ebp)
f0102ee3:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0102ee6:	29 45 f0             	sub    %eax,-0x10(%ebp)
f0102ee9:	d3 e7                	shl    %cl,%edi
f0102eeb:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0102eee:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
f0102ef2:	89 f2                	mov    %esi,%edx
f0102ef4:	d3 e8                	shr    %cl,%eax
f0102ef6:	09 f8                	or     %edi,%eax
f0102ef8:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
f0102efc:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0102eff:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0102f02:	d3 e0                	shl    %cl,%eax
f0102f04:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
f0102f08:	89 45 f4             	mov    %eax,-0xc(%ebp)
f0102f0b:	8b 45 e8             	mov    -0x18(%ebp),%eax
f0102f0e:	d3 ea                	shr    %cl,%edx
f0102f10:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
f0102f14:	d3 e6                	shl    %cl,%esi
f0102f16:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
f0102f1a:	d3 e8                	shr    %cl,%eax
f0102f1c:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
f0102f20:	09 f0                	or     %esi,%eax
f0102f22:	8b 75 e8             	mov    -0x18(%ebp),%esi
f0102f25:	d3 e6                	shl    %cl,%esi
f0102f27:	f7 75 e4             	divl   -0x1c(%ebp)
f0102f2a:	89 75 e8             	mov    %esi,-0x18(%ebp)
f0102f2d:	89 d6                	mov    %edx,%esi
f0102f2f:	f7 65 f4             	mull   -0xc(%ebp)
f0102f32:	89 d7                	mov    %edx,%edi
f0102f34:	89 c2                	mov    %eax,%edx
f0102f36:	39 fe                	cmp    %edi,%esi
f0102f38:	89 f9                	mov    %edi,%ecx
f0102f3a:	72 30                	jb     f0102f6c <__umoddi3+0x12c>
f0102f3c:	39 45 e8             	cmp    %eax,-0x18(%ebp)
f0102f3f:	72 27                	jb     f0102f68 <__umoddi3+0x128>
f0102f41:	8b 45 e8             	mov    -0x18(%ebp),%eax
f0102f44:	29 d0                	sub    %edx,%eax
f0102f46:	19 ce                	sbb    %ecx,%esi
f0102f48:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
f0102f4c:	89 f2                	mov    %esi,%edx
f0102f4e:	d3 e8                	shr    %cl,%eax
f0102f50:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
f0102f54:	d3 e2                	shl    %cl,%edx
f0102f56:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
f0102f5a:	09 d0                	or     %edx,%eax
f0102f5c:	89 f2                	mov    %esi,%edx
f0102f5e:	d3 ea                	shr    %cl,%edx
f0102f60:	8d 64 24 20          	lea    0x20(%esp),%esp
f0102f64:	5e                   	pop    %esi
f0102f65:	5f                   	pop    %edi
f0102f66:	5d                   	pop    %ebp
f0102f67:	c3                   	ret    
f0102f68:	39 fe                	cmp    %edi,%esi
f0102f6a:	75 d5                	jne    f0102f41 <__umoddi3+0x101>
f0102f6c:	89 f9                	mov    %edi,%ecx
f0102f6e:	89 c2                	mov    %eax,%edx
f0102f70:	2b 55 f4             	sub    -0xc(%ebp),%edx
f0102f73:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
f0102f76:	eb c9                	jmp    f0102f41 <__umoddi3+0x101>
f0102f78:	39 f7                	cmp    %esi,%edi
f0102f7a:	0f 82 10 ff ff ff    	jb     f0102e90 <__umoddi3+0x50>
f0102f80:	e9 17 ff ff ff       	jmp    f0102e9c <__umoddi3+0x5c>
