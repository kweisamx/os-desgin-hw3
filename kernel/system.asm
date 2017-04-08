
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
f010005f:	e8 b3 04 00 00       	call   f0100517 <init_video>

	pic_init();
f0100064:	e8 4b 00 00 00       	call   f01000b4 <pic_init>
  /* TODO: You should uncomment them
   */
	 kbd_init();
f0100069:	e8 68 02 00 00       	call   f01002d6 <kbd_init>
	 timer_init();
f010006e:	e8 30 23 00 00       	call   f01023a3 <timer_init>
	 trap_init();
f0100073:	e8 ed 06 00 00       	call   f0100765 <trap_init>
     mem_init();
f0100078:	e8 f8 0d 00 00       	call   f0100e75 <mem_init>
	/* Enable interrupt */
    __asm __volatile("sti");

    /* Test for page fault handler */
    ptr = (int*)(0x12345678);
   *ptr = 1;
f010007d:	c7 05 78 56 34 12 01 	movl   $0x1,0x12345678
f0100084:	00 00 00 
	 timer_init();
	 trap_init();
     mem_init();

	/* Enable interrupt */
    __asm __volatile("sti");
f0100087:	fb                   	sti    
    /* Test for page fault handler */
    ptr = (int*)(0x12345678);
   *ptr = 1;

	shell();
}
f0100088:	83 c4 0c             	add    $0xc,%esp

    /* Test for page fault handler */
    ptr = (int*)(0x12345678);
   *ptr = 1;

	shell();
f010008b:	e9 d9 21 00 00       	jmp    f0102269 <shell>

f0100090 <irq_setmask_8259A>:
		irq_setmask_8259A(irq_mask_8259A);
}

void
irq_setmask_8259A(uint16_t mask)
{
f0100090:	8b 54 24 04          	mov    0x4(%esp),%edx
	int i;
	irq_mask_8259A = mask;
	if (!didinit)
f0100094:	80 3d 00 00 11 f0 00 	cmpb   $0x0,0xf0110000
		irq_setmask_8259A(irq_mask_8259A);
}

void
irq_setmask_8259A(uint16_t mask)
{
f010009b:	89 d0                	mov    %edx,%eax
	int i;
	irq_mask_8259A = mask;
f010009d:	66 89 15 00 50 10 f0 	mov    %dx,0xf0105000
	if (!didinit)
f01000a4:	74 0d                	je     f01000b3 <irq_setmask_8259A+0x23>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01000a6:	ba 21 00 00 00       	mov    $0x21,%edx
f01000ab:	ee                   	out    %al,(%dx)
		return;
	outb(IO_PIC1+1, (char)mask);
	outb(IO_PIC2+1, (char)(mask >> 8));
f01000ac:	66 c1 e8 08          	shr    $0x8,%ax
f01000b0:	b2 a1                	mov    $0xa1,%dl
f01000b2:	ee                   	out    %al,(%dx)
f01000b3:	c3                   	ret    

f01000b4 <pic_init>:
static bool didinit;

/* Initialize the 8259A interrupt controllers. */
void
pic_init(void)
{
f01000b4:	57                   	push   %edi
f01000b5:	b9 21 00 00 00       	mov    $0x21,%ecx
f01000ba:	56                   	push   %esi
f01000bb:	b0 ff                	mov    $0xff,%al
f01000bd:	53                   	push   %ebx
f01000be:	89 ca                	mov    %ecx,%edx
f01000c0:	ee                   	out    %al,(%dx)
f01000c1:	be a1 00 00 00       	mov    $0xa1,%esi
f01000c6:	89 f2                	mov    %esi,%edx
f01000c8:	ee                   	out    %al,(%dx)
f01000c9:	bf 11 00 00 00       	mov    $0x11,%edi
f01000ce:	bb 20 00 00 00       	mov    $0x20,%ebx
f01000d3:	89 f8                	mov    %edi,%eax
f01000d5:	89 da                	mov    %ebx,%edx
f01000d7:	ee                   	out    %al,(%dx)
f01000d8:	b0 20                	mov    $0x20,%al
f01000da:	89 ca                	mov    %ecx,%edx
f01000dc:	ee                   	out    %al,(%dx)
f01000dd:	b0 04                	mov    $0x4,%al
f01000df:	ee                   	out    %al,(%dx)
f01000e0:	b0 03                	mov    $0x3,%al
f01000e2:	ee                   	out    %al,(%dx)
f01000e3:	b1 a0                	mov    $0xa0,%cl
f01000e5:	89 f8                	mov    %edi,%eax
f01000e7:	89 ca                	mov    %ecx,%edx
f01000e9:	ee                   	out    %al,(%dx)
f01000ea:	b0 28                	mov    $0x28,%al
f01000ec:	89 f2                	mov    %esi,%edx
f01000ee:	ee                   	out    %al,(%dx)
f01000ef:	b0 02                	mov    $0x2,%al
f01000f1:	ee                   	out    %al,(%dx)
f01000f2:	b0 01                	mov    $0x1,%al
f01000f4:	ee                   	out    %al,(%dx)
f01000f5:	bf 68 00 00 00       	mov    $0x68,%edi
f01000fa:	89 da                	mov    %ebx,%edx
f01000fc:	89 f8                	mov    %edi,%eax
f01000fe:	ee                   	out    %al,(%dx)
f01000ff:	be 0a 00 00 00       	mov    $0xa,%esi
f0100104:	89 f0                	mov    %esi,%eax
f0100106:	ee                   	out    %al,(%dx)
f0100107:	89 f8                	mov    %edi,%eax
f0100109:	89 ca                	mov    %ecx,%edx
f010010b:	ee                   	out    %al,(%dx)
f010010c:	89 f0                	mov    %esi,%eax
f010010e:	ee                   	out    %al,(%dx)
	outb(IO_PIC1, 0x0a);             /* read IRR by default */

	outb(IO_PIC2, 0x68);               /* OCW3 */
	outb(IO_PIC2, 0x0a);               /* OCW3 */

	if (irq_mask_8259A != 0xFFFF)
f010010f:	66 a1 00 50 10 f0    	mov    0xf0105000,%ax

/* Initialize the 8259A interrupt controllers. */
void
pic_init(void)
{
	didinit = 1;
f0100115:	c6 05 00 00 11 f0 01 	movb   $0x1,0xf0110000
	outb(IO_PIC1, 0x0a);             /* read IRR by default */

	outb(IO_PIC2, 0x68);               /* OCW3 */
	outb(IO_PIC2, 0x0a);               /* OCW3 */

	if (irq_mask_8259A != 0xFFFF)
f010011c:	66 83 f8 ff          	cmp    $0xffffffff,%ax
f0100120:	74 0a                	je     f010012c <pic_init+0x78>
		irq_setmask_8259A(irq_mask_8259A);
f0100122:	0f b7 c0             	movzwl %ax,%eax
f0100125:	50                   	push   %eax
f0100126:	e8 65 ff ff ff       	call   f0100090 <irq_setmask_8259A>
f010012b:	58                   	pop    %eax
}
f010012c:	5b                   	pop    %ebx
f010012d:	5e                   	pop    %esi
f010012e:	5f                   	pop    %edi
f010012f:	c3                   	ret    

f0100130 <kbd_proc_data>:
 * Get data from the keyboard.  If we finish a character, return it.  Else 0.
 * Return -1 if no data.
 */
static int
kbd_proc_data(void)
{
f0100130:	83 ec 1c             	sub    $0x1c,%esp

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100133:	ba 64 00 00 00       	mov    $0x64,%edx
f0100138:	ec                   	in     (%dx),%al
f0100139:	88 c2                	mov    %al,%dl
	volatile int c;
	volatile uint8_t data;
	static uint32_t shift;

	if ((inb(KBSTATP) & KBS_DIB) == 0)
		return -1;
f010013b:	83 c8 ff             	or     $0xffffffff,%eax
{
	volatile int c;
	volatile uint8_t data;
	static uint32_t shift;

	if ((inb(KBSTATP) & KBS_DIB) == 0)
f010013e:	80 e2 01             	and    $0x1,%dl
f0100141:	0f 84 28 01 00 00    	je     f010026f <kbd_proc_data+0x13f>
f0100147:	ba 60 00 00 00       	mov    $0x60,%edx
f010014c:	ec                   	in     (%dx),%al
		return -1;

	data = inb(KBDATAP);
f010014d:	88 44 24 0f          	mov    %al,0xf(%esp)

	if (data == 0xE0) {
f0100151:	8a 44 24 0f          	mov    0xf(%esp),%al
f0100155:	3c e0                	cmp    $0xe0,%al
f0100157:	75 09                	jne    f0100162 <kbd_proc_data+0x32>
		// E0 escape character
		shift |= E0ESC;
f0100159:	83 0d 0c 02 11 f0 40 	orl    $0x40,0xf011020c
f0100160:	eb 40                	jmp    f01001a2 <kbd_proc_data+0x72>
		return 0;
	} else if (data & 0x80) {
f0100162:	8a 44 24 0f          	mov    0xf(%esp),%al
f0100166:	8b 15 0c 02 11 f0    	mov    0xf011020c,%edx
f010016c:	84 c0                	test   %al,%al
f010016e:	79 39                	jns    f01001a9 <kbd_proc_data+0x79>
		// Key released
		data = (shift & E0ESC ? data : data & 0x7F);
f0100170:	f6 c2 40             	test   $0x40,%dl
f0100173:	74 06                	je     f010017b <kbd_proc_data+0x4b>
f0100175:	8a 44 24 0f          	mov    0xf(%esp),%al
f0100179:	eb 07                	jmp    f0100182 <kbd_proc_data+0x52>
f010017b:	8a 44 24 0f          	mov    0xf(%esp),%al
f010017f:	83 e0 7f             	and    $0x7f,%eax
f0100182:	88 44 24 0f          	mov    %al,0xf(%esp)
		shift &= ~(shiftcode[data] | E0ESC);
f0100186:	8a 44 24 0f          	mov    0xf(%esp),%al
f010018a:	0f b6 c0             	movzbl %al,%eax
f010018d:	8a 80 8c 31 10 f0    	mov    -0xfefce74(%eax),%al
f0100193:	83 c8 40             	or     $0x40,%eax
f0100196:	0f b6 c0             	movzbl %al,%eax
f0100199:	f7 d0                	not    %eax
f010019b:	21 d0                	and    %edx,%eax
f010019d:	a3 0c 02 11 f0       	mov    %eax,0xf011020c
		return 0;
f01001a2:	31 c0                	xor    %eax,%eax
f01001a4:	e9 c6 00 00 00       	jmp    f010026f <kbd_proc_data+0x13f>
	} else if (shift & E0ESC) {
f01001a9:	f6 c2 40             	test   $0x40,%dl
f01001ac:	74 14                	je     f01001c2 <kbd_proc_data+0x92>
		// Last character was an E0 escape; or with 0x80
		data |= 0x80;
f01001ae:	8a 44 24 0f          	mov    0xf(%esp),%al
		shift &= ~E0ESC;
f01001b2:	83 e2 bf             	and    $0xffffffbf,%edx
f01001b5:	89 15 0c 02 11 f0    	mov    %edx,0xf011020c
		data = (shift & E0ESC ? data : data & 0x7F);
		shift &= ~(shiftcode[data] | E0ESC);
		return 0;
	} else if (shift & E0ESC) {
		// Last character was an E0 escape; or with 0x80
		data |= 0x80;
f01001bb:	83 c8 80             	or     $0xffffff80,%eax
f01001be:	88 44 24 0f          	mov    %al,0xf(%esp)
		shift &= ~E0ESC;
	}

	shift |= shiftcode[data];
f01001c2:	8a 44 24 0f          	mov    0xf(%esp),%al
	shift ^= togglecode[data];
f01001c6:	8a 54 24 0f          	mov    0xf(%esp),%dl
		// Last character was an E0 escape; or with 0x80
		data |= 0x80;
		shift &= ~E0ESC;
	}

	shift |= shiftcode[data];
f01001ca:	0f b6 c0             	movzbl %al,%eax
	shift ^= togglecode[data];
f01001cd:	0f b6 d2             	movzbl %dl,%edx
		// Last character was an E0 escape; or with 0x80
		data |= 0x80;
		shift &= ~E0ESC;
	}

	shift |= shiftcode[data];
f01001d0:	0f b6 80 8c 31 10 f0 	movzbl -0xfefce74(%eax),%eax
	shift ^= togglecode[data];
f01001d7:	0f b6 92 8c 32 10 f0 	movzbl -0xfefcd74(%edx),%edx
		// Last character was an E0 escape; or with 0x80
		data |= 0x80;
		shift &= ~E0ESC;
	}

	shift |= shiftcode[data];
f01001de:	0b 05 0c 02 11 f0    	or     0xf011020c,%eax
	shift ^= togglecode[data];
f01001e4:	31 d0                	xor    %edx,%eax

	c = charcode[shift & (CTL | SHIFT)][data];
f01001e6:	8a 54 24 0f          	mov    0xf(%esp),%dl
f01001ea:	89 c1                	mov    %eax,%ecx
f01001ec:	83 e1 03             	and    $0x3,%ecx
	if (shift & CAPSLOCK) {
f01001ef:	a8 08                	test   $0x8,%al
	}

	shift |= shiftcode[data];
	shift ^= togglecode[data];

	c = charcode[shift & (CTL | SHIFT)][data];
f01001f1:	8b 0c 8d 8c 33 10 f0 	mov    -0xfefcc74(,%ecx,4),%ecx
f01001f8:	0f b6 d2             	movzbl %dl,%edx
		data |= 0x80;
		shift &= ~E0ESC;
	}

	shift |= shiftcode[data];
	shift ^= togglecode[data];
f01001fb:	a3 0c 02 11 f0       	mov    %eax,0xf011020c

	c = charcode[shift & (CTL | SHIFT)][data];
f0100200:	0f b6 14 11          	movzbl (%ecx,%edx,1),%edx
f0100204:	89 54 24 08          	mov    %edx,0x8(%esp)
	if (shift & CAPSLOCK) {
f0100208:	74 38                	je     f0100242 <kbd_proc_data+0x112>
		if ('a' <= c && c <= 'z')
f010020a:	8b 54 24 08          	mov    0x8(%esp),%edx
f010020e:	83 fa 60             	cmp    $0x60,%edx
f0100211:	7e 12                	jle    f0100225 <kbd_proc_data+0xf5>
f0100213:	8b 54 24 08          	mov    0x8(%esp),%edx
f0100217:	83 fa 7a             	cmp    $0x7a,%edx
f010021a:	7f 09                	jg     f0100225 <kbd_proc_data+0xf5>
			c += 'A' - 'a';
f010021c:	8b 54 24 08          	mov    0x8(%esp),%edx
f0100220:	83 ea 20             	sub    $0x20,%edx
f0100223:	eb 19                	jmp    f010023e <kbd_proc_data+0x10e>
		else if ('A' <= c && c <= 'Z')
f0100225:	8b 54 24 08          	mov    0x8(%esp),%edx
f0100229:	83 fa 40             	cmp    $0x40,%edx
f010022c:	7e 14                	jle    f0100242 <kbd_proc_data+0x112>
f010022e:	8b 54 24 08          	mov    0x8(%esp),%edx
f0100232:	83 fa 5a             	cmp    $0x5a,%edx
f0100235:	7f 0b                	jg     f0100242 <kbd_proc_data+0x112>
			c += 'a' - 'A';
f0100237:	8b 54 24 08          	mov    0x8(%esp),%edx
f010023b:	83 c2 20             	add    $0x20,%edx
f010023e:	89 54 24 08          	mov    %edx,0x8(%esp)
	}

	// Process special keys
	// Ctrl-Alt-Del: reboot
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
f0100242:	f7 d0                	not    %eax
f0100244:	a8 06                	test   $0x6,%al
f0100246:	75 23                	jne    f010026b <kbd_proc_data+0x13b>
f0100248:	8b 44 24 08          	mov    0x8(%esp),%eax
f010024c:	3d e9 00 00 00       	cmp    $0xe9,%eax
f0100251:	75 18                	jne    f010026b <kbd_proc_data+0x13b>
		cprintf("Rebooting!\n");
f0100253:	83 ec 0c             	sub    $0xc,%esp
f0100256:	68 80 31 10 f0       	push   $0xf0103180
f010025b:	e8 e6 05 00 00       	call   f0100846 <cprintf>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100260:	ba 92 00 00 00       	mov    $0x92,%edx
f0100265:	b0 03                	mov    $0x3,%al
f0100267:	ee                   	out    %al,(%dx)
f0100268:	83 c4 10             	add    $0x10,%esp
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
f010026b:	8b 44 24 08          	mov    0x8(%esp),%eax
}
f010026f:	83 c4 1c             	add    $0x1c,%esp
f0100272:	c3                   	ret    

f0100273 <cons_getc>:
	// so that this function works even when interrupts are disabled
	// (e.g., when called from the kernel monitor).
	//kbd_intr();

	// grab the next character from the input buffer.
	if (cons.rpos != cons.wpos) {
f0100273:	8b 15 04 02 11 f0    	mov    0xf0110204,%edx
		c = cons.buf[cons.rpos++];
		if (cons.rpos == CONSBUFSIZE)
			cons.rpos = 0;
		return c;
	}
	return 0;
f0100279:	31 c0                	xor    %eax,%eax
	// so that this function works even when interrupts are disabled
	// (e.g., when called from the kernel monitor).
	//kbd_intr();

	// grab the next character from the input buffer.
	if (cons.rpos != cons.wpos) {
f010027b:	3b 15 08 02 11 f0    	cmp    0xf0110208,%edx
f0100281:	74 1b                	je     f010029e <cons_getc+0x2b>
		c = cons.buf[cons.rpos++];
f0100283:	8d 4a 01             	lea    0x1(%edx),%ecx
f0100286:	0f b6 82 04 00 11 f0 	movzbl -0xfeefffc(%edx),%eax
		if (cons.rpos == CONSBUFSIZE)
			cons.rpos = 0;
f010028d:	31 d2                	xor    %edx,%edx
f010028f:	81 f9 00 02 00 00    	cmp    $0x200,%ecx
f0100295:	0f 45 d1             	cmovne %ecx,%edx
f0100298:	89 15 04 02 11 f0    	mov    %edx,0xf0110204
		return c;
	}
	return 0;
}
f010029e:	c3                   	ret    

f010029f <kbd_intr>:
/* 
 *  Note: The interrupt handler
 */
void
kbd_intr(void)
{
f010029f:	53                   	push   %ebx
	while ((c = (*proc)()) != -1) {
		if (c == 0)
			continue;
		cons.buf[cons.wpos++] = c;
		if (cons.wpos == CONSBUFSIZE)
			cons.wpos = 0;
f01002a0:	31 db                	xor    %ebx,%ebx
/* 
 *  Note: The interrupt handler
 */
void
kbd_intr(void)
{
f01002a2:	83 ec 08             	sub    $0x8,%esp
f01002a5:	eb 20                	jmp    f01002c7 <kbd_intr+0x28>
cons_intr(int (*proc)(void))
{
	int c;

	while ((c = (*proc)()) != -1) {
		if (c == 0)
f01002a7:	85 c0                	test   %eax,%eax
f01002a9:	74 1c                	je     f01002c7 <kbd_intr+0x28>
			continue;
		cons.buf[cons.wpos++] = c;
f01002ab:	8b 15 08 02 11 f0    	mov    0xf0110208,%edx
f01002b1:	88 82 04 00 11 f0    	mov    %al,-0xfeefffc(%edx)
f01002b7:	8d 42 01             	lea    0x1(%edx),%eax
		if (cons.wpos == CONSBUFSIZE)
			cons.wpos = 0;
f01002ba:	3d 00 02 00 00       	cmp    $0x200,%eax
f01002bf:	0f 44 c3             	cmove  %ebx,%eax
f01002c2:	a3 08 02 11 f0       	mov    %eax,0xf0110208
static void
cons_intr(int (*proc)(void))
{
	int c;

	while ((c = (*proc)()) != -1) {
f01002c7:	e8 64 fe ff ff       	call   f0100130 <kbd_proc_data>
f01002cc:	83 f8 ff             	cmp    $0xffffffff,%eax
f01002cf:	75 d6                	jne    f01002a7 <kbd_intr+0x8>
 */
void
kbd_intr(void)
{
	cons_intr(kbd_proc_data);
}
f01002d1:	83 c4 08             	add    $0x8,%esp
f01002d4:	5b                   	pop    %ebx
f01002d5:	c3                   	ret    

f01002d6 <kbd_init>:

void kbd_init(void)
{
f01002d6:	83 ec 0c             	sub    $0xc,%esp
	// Drain the kbd buffer so that Bochs generates interrupts.
    cons.rpos = 0;
f01002d9:	c7 05 04 02 11 f0 00 	movl   $0x0,0xf0110204
f01002e0:	00 00 00 
    cons.wpos = 0;
f01002e3:	c7 05 08 02 11 f0 00 	movl   $0x0,0xf0110208
f01002ea:	00 00 00 
	kbd_intr();
f01002ed:	e8 ad ff ff ff       	call   f010029f <kbd_intr>
	irq_setmask_8259A(irq_mask_8259A & ~(1<<IRQ_KBD));
f01002f2:	0f b7 05 00 50 10 f0 	movzwl 0xf0105000,%eax
f01002f9:	83 ec 0c             	sub    $0xc,%esp
f01002fc:	25 fd ff 00 00       	and    $0xfffd,%eax
f0100301:	50                   	push   %eax
f0100302:	e8 89 fd ff ff       	call   f0100090 <irq_setmask_8259A>
}
f0100307:	83 c4 1c             	add    $0x1c,%esp
f010030a:	c3                   	ret    

f010030b <getc>:
/* high-level console I/O */
int getc(void)
{
	int c;

	while ((c = cons_getc()) == 0)
f010030b:	e8 63 ff ff ff       	call   f0100273 <cons_getc>
f0100310:	85 c0                	test   %eax,%eax
f0100312:	74 f7                	je     f010030b <getc>
		/* do nothing */;
	return c;
}
f0100314:	c3                   	ret    
f0100315:	00 00                	add    %al,(%eax)
	...

f0100318 <scroll>:
int attrib = 0x0F;
int csr_x = 0, csr_y = 0;

/* Scrolls the screen */
void scroll(void)
{
f0100318:	56                   	push   %esi
f0100319:	53                   	push   %ebx
f010031a:	83 ec 04             	sub    $0x4,%esp
    /* A blank is defined as a space... we need to give it
    *  backcolor too */
    blank = 0x0 | (attrib << 8);

    /* Row 25 is the end, this means we need to scroll up */
    if(csr_y >= 25)
f010031d:	8b 1d 14 02 11 f0    	mov    0xf0110214,%ebx
{
    unsigned short blank, temp;

    /* A blank is defined as a space... we need to give it
    *  backcolor too */
    blank = 0x0 | (attrib << 8);
f0100323:	8b 35 04 53 10 f0    	mov    0xf0105304,%esi

    /* Row 25 is the end, this means we need to scroll up */
    if(csr_y >= 25)
f0100329:	83 fb 18             	cmp    $0x18,%ebx
f010032c:	7e 58                	jle    f0100386 <scroll+0x6e>
    {
        /* Move the current text chunk that makes up the screen
        *  back in the buffer by a line */
        temp = csr_y - 25 + 1;
f010032e:	83 eb 18             	sub    $0x18,%ebx
        memcpy (textmemptr, textmemptr + temp * 80, (25 - temp) * 80 * 2);
f0100331:	a1 40 06 11 f0       	mov    0xf0110640,%eax
f0100336:	0f b7 db             	movzwl %bx,%ebx
f0100339:	52                   	push   %edx
f010033a:	69 d3 60 ff ff ff    	imul   $0xffffff60,%ebx,%edx
{
    unsigned short blank, temp;

    /* A blank is defined as a space... we need to give it
    *  backcolor too */
    blank = 0x0 | (attrib << 8);
f0100340:	c1 e6 08             	shl    $0x8,%esi
        temp = csr_y - 25 + 1;
        memcpy (textmemptr, textmemptr + temp * 80, (25 - temp) * 80 * 2);

        /* Finally, we set the chunk of memory that occupies
        *  the last line of text to our 'blank' character */
        memset (textmemptr + (25 - temp) * 80, blank, 80);
f0100343:	0f b7 f6             	movzwl %si,%esi
    if(csr_y >= 25)
    {
        /* Move the current text chunk that makes up the screen
        *  back in the buffer by a line */
        temp = csr_y - 25 + 1;
        memcpy (textmemptr, textmemptr + temp * 80, (25 - temp) * 80 * 2);
f0100346:	81 c2 a0 0f 00 00    	add    $0xfa0,%edx
f010034c:	52                   	push   %edx
f010034d:	69 d3 a0 00 00 00    	imul   $0xa0,%ebx,%edx

        /* Finally, we set the chunk of memory that occupies
        *  the last line of text to our 'blank' character */
        memset (textmemptr + (25 - temp) * 80, blank, 80);
f0100353:	6b db b0             	imul   $0xffffffb0,%ebx,%ebx
    if(csr_y >= 25)
    {
        /* Move the current text chunk that makes up the screen
        *  back in the buffer by a line */
        temp = csr_y - 25 + 1;
        memcpy (textmemptr, textmemptr + temp * 80, (25 - temp) * 80 * 2);
f0100356:	8d 14 10             	lea    (%eax,%edx,1),%edx
f0100359:	52                   	push   %edx
f010035a:	50                   	push   %eax
f010035b:	e8 29 2a 00 00       	call   f0102d89 <memcpy>

        /* Finally, we set the chunk of memory that occupies
        *  the last line of text to our 'blank' character */
        memset (textmemptr + (25 - temp) * 80, blank, 80);
f0100360:	83 c4 0c             	add    $0xc,%esp
f0100363:	8d 84 1b a0 0f 00 00 	lea    0xfa0(%ebx,%ebx,1),%eax
f010036a:	03 05 40 06 11 f0    	add    0xf0110640,%eax
f0100370:	6a 50                	push   $0x50
f0100372:	56                   	push   %esi
f0100373:	50                   	push   %eax
f0100374:	e8 36 29 00 00       	call   f0102caf <memset>
        csr_y = 25 - 1;
f0100379:	83 c4 10             	add    $0x10,%esp
f010037c:	c7 05 14 02 11 f0 18 	movl   $0x18,0xf0110214
f0100383:	00 00 00 
    }
}
f0100386:	83 c4 04             	add    $0x4,%esp
f0100389:	5b                   	pop    %ebx
f010038a:	5e                   	pop    %esi
f010038b:	c3                   	ret    

f010038c <move_csr>:
    unsigned short temp;

    /* The equation for finding the index in a linear
    *  chunk of memory can be represented by:
    *  Index = [(y * width) + x] */
    temp = csr_y * 80 + csr_x;
f010038c:	66 6b 0d 14 02 11 f0 	imul   $0x50,0xf0110214,%cx
f0100393:	50 
f0100394:	ba d4 03 00 00       	mov    $0x3d4,%edx
f0100399:	03 0d 10 02 11 f0    	add    0xf0110210,%ecx
f010039f:	b0 0e                	mov    $0xe,%al
f01003a1:	ee                   	out    %al,(%dx)
    *  where the hardware cursor is to be 'blinking'. To
    *  learn more, you should look up some VGA specific
    *  programming documents. A great start to graphics:
    *  http://www.brackeen.com/home/vga */
    outb(0x3D4, 14);
    outb(0x3D5, temp >> 8);
f01003a2:	89 c8                	mov    %ecx,%eax
f01003a4:	b2 d5                	mov    $0xd5,%dl
f01003a6:	66 c1 e8 08          	shr    $0x8,%ax
f01003aa:	ee                   	out    %al,(%dx)
f01003ab:	b0 0f                	mov    $0xf,%al
f01003ad:	b2 d4                	mov    $0xd4,%dl
f01003af:	ee                   	out    %al,(%dx)
f01003b0:	b2 d5                	mov    $0xd5,%dl
f01003b2:	88 c8                	mov    %cl,%al
f01003b4:	ee                   	out    %al,(%dx)
    outb(0x3D4, 15);
    outb(0x3D5, temp);
}
f01003b5:	c3                   	ret    

f01003b6 <cls>:

/* Clears the screen */
void cls()
{
f01003b6:	56                   	push   %esi
f01003b7:	53                   	push   %ebx
    unsigned short blank;
    int i;

    /* Again, we need the 'short' that will be used to
    *  represent a space with color */
    blank = 0x0 | (attrib << 8);
f01003b8:	31 db                	xor    %ebx,%ebx
    outb(0x3D5, temp);
}

/* Clears the screen */
void cls()
{
f01003ba:	83 ec 04             	sub    $0x4,%esp
    unsigned short blank;
    int i;

    /* Again, we need the 'short' that will be used to
    *  represent a space with color */
    blank = 0x0 | (attrib << 8);
f01003bd:	8b 35 04 53 10 f0    	mov    0xf0105304,%esi
f01003c3:	c1 e6 08             	shl    $0x8,%esi

    /* Sets the entire screen to spaces in our current
    *  color */
    for(i = 0; i < 25; i++)
        memset (textmemptr + i * 80, blank, 80);
f01003c6:	0f b7 f6             	movzwl %si,%esi
f01003c9:	a1 40 06 11 f0       	mov    0xf0110640,%eax
f01003ce:	51                   	push   %ecx
f01003cf:	6a 50                	push   $0x50
f01003d1:	56                   	push   %esi
f01003d2:	01 d8                	add    %ebx,%eax
f01003d4:	81 c3 a0 00 00 00    	add    $0xa0,%ebx
f01003da:	50                   	push   %eax
f01003db:	e8 cf 28 00 00       	call   f0102caf <memset>
    *  represent a space with color */
    blank = 0x0 | (attrib << 8);

    /* Sets the entire screen to spaces in our current
    *  color */
    for(i = 0; i < 25; i++)
f01003e0:	83 c4 10             	add    $0x10,%esp
f01003e3:	81 fb a0 0f 00 00    	cmp    $0xfa0,%ebx
f01003e9:	75 de                	jne    f01003c9 <cls+0x13>
        memset (textmemptr + i * 80, blank, 80);

    /* Update out virtual cursor, and then move the
    *  hardware cursor */
    csr_x = 0;
f01003eb:	c7 05 10 02 11 f0 00 	movl   $0x0,0xf0110210
f01003f2:	00 00 00 
    csr_y = 0;
f01003f5:	c7 05 14 02 11 f0 00 	movl   $0x0,0xf0110214
f01003fc:	00 00 00 
    move_csr();
}
f01003ff:	83 c4 04             	add    $0x4,%esp
f0100402:	5b                   	pop    %ebx
f0100403:	5e                   	pop    %esi

    /* Update out virtual cursor, and then move the
    *  hardware cursor */
    csr_x = 0;
    csr_y = 0;
    move_csr();
f0100404:	e9 83 ff ff ff       	jmp    f010038c <move_csr>

f0100409 <putch>:
}

/* Puts a single character on the screen */
void putch(unsigned char c)
{
f0100409:	53                   	push   %ebx
f010040a:	83 ec 08             	sub    $0x8,%esp
    unsigned short *where;
    unsigned short att = attrib << 8;
f010040d:	8b 0d 04 53 10 f0    	mov    0xf0105304,%ecx
    move_csr();
}

/* Puts a single character on the screen */
void putch(unsigned char c)
{
f0100413:	8a 44 24 10          	mov    0x10(%esp),%al
    unsigned short *where;
    unsigned short att = attrib << 8;
f0100417:	c1 e1 08             	shl    $0x8,%ecx

    /* Handle a backspace, by moving the cursor back one space */
    if(c == 0x08)
f010041a:	3c 08                	cmp    $0x8,%al
f010041c:	75 21                	jne    f010043f <putch+0x36>
    {
        if(csr_x != 0) {
f010041e:	a1 10 02 11 f0       	mov    0xf0110210,%eax
f0100423:	85 c0                	test   %eax,%eax
f0100425:	74 7d                	je     f01004a4 <putch+0x9b>
          where = (textmemptr-1) + (csr_y * 80 + csr_x);
f0100427:	6b 15 14 02 11 f0 50 	imul   $0x50,0xf0110214,%edx
f010042e:	8d 5c 10 ff          	lea    -0x1(%eax,%edx,1),%ebx
          *where = 0x0 | att;	/* Character AND attributes: color */
f0100432:	8b 15 40 06 11 f0    	mov    0xf0110640,%edx
          csr_x--;
f0100438:	48                   	dec    %eax
    /* Handle a backspace, by moving the cursor back one space */
    if(c == 0x08)
    {
        if(csr_x != 0) {
          where = (textmemptr-1) + (csr_y * 80 + csr_x);
          *where = 0x0 | att;	/* Character AND attributes: color */
f0100439:	66 89 0c 5a          	mov    %cx,(%edx,%ebx,2)
f010043d:	eb 0f                	jmp    f010044e <putch+0x45>
          csr_x--;
        }
    }
    /* Handles a tab by incrementing the cursor's x, but only
    *  to a point that will make it divisible by 8 */
    else if(c == 0x09)
f010043f:	3c 09                	cmp    $0x9,%al
f0100441:	75 12                	jne    f0100455 <putch+0x4c>
    {
        csr_x = (csr_x + 8) & ~(8 - 1);
f0100443:	a1 10 02 11 f0       	mov    0xf0110210,%eax
f0100448:	83 c0 08             	add    $0x8,%eax
f010044b:	83 e0 f8             	and    $0xfffffff8,%eax
f010044e:	a3 10 02 11 f0       	mov    %eax,0xf0110210
f0100453:	eb 4f                	jmp    f01004a4 <putch+0x9b>
    }
    /* Handles a 'Carriage Return', which simply brings the
    *  cursor back to the margin */
    else if(c == '\r')
f0100455:	3c 0d                	cmp    $0xd,%al
f0100457:	75 0c                	jne    f0100465 <putch+0x5c>
    {
        csr_x = 0;
f0100459:	c7 05 10 02 11 f0 00 	movl   $0x0,0xf0110210
f0100460:	00 00 00 
f0100463:	eb 3f                	jmp    f01004a4 <putch+0x9b>
    }
    /* We handle our newlines the way DOS and the BIOS do: we
    *  treat it as if a 'CR' was also there, so we bring the
    *  cursor to the margin and we increment the 'y' value */
    else if(c == '\n')
f0100465:	3c 0a                	cmp    $0xa,%al
f0100467:	75 12                	jne    f010047b <putch+0x72>
    {
        csr_x = 0;
f0100469:	c7 05 10 02 11 f0 00 	movl   $0x0,0xf0110210
f0100470:	00 00 00 
        csr_y++;
f0100473:	ff 05 14 02 11 f0    	incl   0xf0110214
f0100479:	eb 29                	jmp    f01004a4 <putch+0x9b>
    }
    /* Any character greater than and including a space, is a
    *  printable character. The equation for finding the index
    *  in a linear chunk of memory can be represented by:
    *  Index = [(y * width) + x] */
    else if(c >= ' ')
f010047b:	3c 1f                	cmp    $0x1f,%al
f010047d:	76 25                	jbe    f01004a4 <putch+0x9b>
    {
        where = textmemptr + (csr_y * 80 + csr_x);
f010047f:	8b 15 10 02 11 f0    	mov    0xf0110210,%edx
        *where = c | att;	/* Character AND attributes: color */
f0100485:	0f b6 c0             	movzbl %al,%eax
    *  printable character. The equation for finding the index
    *  in a linear chunk of memory can be represented by:
    *  Index = [(y * width) + x] */
    else if(c >= ' ')
    {
        where = textmemptr + (csr_y * 80 + csr_x);
f0100488:	6b 1d 14 02 11 f0 50 	imul   $0x50,0xf0110214,%ebx
        *where = c | att;	/* Character AND attributes: color */
f010048f:	09 c8                	or     %ecx,%eax
f0100491:	8b 0d 40 06 11 f0    	mov    0xf0110640,%ecx
    *  printable character. The equation for finding the index
    *  in a linear chunk of memory can be represented by:
    *  Index = [(y * width) + x] */
    else if(c >= ' ')
    {
        where = textmemptr + (csr_y * 80 + csr_x);
f0100497:	01 d3                	add    %edx,%ebx
        *where = c | att;	/* Character AND attributes: color */
        csr_x++;
f0100499:	42                   	inc    %edx
    *  in a linear chunk of memory can be represented by:
    *  Index = [(y * width) + x] */
    else if(c >= ' ')
    {
        where = textmemptr + (csr_y * 80 + csr_x);
        *where = c | att;	/* Character AND attributes: color */
f010049a:	66 89 04 59          	mov    %ax,(%ecx,%ebx,2)
        csr_x++;
f010049e:	89 15 10 02 11 f0    	mov    %edx,0xf0110210
    }

    /* If the cursor has reached the edge of the screen's width, we
    *  insert a new line in there */
    if(csr_x >= 80)
f01004a4:	83 3d 10 02 11 f0 4f 	cmpl   $0x4f,0xf0110210
f01004ab:	7e 10                	jle    f01004bd <putch+0xb4>
    {
        csr_x = 0;
        csr_y++;
f01004ad:	ff 05 14 02 11 f0    	incl   0xf0110214

    /* If the cursor has reached the edge of the screen's width, we
    *  insert a new line in there */
    if(csr_x >= 80)
    {
        csr_x = 0;
f01004b3:	c7 05 10 02 11 f0 00 	movl   $0x0,0xf0110210
f01004ba:	00 00 00 
        csr_y++;
    }

    /* Scroll the screen if needed, and finally move the cursor */
    scroll();
f01004bd:	e8 56 fe ff ff       	call   f0100318 <scroll>
    move_csr();
}
f01004c2:	83 c4 08             	add    $0x8,%esp
f01004c5:	5b                   	pop    %ebx
        csr_y++;
    }

    /* Scroll the screen if needed, and finally move the cursor */
    scroll();
    move_csr();
f01004c6:	e9 c1 fe ff ff       	jmp    f010038c <move_csr>

f01004cb <puts>:
}

/* Uses the above routine to output a string... */
void puts(unsigned char *text)
{
f01004cb:	56                   	push   %esi
f01004cc:	53                   	push   %ebx
    int i;

    for (i = 0; i < strlen(text); i++)
f01004cd:	31 db                	xor    %ebx,%ebx
    move_csr();
}

/* Uses the above routine to output a string... */
void puts(unsigned char *text)
{
f01004cf:	83 ec 04             	sub    $0x4,%esp
f01004d2:	8b 74 24 10          	mov    0x10(%esp),%esi
    int i;

    for (i = 0; i < strlen(text); i++)
f01004d6:	eb 11                	jmp    f01004e9 <puts+0x1e>
    {
        putch(text[i]);
f01004d8:	0f b6 04 1e          	movzbl (%esi,%ebx,1),%eax
f01004dc:	83 ec 0c             	sub    $0xc,%esp
/* Uses the above routine to output a string... */
void puts(unsigned char *text)
{
    int i;

    for (i = 0; i < strlen(text); i++)
f01004df:	43                   	inc    %ebx
    {
        putch(text[i]);
f01004e0:	50                   	push   %eax
f01004e1:	e8 23 ff ff ff       	call   f0100409 <putch>
/* Uses the above routine to output a string... */
void puts(unsigned char *text)
{
    int i;

    for (i = 0; i < strlen(text); i++)
f01004e6:	83 c4 10             	add    $0x10,%esp
f01004e9:	83 ec 0c             	sub    $0xc,%esp
f01004ec:	56                   	push   %esi
f01004ed:	e8 ee 25 00 00       	call   f0102ae0 <strlen>
f01004f2:	83 c4 10             	add    $0x10,%esp
f01004f5:	39 c3                	cmp    %eax,%ebx
f01004f7:	7c df                	jl     f01004d8 <puts+0xd>
    {
        putch(text[i]);
    }
}
f01004f9:	83 c4 04             	add    $0x4,%esp
f01004fc:	5b                   	pop    %ebx
f01004fd:	5e                   	pop    %esi
f01004fe:	c3                   	ret    

f01004ff <settextcolor>:
void settextcolor(unsigned char forecolor, unsigned char backcolor)
{
    /* Lab3: Use this function */
    /* Top 4 bit are the background, bottom 4 bytes
    *  are the foreground color */
    attrib = (backcolor << 4) | (forecolor & 0x0F);
f01004ff:	0f b6 44 24 08       	movzbl 0x8(%esp),%eax
f0100504:	0f b6 54 24 04       	movzbl 0x4(%esp),%edx
f0100509:	c1 e0 04             	shl    $0x4,%eax
f010050c:	83 e2 0f             	and    $0xf,%edx
f010050f:	09 d0                	or     %edx,%eax
f0100511:	a3 04 53 10 f0       	mov    %eax,0xf0105304
}
f0100516:	c3                   	ret    

f0100517 <init_video>:

/* Sets our text-mode VGA pointer, then clears the screen for us */
void init_video(void)
{
f0100517:	83 ec 0c             	sub    $0xc,%esp
    textmemptr = (unsigned short *)0xB8000;
f010051a:	c7 05 40 06 11 f0 00 	movl   $0xb8000,0xf0110640
f0100521:	80 0b 00 
    cls();
}
f0100524:	83 c4 0c             	add    $0xc,%esp

/* Sets our text-mode VGA pointer, then clears the screen for us */
void init_video(void)
{
    textmemptr = (unsigned short *)0xB8000;
    cls();
f0100527:	e9 8a fe ff ff       	jmp    f01003b6 <cls>

f010052c <print_regs>:
}

/* For debugging */
void
print_regs(struct PushRegs *regs)
{
f010052c:	53                   	push   %ebx
f010052d:	83 ec 10             	sub    $0x10,%esp
f0100530:	8b 5c 24 18          	mov    0x18(%esp),%ebx
	cprintf("  edi  0x%08x\n", regs->reg_edi);
f0100534:	ff 33                	pushl  (%ebx)
f0100536:	68 9c 33 10 f0       	push   $0xf010339c
f010053b:	e8 06 03 00 00       	call   f0100846 <cprintf>
	cprintf("  esi  0x%08x\n", regs->reg_esi);
f0100540:	58                   	pop    %eax
f0100541:	5a                   	pop    %edx
f0100542:	ff 73 04             	pushl  0x4(%ebx)
f0100545:	68 ab 33 10 f0       	push   $0xf01033ab
f010054a:	e8 f7 02 00 00       	call   f0100846 <cprintf>
	cprintf("  ebp  0x%08x\n", regs->reg_ebp);
f010054f:	5a                   	pop    %edx
f0100550:	59                   	pop    %ecx
f0100551:	ff 73 08             	pushl  0x8(%ebx)
f0100554:	68 ba 33 10 f0       	push   $0xf01033ba
f0100559:	e8 e8 02 00 00       	call   f0100846 <cprintf>
	cprintf("  oesp 0x%08x\n", regs->reg_oesp);
f010055e:	59                   	pop    %ecx
f010055f:	58                   	pop    %eax
f0100560:	ff 73 0c             	pushl  0xc(%ebx)
f0100563:	68 c9 33 10 f0       	push   $0xf01033c9
f0100568:	e8 d9 02 00 00       	call   f0100846 <cprintf>
	cprintf("  ebx  0x%08x\n", regs->reg_ebx);
f010056d:	58                   	pop    %eax
f010056e:	5a                   	pop    %edx
f010056f:	ff 73 10             	pushl  0x10(%ebx)
f0100572:	68 d8 33 10 f0       	push   $0xf01033d8
f0100577:	e8 ca 02 00 00       	call   f0100846 <cprintf>
	cprintf("  edx  0x%08x\n", regs->reg_edx);
f010057c:	5a                   	pop    %edx
f010057d:	59                   	pop    %ecx
f010057e:	ff 73 14             	pushl  0x14(%ebx)
f0100581:	68 e7 33 10 f0       	push   $0xf01033e7
f0100586:	e8 bb 02 00 00       	call   f0100846 <cprintf>
	cprintf("  ecx  0x%08x\n", regs->reg_ecx);
f010058b:	59                   	pop    %ecx
f010058c:	58                   	pop    %eax
f010058d:	ff 73 18             	pushl  0x18(%ebx)
f0100590:	68 f6 33 10 f0       	push   $0xf01033f6
f0100595:	e8 ac 02 00 00       	call   f0100846 <cprintf>
	cprintf("  eax  0x%08x\n", regs->reg_eax);
f010059a:	58                   	pop    %eax
f010059b:	5a                   	pop    %edx
f010059c:	ff 73 1c             	pushl  0x1c(%ebx)
f010059f:	68 05 34 10 f0       	push   $0xf0103405
f01005a4:	e8 9d 02 00 00       	call   f0100846 <cprintf>
}
f01005a9:	83 c4 18             	add    $0x18,%esp
f01005ac:	5b                   	pop    %ebx
f01005ad:	c3                   	ret    

f01005ae <print_trapframe>:
}

/* For debugging */
void
print_trapframe(struct Trapframe *tf)
{
f01005ae:	56                   	push   %esi
f01005af:	53                   	push   %ebx
f01005b0:	83 ec 10             	sub    $0x10,%esp
f01005b3:	8b 5c 24 1c          	mov    0x1c(%esp),%ebx
	cprintf("TRAP frame at %p \n");
f01005b7:	68 69 34 10 f0       	push   $0xf0103469
f01005bc:	e8 85 02 00 00       	call   f0100846 <cprintf>
	print_regs(&tf->tf_regs);
f01005c1:	89 1c 24             	mov    %ebx,(%esp)
f01005c4:	e8 63 ff ff ff       	call   f010052c <print_regs>
	cprintf("  es   0x----%04x\n", tf->tf_es);
f01005c9:	0f b7 43 20          	movzwl 0x20(%ebx),%eax
f01005cd:	5a                   	pop    %edx
f01005ce:	59                   	pop    %ecx
f01005cf:	50                   	push   %eax
f01005d0:	68 7c 34 10 f0       	push   $0xf010347c
f01005d5:	e8 6c 02 00 00       	call   f0100846 <cprintf>
	cprintf("  ds   0x----%04x\n", tf->tf_ds);
f01005da:	5e                   	pop    %esi
f01005db:	58                   	pop    %eax
f01005dc:	0f b7 43 24          	movzwl 0x24(%ebx),%eax
f01005e0:	50                   	push   %eax
f01005e1:	68 8f 34 10 f0       	push   $0xf010348f
f01005e6:	e8 5b 02 00 00       	call   f0100846 <cprintf>
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f01005eb:	8b 43 28             	mov    0x28(%ebx),%eax
		"Alignment Check",
		"Machine-Check",
		"SIMD Floating-Point Exception"
	};

	if (trapno < sizeof(excnames)/sizeof(excnames[0]))
f01005ee:	83 c4 10             	add    $0x10,%esp
f01005f1:	83 f8 13             	cmp    $0x13,%eax
f01005f4:	77 09                	ja     f01005ff <print_trapframe+0x51>
		return excnames[trapno];
f01005f6:	8b 14 85 94 36 10 f0 	mov    -0xfefc96c(,%eax,4),%edx
f01005fd:	eb 1d                	jmp    f010061c <print_trapframe+0x6e>
	if (trapno == T_SYSCALL)
f01005ff:	83 f8 30             	cmp    $0x30,%eax
		return "System call";
f0100602:	ba 14 34 10 f0       	mov    $0xf0103414,%edx
		"SIMD Floating-Point Exception"
	};

	if (trapno < sizeof(excnames)/sizeof(excnames[0]))
		return excnames[trapno];
	if (trapno == T_SYSCALL)
f0100607:	74 13                	je     f010061c <print_trapframe+0x6e>
		return "System call";
	if (trapno >= IRQ_OFFSET && trapno < IRQ_OFFSET + 16)
f0100609:	8d 48 e0             	lea    -0x20(%eax),%ecx
		return "Hardware Interrupt";
f010060c:	ba 20 34 10 f0       	mov    $0xf0103420,%edx
f0100611:	83 f9 0f             	cmp    $0xf,%ecx
f0100614:	b9 33 34 10 f0       	mov    $0xf0103433,%ecx
f0100619:	0f 47 d1             	cmova  %ecx,%edx
{
	cprintf("TRAP frame at %p \n");
	print_regs(&tf->tf_regs);
	cprintf("  es   0x----%04x\n", tf->tf_es);
	cprintf("  ds   0x----%04x\n", tf->tf_ds);
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f010061c:	51                   	push   %ecx
f010061d:	52                   	push   %edx
f010061e:	50                   	push   %eax
f010061f:	68 a2 34 10 f0       	push   $0xf01034a2
f0100624:	e8 1d 02 00 00       	call   f0100846 <cprintf>
	// If this trap was a page fault that just happened
	// (so %cr2 is meaningful), print the faulting linear address.
	if (tf == last_tf && tf->tf_trapno == T_PGFLT)
f0100629:	83 c4 10             	add    $0x10,%esp
f010062c:	3b 1d 18 02 11 f0    	cmp    0xf0110218,%ebx
f0100632:	75 19                	jne    f010064d <print_trapframe+0x9f>
f0100634:	83 7b 28 0e          	cmpl   $0xe,0x28(%ebx)
f0100638:	75 13                	jne    f010064d <print_trapframe+0x9f>

static __inline uint32_t
rcr2(void)
{
	uint32_t val;
	__asm __volatile("movl %%cr2,%0" : "=r" (val));
f010063a:	0f 20 d0             	mov    %cr2,%eax
		cprintf("  cr2  0x%08x\n", rcr2());
f010063d:	52                   	push   %edx
f010063e:	52                   	push   %edx
f010063f:	50                   	push   %eax
f0100640:	68 b4 34 10 f0       	push   $0xf01034b4
f0100645:	e8 fc 01 00 00       	call   f0100846 <cprintf>
f010064a:	83 c4 10             	add    $0x10,%esp
	cprintf("  err  0x%08x", tf->tf_err);
f010064d:	56                   	push   %esi
f010064e:	56                   	push   %esi
f010064f:	ff 73 2c             	pushl  0x2c(%ebx)
f0100652:	68 c3 34 10 f0       	push   $0xf01034c3
f0100657:	e8 ea 01 00 00       	call   f0100846 <cprintf>
	// For page faults, print decoded fault error code:
	// U/K=fault occurred in user/kernel mode
	// W/R=a write/read caused the fault
	// PR=a protection violation caused the fault (NP=page not present).
	if (tf->tf_trapno == T_PGFLT)
f010065c:	83 c4 10             	add    $0x10,%esp
f010065f:	83 7b 28 0e          	cmpl   $0xe,0x28(%ebx)
f0100663:	75 43                	jne    f01006a8 <print_trapframe+0xfa>
		cprintf(" [%s, %s, %s]\n",
			tf->tf_err & 4 ? "user" : "kernel",
			tf->tf_err & 2 ? "write" : "read",
			tf->tf_err & 1 ? "protection" : "not-present");
f0100665:	8b 73 2c             	mov    0x2c(%ebx),%esi
	// For page faults, print decoded fault error code:
	// U/K=fault occurred in user/kernel mode
	// W/R=a write/read caused the fault
	// PR=a protection violation caused the fault (NP=page not present).
	if (tf->tf_trapno == T_PGFLT)
		cprintf(" [%s, %s, %s]\n",
f0100668:	b8 4d 34 10 f0       	mov    $0xf010344d,%eax
f010066d:	b9 42 34 10 f0       	mov    $0xf0103442,%ecx
f0100672:	ba 59 34 10 f0       	mov    $0xf0103459,%edx
f0100677:	f7 c6 01 00 00 00    	test   $0x1,%esi
f010067d:	0f 44 c8             	cmove  %eax,%ecx
f0100680:	f7 c6 02 00 00 00    	test   $0x2,%esi
f0100686:	b8 5f 34 10 f0       	mov    $0xf010345f,%eax
f010068b:	0f 44 d0             	cmove  %eax,%edx
f010068e:	83 e6 04             	and    $0x4,%esi
f0100691:	51                   	push   %ecx
f0100692:	b8 64 34 10 f0       	mov    $0xf0103464,%eax
f0100697:	be 3b 42 10 f0       	mov    $0xf010423b,%esi
f010069c:	52                   	push   %edx
f010069d:	0f 44 c6             	cmove  %esi,%eax
f01006a0:	50                   	push   %eax
f01006a1:	68 d1 34 10 f0       	push   $0xf01034d1
f01006a6:	eb 08                	jmp    f01006b0 <print_trapframe+0x102>
			tf->tf_err & 4 ? "user" : "kernel",
			tf->tf_err & 2 ? "write" : "read",
			tf->tf_err & 1 ? "protection" : "not-present");
	else
		cprintf("\n");
f01006a8:	83 ec 0c             	sub    $0xc,%esp
f01006ab:	68 7a 34 10 f0       	push   $0xf010347a
f01006b0:	e8 91 01 00 00       	call   f0100846 <cprintf>
f01006b5:	5a                   	pop    %edx
f01006b6:	59                   	pop    %ecx
	cprintf("  eip  0x%08x\n", tf->tf_eip);
f01006b7:	ff 73 30             	pushl  0x30(%ebx)
f01006ba:	68 e0 34 10 f0       	push   $0xf01034e0
f01006bf:	e8 82 01 00 00       	call   f0100846 <cprintf>
	cprintf("  cs   0x----%04x\n", tf->tf_cs);
f01006c4:	5e                   	pop    %esi
f01006c5:	58                   	pop    %eax
f01006c6:	0f b7 43 34          	movzwl 0x34(%ebx),%eax
f01006ca:	50                   	push   %eax
f01006cb:	68 ef 34 10 f0       	push   $0xf01034ef
f01006d0:	e8 71 01 00 00       	call   f0100846 <cprintf>
	cprintf("  flag 0x%08x\n", tf->tf_eflags);
f01006d5:	5a                   	pop    %edx
f01006d6:	59                   	pop    %ecx
f01006d7:	ff 73 38             	pushl  0x38(%ebx)
f01006da:	68 02 35 10 f0       	push   $0xf0103502
f01006df:	e8 62 01 00 00       	call   f0100846 <cprintf>
	if ((tf->tf_cs & 3) != 0) {
f01006e4:	83 c4 10             	add    $0x10,%esp
f01006e7:	f6 43 34 03          	testb  $0x3,0x34(%ebx)
f01006eb:	74 23                	je     f0100710 <print_trapframe+0x162>
		cprintf("  esp  0x%08x\n", tf->tf_esp);
f01006ed:	50                   	push   %eax
f01006ee:	50                   	push   %eax
f01006ef:	ff 73 3c             	pushl  0x3c(%ebx)
f01006f2:	68 11 35 10 f0       	push   $0xf0103511
f01006f7:	e8 4a 01 00 00       	call   f0100846 <cprintf>
		cprintf("  ss   0x----%04x\n", tf->tf_ss);
f01006fc:	0f b7 43 40          	movzwl 0x40(%ebx),%eax
f0100700:	59                   	pop    %ecx
f0100701:	5e                   	pop    %esi
f0100702:	50                   	push   %eax
f0100703:	68 20 35 10 f0       	push   $0xf0103520
f0100708:	e8 39 01 00 00       	call   f0100846 <cprintf>
f010070d:	83 c4 10             	add    $0x10,%esp
	}
}
f0100710:	83 c4 04             	add    $0x4,%esp
f0100713:	5b                   	pop    %ebx
f0100714:	5e                   	pop    %esi
f0100715:	c3                   	ret    

f0100716 <default_trap_handler>:

/* 
 * Note: This is the called for every interrupt.
 */
void default_trap_handler(struct Trapframe *tf)
{
f0100716:	83 ec 0c             	sub    $0xc,%esp
f0100719:	8b 44 24 10          	mov    0x10(%esp),%eax
}

static void
trap_dispatch(struct Trapframe *tf)
{
    if(tf->tf_trapno == IRQ_OFFSET + IRQ_KBD)
f010071d:	8b 50 28             	mov    0x28(%eax),%edx
 */
void default_trap_handler(struct Trapframe *tf)
{
	// Record that tf is the last real trapframe so
	// print_trapframe can print some additional information.
	last_tf = tf;
f0100720:	a3 18 02 11 f0       	mov    %eax,0xf0110218
}

static void
trap_dispatch(struct Trapframe *tf)
{
    if(tf->tf_trapno == IRQ_OFFSET + IRQ_KBD)
f0100725:	83 fa 21             	cmp    $0x21,%edx
f0100728:	75 08                	jne    f0100732 <default_trap_handler+0x1c>
	// print_trapframe can print some additional information.
	last_tf = tf;

	// Dispatch based on what type of trap occurred
	trap_dispatch(tf);
}
f010072a:	83 c4 0c             	add    $0xc,%esp
static void
trap_dispatch(struct Trapframe *tf)
{
    if(tf->tf_trapno == IRQ_OFFSET + IRQ_KBD)
    {
        kbd_intr();
f010072d:	e9 6d fb ff ff       	jmp    f010029f <kbd_intr>
        return;
    }
    if(tf->tf_trapno == IRQ_OFFSET + IRQ_TIMER)
f0100732:	83 fa 20             	cmp    $0x20,%edx
f0100735:	75 08                	jne    f010073f <default_trap_handler+0x29>
	// print_trapframe can print some additional information.
	last_tf = tf;

	// Dispatch based on what type of trap occurred
	trap_dispatch(tf);
}
f0100737:	83 c4 0c             	add    $0xc,%esp
        kbd_intr();
        return;
    }
    if(tf->tf_trapno == IRQ_OFFSET + IRQ_TIMER)
    {
        timer_handler();
f010073a:	e9 57 1c 00 00       	jmp    f0102396 <timer_handler>
        return;
    }
    if(tf->tf_trapno == T_PGFLT)
f010073f:	83 fa 0e             	cmp    $0xe,%edx
f0100742:	75 15                	jne    f0100759 <default_trap_handler+0x43>
f0100744:	0f 20 d0             	mov    %cr2,%eax
    {
		cprintf("0556148 Page Fault @ 0x%08x\n", rcr2());
f0100747:	52                   	push   %edx
f0100748:	52                   	push   %edx
f0100749:	50                   	push   %eax
f010074a:	68 33 35 10 f0       	push   $0xf0103533
f010074f:	e8 f2 00 00 00       	call   f0100846 <cprintf>
f0100754:	83 c4 10             	add    $0x10,%esp
f0100757:	eb fe                	jmp    f0100757 <default_trap_handler+0x41>
   *       We prepared the keyboard handler and timer handler for you
   *       already. Please reference in kernel/kbd.c and kernel/timer.c
   */

	// Unexpected trap: The user process or the kernel has a bug.
	print_trapframe(tf);
f0100759:	89 44 24 10          	mov    %eax,0x10(%esp)
	// print_trapframe can print some additional information.
	last_tf = tf;

	// Dispatch based on what type of trap occurred
	trap_dispatch(tf);
}
f010075d:	83 c4 0c             	add    $0xc,%esp
   *       We prepared the keyboard handler and timer handler for you
   *       already. Please reference in kernel/kbd.c and kernel/timer.c
   */

	// Unexpected trap: The user process or the kernel has a bug.
	print_trapframe(tf);
f0100760:	e9 49 fe ff ff       	jmp    f01005ae <print_trapframe>

f0100765 <trap_init>:
 //   int i;                                                                       
   // for(i = 0;i < 256; i++)
     //   SETGATE(idt[i],0,GD_KT,64*i,0);
           //it is means to map idt to function
           //trap_entry.s is to define the function of handler
    SETGATE(idt[IRQ_OFFSET + IRQ_KBD],0,GD_KT,kbd,0);
f0100765:	b8 f6 07 10 f0       	mov    $0xf01007f6,%eax
f010076a:	66 a3 4c 07 11 f0    	mov    %ax,0xf011074c
f0100770:	c1 e8 10             	shr    $0x10,%eax
f0100773:	66 a3 52 07 11 f0    	mov    %ax,0xf0110752
    SETGATE(idt[IRQ_OFFSET + IRQ_TIMER],0,GD_KT,timer,0);
f0100779:	b8 f0 07 10 f0       	mov    $0xf01007f0,%eax
f010077e:	66 a3 44 07 11 f0    	mov    %ax,0xf0110744
f0100784:	c1 e8 10             	shr    $0x10,%eax
f0100787:	66 a3 4a 07 11 f0    	mov    %ax,0xf011074a
    SETGATE(idt[T_PGFLT],1,GD_KT,pagefault,0);
f010078d:	b8 fc 07 10 f0       	mov    $0xf01007fc,%eax
f0100792:	66 a3 b4 06 11 f0    	mov    %ax,0xf01106b4
f0100798:	c1 e8 10             	shr    $0x10,%eax
f010079b:	66 a3 ba 06 11 f0    	mov    %ax,0xf01106ba
}

static __inline void
lidt(void *p)
{
	__asm __volatile("lidt (%0)" : : "r" (p));
f01007a1:	b8 08 53 10 f0       	mov    $0xf0105308,%eax
 //   int i;                                                                       
   // for(i = 0;i < 256; i++)
     //   SETGATE(idt[i],0,GD_KT,64*i,0);
           //it is means to map idt to function
           //trap_entry.s is to define the function of handler
    SETGATE(idt[IRQ_OFFSET + IRQ_KBD],0,GD_KT,kbd,0);
f01007a6:	66 c7 05 4e 07 11 f0 	movw   $0x8,0xf011074e
f01007ad:	08 00 
f01007af:	c6 05 50 07 11 f0 00 	movb   $0x0,0xf0110750
f01007b6:	c6 05 51 07 11 f0 8e 	movb   $0x8e,0xf0110751
    SETGATE(idt[IRQ_OFFSET + IRQ_TIMER],0,GD_KT,timer,0);
f01007bd:	66 c7 05 46 07 11 f0 	movw   $0x8,0xf0110746
f01007c4:	08 00 
f01007c6:	c6 05 48 07 11 f0 00 	movb   $0x0,0xf0110748
f01007cd:	c6 05 49 07 11 f0 8e 	movb   $0x8e,0xf0110749
    SETGATE(idt[T_PGFLT],1,GD_KT,pagefault,0);
f01007d4:	66 c7 05 b6 06 11 f0 	movw   $0x8,0xf01106b6
f01007db:	08 00 
f01007dd:	c6 05 b8 06 11 f0 00 	movb   $0x0,0xf01106b8
f01007e4:	c6 05 b9 06 11 f0 8f 	movb   $0x8f,0xf01106b9
f01007eb:	0f 01 18             	lidtl  (%eax)

	/* Keyboard interrupt setup */
	/* Timer Trap setup */
  /* Load IDT */

}
f01007ee:	c3                   	ret    
	...

f01007f0 <timer>:
	pushl $(num);							\
	jmp _alltraps


.text
    TRAPHANDLER_NOEC(timer,IRQ_OFFSET + IRQ_TIMER)
f01007f0:	6a 00                	push   $0x0
f01007f2:	6a 20                	push   $0x20
f01007f4:	eb 0c                	jmp    f0100802 <_alltraps>

f01007f6 <kbd>:
    TRAPHANDLER_NOEC(kbd,IRQ_OFFSET + IRQ_KBD)   
f01007f6:	6a 00                	push   $0x0
f01007f8:	6a 21                	push   $0x21
f01007fa:	eb 06                	jmp    f0100802 <_alltraps>

f01007fc <pagefault>:
    TRAPHANDLER_NOEC(pagefault,T_PGFLT)
f01007fc:	6a 00                	push   $0x0
f01007fe:	6a 0e                	push   $0xe
f0100800:	eb 00                	jmp    f0100802 <_alltraps>

f0100802 <_alltraps>:
   *       CPU.
   *       You may want to leverage the "pusha" instructions to reduce your work of
   *       pushing all the general purpose registers into the stack.
	 */
/*because  in kernel stack ,we need to reverse the push order trapno ->     ds - > es -> pusha*/
    pushl %ds
f0100802:	1e                   	push   %ds
    pushl %es
f0100803:	06                   	push   %es
    pusha          #  push AX CX BX SP BP SI DI
f0100804:	60                   	pusha  

    /*load kernel segment */
    movw $(GD_KT), %ax
f0100805:	66 b8 08 00          	mov    $0x8,%ax
    movw %ax , %ds
f0100809:	8e d8                	mov    %eax,%ds
    movw %ax , %es
f010080b:	8e c0                	mov    %eax,%es

	pushl %esp # Pass a pointer which points to the Trapframe as an argument to default_trap_handler()
f010080d:	54                   	push   %esp
	call default_trap_handler
f010080e:	e8 03 ff ff ff       	call   f0100716 <default_trap_handler>
    popl %esp
f0100813:	5c                   	pop    %esp
    popa
f0100814:	61                   	popa   
    popl %es
f0100815:	07                   	pop    %es
    popl %ds
f0100816:	1f                   	pop    %ds

	add $8, %esp # Cleans up the pushed error code and pushed ISR number
f0100817:	83 c4 08             	add    $0x8,%esp
	iret # pops 5 things at once: CS, EIP, EFLAGS, SS, and ESP!
f010081a:	cf                   	iret   
	...

f010081c <vcprintf>:
#include <inc/stdio.h>


int
vcprintf(const char *fmt, va_list ap)
{
f010081c:	83 ec 1c             	sub    $0x1c,%esp
	int cnt = 0;
f010081f:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
f0100826:	00 

	vprintfmt((void*)putch, &cnt, fmt, ap);
f0100827:	ff 74 24 24          	pushl  0x24(%esp)
f010082b:	ff 74 24 24          	pushl  0x24(%esp)
f010082f:	8d 44 24 14          	lea    0x14(%esp),%eax
f0100833:	50                   	push   %eax
f0100834:	68 09 04 10 f0       	push   $0xf0100409
f0100839:	e8 01 1d 00 00       	call   f010253f <vprintfmt>
	return cnt;
}
f010083e:	8b 44 24 1c          	mov    0x1c(%esp),%eax
f0100842:	83 c4 2c             	add    $0x2c,%esp
f0100845:	c3                   	ret    

f0100846 <cprintf>:

int
cprintf(const char *fmt, ...)
{
f0100846:	83 ec 0c             	sub    $0xc,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
f0100849:	8d 44 24 14          	lea    0x14(%esp),%eax
	cnt = vcprintf(fmt, ap);
f010084d:	52                   	push   %edx
f010084e:	52                   	push   %edx
f010084f:	50                   	push   %eax
f0100850:	ff 74 24 1c          	pushl  0x1c(%esp)
f0100854:	e8 c3 ff ff ff       	call   f010081c <vcprintf>
	va_end(ap);

	return cnt;
}
f0100859:	83 c4 1c             	add    $0x1c,%esp
f010085c:	c3                   	ret    
f010085d:	00 00                	add    %al,(%eax)
	...

f0100860 <page2pa>:
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0100860:	2b 05 4c 0e 11 f0    	sub    0xf0110e4c,%eax
f0100866:	c1 f8 03             	sar    $0x3,%eax
f0100869:	c1 e0 0c             	shl    $0xc,%eax
}
f010086c:	c3                   	ret    

f010086d <boot_alloc>:
	// Initialize nextfree if this is the first time.
	// 'end' is a magic symbol automatically generated by the linker,#end is behind on bss
	// which points to the end of the kernel's bss segment:
	// the first virtual address that the linker did *not* assign
	// to any kernel code or global variables.
	if (!nextfree) {
f010086d:	83 3d 24 02 11 f0 00 	cmpl   $0x0,0xf0110224
// This function may ONLY be used during initialization,
// before the page_free_list list has been set up.
// boot_alloc return the address which can be used
static void *
boot_alloc(uint32_t n)
{
f0100874:	89 c2                	mov    %eax,%edx
	// Initialize nextfree if this is the first time.
	// 'end' is a magic symbol automatically generated by the linker,#end is behind on bss
	// which points to the end of the kernel's bss segment:
	// the first virtual address that the linker did *not* assign
	// to any kernel code or global variables.
	if (!nextfree) {
f0100876:	75 11                	jne    f0100889 <boot_alloc+0x1c>
		extern char end[];
		nextfree = ROUNDUP((char *) end, PGSIZE);
f0100878:	b9 53 1e 11 f0       	mov    $0xf0111e53,%ecx
f010087d:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
f0100883:	89 0d 24 02 11 f0    	mov    %ecx,0xf0110224

	//!! Allocate a chunk large enough to hold 'n' bytes, then update
	//!! nextfree.  Make sure nextfree is kept aligned
	//!!! to a multiple of PGSIZE.
    //if n is zero return the address currently, else return the address can be div by page
    if (n == 0)
f0100889:	85 d2                	test   %edx,%edx
f010088b:	a1 24 02 11 f0       	mov    0xf0110224,%eax
f0100890:	74 15                	je     f01008a7 <boot_alloc+0x3a>
        return nextfree;
    else if (n > 0)
    {
        result = nextfree;
        nextfree += ROUNDUP(n, PGSIZE);//find the nearest address which is nearest to address is be div by pagesize
f0100892:	81 c2 ff 0f 00 00    	add    $0xfff,%edx
f0100898:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f010089e:	8d 14 10             	lea    (%eax,%edx,1),%edx
f01008a1:	89 15 24 02 11 f0    	mov    %edx,0xf0110224
    }

	return result;
}
f01008a7:	c3                   	ret    

f01008a8 <_kaddr>:
 * virtual address.  It panics if you pass an invalid physical address. */
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
f01008a8:	53                   	push   %ebx
	if (PGNUM(pa) >= npages)
f01008a9:	89 cb                	mov    %ecx,%ebx
 * virtual address.  It panics if you pass an invalid physical address. */
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
f01008ab:	83 ec 08             	sub    $0x8,%esp
	if (PGNUM(pa) >= npages)
f01008ae:	c1 eb 0c             	shr    $0xc,%ebx
f01008b1:	3b 1d 44 0e 11 f0    	cmp    0xf0110e44,%ebx
f01008b7:	72 0d                	jb     f01008c6 <_kaddr+0x1e>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01008b9:	51                   	push   %ecx
f01008ba:	68 e4 36 10 f0       	push   $0xf01036e4
f01008bf:	52                   	push   %edx
f01008c0:	50                   	push   %eax
f01008c1:	e8 da 17 00 00       	call   f01020a0 <_panic>
	return (void *)(pa + KERNBASE);
f01008c6:	8d 81 00 00 00 f0    	lea    -0x10000000(%ecx),%eax
}
f01008cc:	83 c4 08             	add    $0x8,%esp
f01008cf:	5b                   	pop    %ebx
f01008d0:	c3                   	ret    

f01008d1 <page2kva>:
	return &pages[PGNUM(pa)];
}

static inline void*
page2kva(struct PageInfo *pp)
{
f01008d1:	83 ec 0c             	sub    $0xc,%esp
	return KADDR(page2pa(pp));
f01008d4:	e8 87 ff ff ff       	call   f0100860 <page2pa>
f01008d9:	ba 4d 00 00 00       	mov    $0x4d,%edx
}
f01008de:	83 c4 0c             	add    $0xc,%esp
}

static inline void*
page2kva(struct PageInfo *pp)
{
	return KADDR(page2pa(pp));
f01008e1:	89 c1                	mov    %eax,%ecx
f01008e3:	b8 07 37 10 f0       	mov    $0xf0103707,%eax
f01008e8:	eb be                	jmp    f01008a8 <_kaddr>

f01008ea <check_va2pa>:
// this functionality for us!  We define our own version to help check
// the check_kern_pgdir() function; it shouldn't be used elsewhere.

static physaddr_t
check_va2pa(pde_t *pgdir, uintptr_t va)
{
f01008ea:	56                   	push   %esi
f01008eb:	89 d6                	mov    %edx,%esi
f01008ed:	53                   	push   %ebx
	pte_t *p;

	pgdir = &pgdir[PDX(va)];
	if (!(*pgdir & PTE_P))
		return ~0;
f01008ee:	83 cb ff             	or     $0xffffffff,%ebx
static physaddr_t
check_va2pa(pde_t *pgdir, uintptr_t va)
{
	pte_t *p;

	pgdir = &pgdir[PDX(va)];
f01008f1:	c1 ea 16             	shr    $0x16,%edx
// this functionality for us!  We define our own version to help check
// the check_kern_pgdir() function; it shouldn't be used elsewhere.

static physaddr_t
check_va2pa(pde_t *pgdir, uintptr_t va)
{
f01008f4:	83 ec 04             	sub    $0x4,%esp
	pte_t *p;

	pgdir = &pgdir[PDX(va)];
	if (!(*pgdir & PTE_P))
f01008f7:	8b 0c 90             	mov    (%eax,%edx,4),%ecx
f01008fa:	f6 c1 01             	test   $0x1,%cl
f01008fd:	74 2e                	je     f010092d <check_va2pa+0x43>
		return ~0;
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
f01008ff:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
f0100905:	ba ee 02 00 00       	mov    $0x2ee,%edx
f010090a:	b8 16 37 10 f0       	mov    $0xf0103716,%eax
f010090f:	e8 94 ff ff ff       	call   f01008a8 <_kaddr>
	if (!(p[PTX(va)] & PTE_P))
f0100914:	c1 ee 0c             	shr    $0xc,%esi
f0100917:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
f010091d:	8b 04 b0             	mov    (%eax,%esi,4),%eax
		return ~0;
	return PTE_ADDR(p[PTX(va)]);
f0100920:	89 c2                	mov    %eax,%edx
f0100922:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0100928:	a8 01                	test   $0x1,%al
f010092a:	0f 45 da             	cmovne %edx,%ebx
}
f010092d:	89 d8                	mov    %ebx,%eax
f010092f:	83 c4 04             	add    $0x4,%esp
f0100932:	5b                   	pop    %ebx
f0100933:	5e                   	pop    %esi
f0100934:	c3                   	ret    

f0100935 <check_page_free_list>:
//
// Check that the pages on the page_free_list are reasonable.
//
static void
check_page_free_list(bool only_low_memory)
{
f0100935:	55                   	push   %ebp
f0100936:	57                   	push   %edi
f0100937:	56                   	push   %esi
f0100938:	53                   	push   %ebx
f0100939:	83 ec 1c             	sub    $0x1c,%esp
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
	int nfree_basemem = 0, nfree_extmem = 0;
	char *first_free_page;

	if (!page_free_list)
f010093c:	8b 1d 1c 02 11 f0    	mov    0xf011021c,%ebx
//
static void
check_page_free_list(bool only_low_memory)
{
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100942:	3c 01                	cmp    $0x1,%al
f0100944:	19 f6                	sbb    %esi,%esi
f0100946:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
f010094c:	46                   	inc    %esi
	int nfree_basemem = 0, nfree_extmem = 0;
	char *first_free_page;

	if (!page_free_list)
f010094d:	85 db                	test   %ebx,%ebx
f010094f:	75 10                	jne    f0100961 <check_page_free_list+0x2c>
		panic("'page_free_list' is a null pointer!");
f0100951:	51                   	push   %ecx
f0100952:	68 23 37 10 f0       	push   $0xf0103723
f0100957:	68 2c 02 00 00       	push   $0x22c
f010095c:	e9 b6 00 00 00       	jmp    f0100a17 <check_page_free_list+0xe2>

	if (only_low_memory) {
f0100961:	84 c0                	test   %al,%al
f0100963:	74 4b                	je     f01009b0 <check_page_free_list+0x7b>
		// Move pages with lower addresses first in the free
		// list, since entry_pgdir does not map all pages.
		struct PageInfo *pp1, *pp2;
		struct PageInfo **tp[2] = { &pp1, &pp2 };
f0100965:	8d 44 24 0c          	lea    0xc(%esp),%eax
f0100969:	89 04 24             	mov    %eax,(%esp)
f010096c:	8d 44 24 08          	lea    0x8(%esp),%eax
f0100970:	89 44 24 04          	mov    %eax,0x4(%esp)
		for (pp = page_free_list; pp; pp = pp->pp_link) {
			int pagetype = PDX(page2pa(pp)) >= pdx_limit;
f0100974:	89 d8                	mov    %ebx,%eax
f0100976:	e8 e5 fe ff ff       	call   f0100860 <page2pa>
f010097b:	c1 e8 16             	shr    $0x16,%eax
f010097e:	39 f0                	cmp    %esi,%eax
f0100980:	0f 93 c0             	setae  %al
f0100983:	0f b6 c0             	movzbl %al,%eax
			*tp[pagetype] = pp;
f0100986:	8b 14 84             	mov    (%esp,%eax,4),%edx
f0100989:	89 1a                	mov    %ebx,(%edx)
			tp[pagetype] = &pp->pp_link;
f010098b:	89 1c 84             	mov    %ebx,(%esp,%eax,4)
	if (only_low_memory) {
		// Move pages with lower addresses first in the free
		// list, since entry_pgdir does not map all pages.
		struct PageInfo *pp1, *pp2;
		struct PageInfo **tp[2] = { &pp1, &pp2 };
		for (pp = page_free_list; pp; pp = pp->pp_link) {
f010098e:	8b 1b                	mov    (%ebx),%ebx
f0100990:	85 db                	test   %ebx,%ebx
f0100992:	75 e0                	jne    f0100974 <check_page_free_list+0x3f>
			int pagetype = PDX(page2pa(pp)) >= pdx_limit;
			*tp[pagetype] = pp;
			tp[pagetype] = &pp->pp_link;
		}
		*tp[1] = 0;
f0100994:	8b 44 24 04          	mov    0x4(%esp),%eax
f0100998:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		*tp[0] = pp2;
f010099e:	8b 04 24             	mov    (%esp),%eax
f01009a1:	8b 54 24 08          	mov    0x8(%esp),%edx
f01009a5:	89 10                	mov    %edx,(%eax)
		page_free_list = pp1;
f01009a7:	8b 44 24 0c          	mov    0xc(%esp),%eax
f01009ab:	a3 1c 02 11 f0       	mov    %eax,0xf011021c
	}

	// if there's a page that shouldn't be on the free list,
	// try to make sure it eventually causes trouble.
	for (pp = page_free_list; pp; pp = pp->pp_link)
f01009b0:	8b 1d 1c 02 11 f0    	mov    0xf011021c,%ebx
f01009b6:	eb 2b                	jmp    f01009e3 <check_page_free_list+0xae>
		if (PDX(page2pa(pp)) < pdx_limit)
f01009b8:	89 d8                	mov    %ebx,%eax
f01009ba:	e8 a1 fe ff ff       	call   f0100860 <page2pa>
f01009bf:	c1 e8 16             	shr    $0x16,%eax
f01009c2:	39 f0                	cmp    %esi,%eax
f01009c4:	73 1b                	jae    f01009e1 <check_page_free_list+0xac>
			memset(page2kva(pp), 0x97, 128);
f01009c6:	89 d8                	mov    %ebx,%eax
f01009c8:	e8 04 ff ff ff       	call   f01008d1 <page2kva>
f01009cd:	52                   	push   %edx
f01009ce:	68 80 00 00 00       	push   $0x80
f01009d3:	68 97 00 00 00       	push   $0x97
f01009d8:	50                   	push   %eax
f01009d9:	e8 d1 22 00 00       	call   f0102caf <memset>
f01009de:	83 c4 10             	add    $0x10,%esp
		page_free_list = pp1;
	}

	// if there's a page that shouldn't be on the free list,
	// try to make sure it eventually causes trouble.
	for (pp = page_free_list; pp; pp = pp->pp_link)
f01009e1:	8b 1b                	mov    (%ebx),%ebx
f01009e3:	85 db                	test   %ebx,%ebx
f01009e5:	75 d1                	jne    f01009b8 <check_page_free_list+0x83>
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
f01009e7:	31 c0                	xor    %eax,%eax
static void
check_page_free_list(bool only_low_memory)
{
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
	int nfree_basemem = 0, nfree_extmem = 0;
f01009e9:	31 f6                	xor    %esi,%esi
	// try to make sure it eventually causes trouble.
	for (pp = page_free_list; pp; pp = pp->pp_link)
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
f01009eb:	e8 7d fe ff ff       	call   f010086d <boot_alloc>
static void
check_page_free_list(bool only_low_memory)
{
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
	int nfree_basemem = 0, nfree_extmem = 0;
f01009f0:	31 ff                	xor    %edi,%edi
	for (pp = page_free_list; pp; pp = pp->pp_link)
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f01009f2:	8b 1d 1c 02 11 f0    	mov    0xf011021c,%ebx
	// try to make sure it eventually causes trouble.
	for (pp = page_free_list; pp; pp = pp->pp_link)
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
f01009f8:	89 c5                	mov    %eax,%ebp
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f01009fa:	e9 ff 00 00 00       	jmp    f0100afe <check_page_free_list+0x1c9>
		// check that we didn't corrupt the free list itself
		assert(pp >= pages);
f01009ff:	a1 4c 0e 11 f0       	mov    0xf0110e4c,%eax
f0100a04:	39 c3                	cmp    %eax,%ebx
f0100a06:	73 19                	jae    f0100a21 <check_page_free_list+0xec>
f0100a08:	68 47 37 10 f0       	push   $0xf0103747
f0100a0d:	68 53 37 10 f0       	push   $0xf0103753
f0100a12:	68 46 02 00 00       	push   $0x246
f0100a17:	68 16 37 10 f0       	push   $0xf0103716
f0100a1c:	e8 7f 16 00 00       	call   f01020a0 <_panic>
		assert(pp < pages + npages);
f0100a21:	8b 15 44 0e 11 f0    	mov    0xf0110e44,%edx
f0100a27:	8d 14 d0             	lea    (%eax,%edx,8),%edx
f0100a2a:	39 d3                	cmp    %edx,%ebx
f0100a2c:	72 11                	jb     f0100a3f <check_page_free_list+0x10a>
f0100a2e:	68 68 37 10 f0       	push   $0xf0103768
f0100a33:	68 53 37 10 f0       	push   $0xf0103753
f0100a38:	68 47 02 00 00       	push   $0x247
f0100a3d:	eb d8                	jmp    f0100a17 <check_page_free_list+0xe2>
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0100a3f:	89 da                	mov    %ebx,%edx
f0100a41:	29 c2                	sub    %eax,%edx
f0100a43:	89 d0                	mov    %edx,%eax
f0100a45:	a8 07                	test   $0x7,%al
f0100a47:	74 11                	je     f0100a5a <check_page_free_list+0x125>
f0100a49:	68 7c 37 10 f0       	push   $0xf010377c
f0100a4e:	68 53 37 10 f0       	push   $0xf0103753
f0100a53:	68 48 02 00 00       	push   $0x248
f0100a58:	eb bd                	jmp    f0100a17 <check_page_free_list+0xe2>

		// check a few pages that shouldn't be on the free list
		assert(page2pa(pp) != 0);
f0100a5a:	89 d8                	mov    %ebx,%eax
f0100a5c:	e8 ff fd ff ff       	call   f0100860 <page2pa>
f0100a61:	85 c0                	test   %eax,%eax
f0100a63:	75 11                	jne    f0100a76 <check_page_free_list+0x141>
f0100a65:	68 ae 37 10 f0       	push   $0xf01037ae
f0100a6a:	68 53 37 10 f0       	push   $0xf0103753
f0100a6f:	68 4b 02 00 00       	push   $0x24b
f0100a74:	eb a1                	jmp    f0100a17 <check_page_free_list+0xe2>
		assert(page2pa(pp) != IOPHYSMEM);
f0100a76:	3d 00 00 0a 00       	cmp    $0xa0000,%eax
f0100a7b:	75 11                	jne    f0100a8e <check_page_free_list+0x159>
f0100a7d:	68 bf 37 10 f0       	push   $0xf01037bf
f0100a82:	68 53 37 10 f0       	push   $0xf0103753
f0100a87:	68 4c 02 00 00       	push   $0x24c
f0100a8c:	eb 89                	jmp    f0100a17 <check_page_free_list+0xe2>
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
f0100a8e:	3d 00 f0 0f 00       	cmp    $0xff000,%eax
f0100a93:	75 14                	jne    f0100aa9 <check_page_free_list+0x174>
f0100a95:	68 d8 37 10 f0       	push   $0xf01037d8
f0100a9a:	68 53 37 10 f0       	push   $0xf0103753
f0100a9f:	68 4d 02 00 00       	push   $0x24d
f0100aa4:	e9 6e ff ff ff       	jmp    f0100a17 <check_page_free_list+0xe2>
		assert(page2pa(pp) != EXTPHYSMEM);
f0100aa9:	3d 00 00 10 00       	cmp    $0x100000,%eax
f0100aae:	75 14                	jne    f0100ac4 <check_page_free_list+0x18f>
f0100ab0:	68 fb 37 10 f0       	push   $0xf01037fb
f0100ab5:	68 53 37 10 f0       	push   $0xf0103753
f0100aba:	68 4e 02 00 00       	push   $0x24e
f0100abf:	e9 53 ff ff ff       	jmp    f0100a17 <check_page_free_list+0xe2>
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
f0100ac4:	3d ff ff 0f 00       	cmp    $0xfffff,%eax
f0100ac9:	76 1f                	jbe    f0100aea <check_page_free_list+0x1b5>
f0100acb:	89 d8                	mov    %ebx,%eax
f0100acd:	e8 ff fd ff ff       	call   f01008d1 <page2kva>
f0100ad2:	39 e8                	cmp    %ebp,%eax
f0100ad4:	73 14                	jae    f0100aea <check_page_free_list+0x1b5>
f0100ad6:	68 15 38 10 f0       	push   $0xf0103815
f0100adb:	68 53 37 10 f0       	push   $0xf0103753
f0100ae0:	68 4f 02 00 00       	push   $0x24f
f0100ae5:	e9 2d ff ff ff       	jmp    f0100a17 <check_page_free_list+0xe2>

		if (page2pa(pp) < EXTPHYSMEM)
f0100aea:	89 d8                	mov    %ebx,%eax
f0100aec:	e8 6f fd ff ff       	call   f0100860 <page2pa>
f0100af1:	3d ff ff 0f 00       	cmp    $0xfffff,%eax
f0100af6:	77 03                	ja     f0100afb <check_page_free_list+0x1c6>
			++nfree_basemem;
f0100af8:	47                   	inc    %edi
f0100af9:	eb 01                	jmp    f0100afc <check_page_free_list+0x1c7>
		else
			++nfree_extmem;
f0100afb:	46                   	inc    %esi
	for (pp = page_free_list; pp; pp = pp->pp_link)
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100afc:	8b 1b                	mov    (%ebx),%ebx
f0100afe:	85 db                	test   %ebx,%ebx
f0100b00:	0f 85 f9 fe ff ff    	jne    f01009ff <check_page_free_list+0xca>
			++nfree_basemem;
		else
			++nfree_extmem;
	}

	assert(nfree_basemem > 0);
f0100b06:	85 ff                	test   %edi,%edi
f0100b08:	75 14                	jne    f0100b1e <check_page_free_list+0x1e9>
f0100b0a:	68 5a 38 10 f0       	push   $0xf010385a
f0100b0f:	68 53 37 10 f0       	push   $0xf0103753
f0100b14:	68 57 02 00 00       	push   $0x257
f0100b19:	e9 f9 fe ff ff       	jmp    f0100a17 <check_page_free_list+0xe2>
	assert(nfree_extmem > 0);
f0100b1e:	85 f6                	test   %esi,%esi
f0100b20:	75 14                	jne    f0100b36 <check_page_free_list+0x201>
f0100b22:	68 6c 38 10 f0       	push   $0xf010386c
f0100b27:	68 53 37 10 f0       	push   $0xf0103753
f0100b2c:	68 58 02 00 00       	push   $0x258
f0100b31:	e9 e1 fe ff ff       	jmp    f0100a17 <check_page_free_list+0xe2>
	cprintf("check_page_free_list() succeeded!\n");
f0100b36:	83 ec 0c             	sub    $0xc,%esp
f0100b39:	68 7d 38 10 f0       	push   $0xf010387d
f0100b3e:	e8 03 fd ff ff       	call   f0100846 <cprintf>
}
f0100b43:	83 c4 2c             	add    $0x2c,%esp
f0100b46:	5b                   	pop    %ebx
f0100b47:	5e                   	pop    %esi
f0100b48:	5f                   	pop    %edi
f0100b49:	5d                   	pop    %ebp
f0100b4a:	c3                   	ret    

f0100b4b <nvram_read>:
// Detect machine's physical memory setup.
// --------------------------------------------------------------

static int
nvram_read(int r)
{
f0100b4b:	56                   	push   %esi
f0100b4c:	53                   	push   %ebx
f0100b4d:	89 c3                	mov    %eax,%ebx
f0100b4f:	83 ec 10             	sub    $0x10,%esp
	return mc146818_read(r) | (mc146818_read(r + 1) << 8);
f0100b52:	43                   	inc    %ebx
f0100b53:	50                   	push   %eax
f0100b54:	e8 cb 15 00 00       	call   f0102124 <mc146818_read>
f0100b59:	89 1c 24             	mov    %ebx,(%esp)
f0100b5c:	89 c6                	mov    %eax,%esi
f0100b5e:	e8 c1 15 00 00       	call   f0102124 <mc146818_read>
}
f0100b63:	83 c4 14             	add    $0x14,%esp
f0100b66:	5b                   	pop    %ebx
// --------------------------------------------------------------

static int
nvram_read(int r)
{
	return mc146818_read(r) | (mc146818_read(r + 1) << 8);
f0100b67:	c1 e0 08             	shl    $0x8,%eax
f0100b6a:	09 f0                	or     %esi,%eax
}
f0100b6c:	5e                   	pop    %esi
f0100b6d:	c3                   	ret    

f0100b6e <_paddr.clone.0>:
 * non-kernel virtual address.
 */
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
f0100b6e:	83 ec 0c             	sub    $0xc,%esp
{
	if ((uint32_t)kva < KERNBASE)
f0100b71:	81 fa ff ff ff ef    	cmp    $0xefffffff,%edx
f0100b77:	77 11                	ja     f0100b8a <_paddr.clone.0+0x1c>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0100b79:	52                   	push   %edx
f0100b7a:	68 a0 38 10 f0       	push   $0xf01038a0
f0100b7f:	50                   	push   %eax
f0100b80:	68 16 37 10 f0       	push   $0xf0103716
f0100b85:	e8 16 15 00 00       	call   f01020a0 <_panic>
	return (physaddr_t)kva - KERNBASE;
f0100b8a:	8d 82 00 00 00 10    	lea    0x10000000(%edx),%eax
}
f0100b90:	83 c4 0c             	add    $0xc,%esp
f0100b93:	c3                   	ret    

f0100b94 <page_init>:
// allocator functions below to allocate and deallocate physical
// memory via the page_free_list.
//
void
page_init(void)
{
f0100b94:	56                   	push   %esi
	// NB: DO NOT actually touch the physical memory corresponding to
	// free pages!
	
    /* TODO */
    size_t i;
	for (i = 0; i < npages; i++) {
f0100b95:	31 f6                	xor    %esi,%esi
// allocator functions below to allocate and deallocate physical
// memory via the page_free_list.
//
void
page_init(void)
{
f0100b97:	53                   	push   %ebx
	// NB: DO NOT actually touch the physical memory corresponding to
	// free pages!
	
    /* TODO */
    size_t i;
	for (i = 0; i < npages; i++) {
f0100b98:	31 db                	xor    %ebx,%ebx
f0100b9a:	e9 82 00 00 00       	jmp    f0100c21 <page_init+0x8d>
        if(i ==0)
f0100b9f:	85 db                	test   %ebx,%ebx
f0100ba1:	75 11                	jne    f0100bb4 <page_init+0x20>
        {
            pages[i].pp_ref = 1; //from the hint tell us the 0 page is taken
f0100ba3:	a1 4c 0e 11 f0       	mov    0xf0110e4c,%eax
f0100ba8:	66 c7 40 04 01 00    	movw   $0x1,0x4(%eax)
            pages[i].pp_link=NULL;
f0100bae:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
        }
        if(i<npages_basemem)
f0100bb4:	3b 1d 20 02 11 f0    	cmp    0xf0110220,%ebx
f0100bba:	73 1a                	jae    f0100bd6 <page_init+0x42>
        {
            pages[i].pp_ref = 0;//free
f0100bbc:	a1 4c 0e 11 f0       	mov    0xf0110e4c,%eax
            pages[i].pp_link = page_free_list;
f0100bc1:	8b 15 1c 02 11 f0    	mov    0xf011021c,%edx
            pages[i].pp_ref = 1; //from the hint tell us the 0 page is taken
            pages[i].pp_link=NULL;
        }
        if(i<npages_basemem)
        {
            pages[i].pp_ref = 0;//free
f0100bc7:	01 f0                	add    %esi,%eax
f0100bc9:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)
            pages[i].pp_link = page_free_list;
f0100bcf:	89 10                	mov    %edx,(%eax)
            page_free_list = &pages[i];
f0100bd1:	a3 1c 02 11 f0       	mov    %eax,0xf011021c
        }
        //(ext-io)/pg is number of io , the other is number of part of ext(kernel)
        if(i < ((EXTPHYSMEM-IOPHYSMEM)/PGSIZE) || i < ((uint32_t)boot_alloc(0)- KERNBASE)/PGSIZE)
f0100bd6:	83 fb 5f             	cmp    $0x5f,%ebx
f0100bd9:	76 13                	jbe    f0100bee <page_init+0x5a>
f0100bdb:	31 c0                	xor    %eax,%eax
f0100bdd:	e8 8b fc ff ff       	call   f010086d <boot_alloc>
f0100be2:	05 00 00 00 10       	add    $0x10000000,%eax
f0100be7:	c1 e8 0c             	shr    $0xc,%eax
f0100bea:	39 c3                	cmp    %eax,%ebx
f0100bec:	73 15                	jae    f0100c03 <page_init+0x6f>
        {
            pages[i].pp_ref = 1; //from the hint tell us the 0 page is taken
f0100bee:	a1 4c 0e 11 f0       	mov    0xf0110e4c,%eax
f0100bf3:	01 f0                	add    %esi,%eax
f0100bf5:	66 c7 40 04 01 00    	movw   $0x1,0x4(%eax)
            pages[i].pp_link=NULL;
f0100bfb:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
f0100c01:	eb 1a                	jmp    f0100c1d <page_init+0x89>
        }
        else
        {
            pages[i].pp_ref = 0;
f0100c03:	a1 4c 0e 11 f0       	mov    0xf0110e4c,%eax
            pages[i].pp_link = page_free_list;
f0100c08:	8b 15 1c 02 11 f0    	mov    0xf011021c,%edx
            pages[i].pp_ref = 1; //from the hint tell us the 0 page is taken
            pages[i].pp_link=NULL;
        }
        else
        {
            pages[i].pp_ref = 0;
f0100c0e:	01 f0                	add    %esi,%eax
f0100c10:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)
            pages[i].pp_link = page_free_list;
f0100c16:	89 10                	mov    %edx,(%eax)
            page_free_list = &pages[i];
f0100c18:	a3 1c 02 11 f0       	mov    %eax,0xf011021c
	// NB: DO NOT actually touch the physical memory corresponding to
	// free pages!
	
    /* TODO */
    size_t i;
	for (i = 0; i < npages; i++) {
f0100c1d:	43                   	inc    %ebx
f0100c1e:	83 c6 08             	add    $0x8,%esi
f0100c21:	3b 1d 44 0e 11 f0    	cmp    0xf0110e44,%ebx
f0100c27:	0f 82 72 ff ff ff    	jb     f0100b9f <page_init+0xb>
            pages[i].pp_ref = 0;
            pages[i].pp_link = page_free_list;
            page_free_list = &pages[i];
        }
    }
}
f0100c2d:	5b                   	pop    %ebx
f0100c2e:	5e                   	pop    %esi
f0100c2f:	c3                   	ret    

f0100c30 <page_alloc>:
// Returns NULL if out of free memory.
//
// Hint: use page2kva and memset
struct PageInfo *
page_alloc(int alloc_flags)
{
f0100c30:	53                   	push   %ebx
f0100c31:	83 ec 08             	sub    $0x8,%esp
    /* TODO */
    if(!page_free_list)
f0100c34:	8b 1d 1c 02 11 f0    	mov    0xf011021c,%ebx
f0100c3a:	85 db                	test   %ebx,%ebx
f0100c3c:	74 2c                	je     f0100c6a <page_alloc+0x3a>
        return NULL;
    struct PageInfo *newpage;
    newpage = page_free_list;
    page_free_list = newpage->pp_link;
f0100c3e:	8b 03                	mov    (%ebx),%eax
    newpage->pp_link = NULL;
    //get the page and let the link to next page


    if(alloc_flags & ALLOC_ZERO)
f0100c40:	f6 44 24 10 01       	testb  $0x1,0x10(%esp)
    if(!page_free_list)
        return NULL;
    struct PageInfo *newpage;
    newpage = page_free_list;
    page_free_list = newpage->pp_link;
    newpage->pp_link = NULL;
f0100c45:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
    /* TODO */
    if(!page_free_list)
        return NULL;
    struct PageInfo *newpage;
    newpage = page_free_list;
    page_free_list = newpage->pp_link;
f0100c4b:	a3 1c 02 11 f0       	mov    %eax,0xf011021c
    newpage->pp_link = NULL;
    //get the page and let the link to next page


    if(alloc_flags & ALLOC_ZERO)
f0100c50:	74 18                	je     f0100c6a <page_alloc+0x3a>
         memset(page2kva(newpage),'\0',PGSIZE);
f0100c52:	89 d8                	mov    %ebx,%eax
f0100c54:	e8 78 fc ff ff       	call   f01008d1 <page2kva>
f0100c59:	52                   	push   %edx
f0100c5a:	68 00 10 00 00       	push   $0x1000
f0100c5f:	6a 00                	push   $0x0
f0100c61:	50                   	push   %eax
f0100c62:	e8 48 20 00 00       	call   f0102caf <memset>
f0100c67:	83 c4 10             	add    $0x10,%esp
         return newpage;
}
f0100c6a:	89 d8                	mov    %ebx,%eax
f0100c6c:	83 c4 08             	add    $0x8,%esp
f0100c6f:	5b                   	pop    %ebx
f0100c70:	c3                   	ret    

f0100c71 <page_free>:
// Return a page to the free list.
// (This function should only be called when pp->pp_ref reaches 0.)
//
void
page_free(struct PageInfo *pp)
{
f0100c71:	83 ec 0c             	sub    $0xc,%esp
f0100c74:	8b 44 24 10          	mov    0x10(%esp),%eax
	// Fill this function in
	// Hint: You may want to panic if pp->pp_ref is nonzero or
	// pp->pp_link is not NULL.
    /* TODO */
    if(pp->pp_link != NULL || pp->pp_ref != 0)
f0100c78:	83 38 00             	cmpl   $0x0,(%eax)
f0100c7b:	75 07                	jne    f0100c84 <page_free+0x13>
f0100c7d:	66 83 78 04 00       	cmpw   $0x0,0x4(%eax)
f0100c82:	74 15                	je     f0100c99 <page_free+0x28>
    {
        panic("the page can't return free");
f0100c84:	51                   	push   %ecx
f0100c85:	68 c4 38 10 f0       	push   $0xf01038c4
f0100c8a:	68 50 01 00 00       	push   $0x150
f0100c8f:	68 16 37 10 f0       	push   $0xf0103716
f0100c94:	e8 07 14 00 00       	call   f01020a0 <_panic>
        return;
    }   
    pp->pp_link = page_free_list;
f0100c99:	8b 15 1c 02 11 f0    	mov    0xf011021c,%edx
    page_free_list = pp;
f0100c9f:	a3 1c 02 11 f0       	mov    %eax,0xf011021c
    if(pp->pp_link != NULL || pp->pp_ref != 0)
    {
        panic("the page can't return free");
        return;
    }   
    pp->pp_link = page_free_list;
f0100ca4:	89 10                	mov    %edx,(%eax)
    page_free_list = pp;
}
f0100ca6:	83 c4 0c             	add    $0xc,%esp
f0100ca9:	c3                   	ret    

f0100caa <page_decref>:
// Decrement the reference count on a page,
// freeing it if there are no more refs.
//
void
page_decref(struct PageInfo* pp)
{
f0100caa:	83 ec 0c             	sub    $0xc,%esp
f0100cad:	8b 44 24 10          	mov    0x10(%esp),%eax
	if (--pp->pp_ref == 0)
f0100cb1:	8b 50 04             	mov    0x4(%eax),%edx
f0100cb4:	4a                   	dec    %edx
f0100cb5:	66 85 d2             	test   %dx,%dx
f0100cb8:	66 89 50 04          	mov    %dx,0x4(%eax)
f0100cbc:	75 08                	jne    f0100cc6 <page_decref+0x1c>
		page_free(pp);
}
f0100cbe:	83 c4 0c             	add    $0xc,%esp
//
void
page_decref(struct PageInfo* pp)
{
	if (--pp->pp_ref == 0)
		page_free(pp);
f0100cc1:	e9 ab ff ff ff       	jmp    f0100c71 <page_free>
}
f0100cc6:	83 c4 0c             	add    $0xc,%esp
f0100cc9:	c3                   	ret    

f0100cca <pgdir_walk>:
//
//check a va which have pte?if has ,return it
//if no we create
pte_t *
pgdir_walk(pde_t *pgdir, const void *va, int create)
{
f0100cca:	57                   	push   %edi
f0100ccb:	56                   	push   %esi
f0100ccc:	53                   	push   %ebx
f0100ccd:	8b 5c 24 14          	mov    0x14(%esp),%ebx
	// Fill this function in
    /* TODO */
    int pagedir_index = PDX(va);
f0100cd1:	89 de                	mov    %ebx,%esi
f0100cd3:	c1 ee 16             	shr    $0x16,%esi
    int pagetable_index = PTX(va);
    //chech the page table entry which is in memory?

    if(!(pgdir[pagedir_index] & PTE_P)){//check the page table(the offset if padir) that can present(inc/mmu.h)
f0100cd6:	c1 e6 02             	shl    $0x2,%esi
f0100cd9:	03 74 24 10          	add    0x10(%esp),%esi
f0100cdd:	8b 3e                	mov    (%esi),%edi
f0100cdf:	83 e7 01             	and    $0x1,%edi
f0100ce2:	75 2a                	jne    f0100d0e <pgdir_walk+0x44>
                return NULL;//return false
            page->pp_ref++;
            pgdir[pagedir_index] =( page2pa(page) | PTE_P | PTE_U | PTE_W); //present read/write user/kernel can use , all OR with page2pa
        }
        else 
            return NULL;
f0100ce4:	31 d2                	xor    %edx,%edx
    int pagedir_index = PDX(va);
    int pagetable_index = PTX(va);
    //chech the page table entry which is in memory?

    if(!(pgdir[pagedir_index] & PTE_P)){//check the page table(the offset if padir) that can present(inc/mmu.h)
        if(create){
f0100ce6:	83 7c 24 18 00       	cmpl   $0x0,0x18(%esp)
f0100ceb:	74 44                	je     f0100d31 <pgdir_walk+0x67>
            struct PageInfo *page = page_alloc(ALLOC_ZERO);//a zero page
f0100ced:	83 ec 0c             	sub    $0xc,%esp
f0100cf0:	6a 01                	push   $0x1
f0100cf2:	e8 39 ff ff ff       	call   f0100c30 <page_alloc>
            if(!page)
f0100cf7:	83 c4 10             	add    $0x10,%esp
                return NULL;//return false
f0100cfa:	89 fa                	mov    %edi,%edx
    //chech the page table entry which is in memory?

    if(!(pgdir[pagedir_index] & PTE_P)){//check the page table(the offset if padir) that can present(inc/mmu.h)
        if(create){
            struct PageInfo *page = page_alloc(ALLOC_ZERO);//a zero page
            if(!page)
f0100cfc:	85 c0                	test   %eax,%eax
f0100cfe:	74 31                	je     f0100d31 <pgdir_walk+0x67>
                return NULL;//return false
            page->pp_ref++;
f0100d00:	66 ff 40 04          	incw   0x4(%eax)
            pgdir[pagedir_index] =( page2pa(page) | PTE_P | PTE_U | PTE_W); //present read/write user/kernel can use , all OR with page2pa
f0100d04:	e8 57 fb ff ff       	call   f0100860 <page2pa>
f0100d09:	83 c8 07             	or     $0x7,%eax
f0100d0c:	89 06                	mov    %eax,(%esi)
        }
        else 
            return NULL;
    }
    pte_t *result;
    result = KADDR(PTE_ADDR(pgdir[pagedir_index]));//PTE_ADDR , the address of page table or dir,inc/mmu.h,KADDR is phy addr to kernel viruial addr , kernel/mem.h
f0100d0e:	8b 0e                	mov    (%esi),%ecx
f0100d10:	ba 91 01 00 00       	mov    $0x191,%edx
f0100d15:	b8 16 37 10 f0       	mov    $0xf0103716,%eax
pgdir_walk(pde_t *pgdir, const void *va, int create)
{
	// Fill this function in
    /* TODO */
    int pagedir_index = PDX(va);
    int pagetable_index = PTX(va);
f0100d1a:	c1 eb 0a             	shr    $0xa,%ebx
        else 
            return NULL;
    }
    pte_t *result;
    result = KADDR(PTE_ADDR(pgdir[pagedir_index]));//PTE_ADDR , the address of page table or dir,inc/mmu.h,KADDR is phy addr to kernel viruial addr , kernel/mem.h
    return &result[pagetable_index];
f0100d1d:	81 e3 fc 0f 00 00    	and    $0xffc,%ebx
        }
        else 
            return NULL;
    }
    pte_t *result;
    result = KADDR(PTE_ADDR(pgdir[pagedir_index]));//PTE_ADDR , the address of page table or dir,inc/mmu.h,KADDR is phy addr to kernel viruial addr , kernel/mem.h
f0100d23:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
f0100d29:	e8 7a fb ff ff       	call   f01008a8 <_kaddr>
    return &result[pagetable_index];
f0100d2e:	8d 14 18             	lea    (%eax,%ebx,1),%edx
}
f0100d31:	89 d0                	mov    %edx,%eax
f0100d33:	5b                   	pop    %ebx
f0100d34:	5e                   	pop    %esi
f0100d35:	5f                   	pop    %edi
f0100d36:	c3                   	ret    

f0100d37 <boot_map_region>:
// mapped pages.
//
// Hint: the TA solution uses pgdir_walk
static void
boot_map_region(pde_t *pgdir, uintptr_t va, size_t size, physaddr_t pa, int perm)//perm means permission
{
f0100d37:	55                   	push   %ebp
f0100d38:	89 cd                	mov    %ecx,%ebp
f0100d3a:	57                   	push   %edi
    /* TODO */
    pte_t *pte;
    int i;
    for (i = 0; i < size/PGSIZE; i++)
f0100d3b:	31 ff                	xor    %edi,%edi
// mapped pages.
//
// Hint: the TA solution uses pgdir_walk
static void
boot_map_region(pde_t *pgdir, uintptr_t va, size_t size, physaddr_t pa, int perm)//perm means permission
{
f0100d3d:	56                   	push   %esi
f0100d3e:	89 d6                	mov    %edx,%esi
f0100d40:	53                   	push   %ebx
f0100d41:	89 c3                	mov    %eax,%ebx
f0100d43:	83 ec 0c             	sub    $0xc,%esp
    /* TODO */
    pte_t *pte;
    int i;
    for (i = 0; i < size/PGSIZE; i++)
f0100d46:	c1 ed 0c             	shr    $0xc,%ebp
    {
        pte = pgdir_walk(pgdir,(void*)va,1);//1 mean create 
        *pte = (pa | perm | PTE_P);
f0100d49:	83 4c 24 24 01       	orl    $0x1,0x24(%esp)
boot_map_region(pde_t *pgdir, uintptr_t va, size_t size, physaddr_t pa, int perm)//perm means permission
{
    /* TODO */
    pte_t *pte;
    int i;
    for (i = 0; i < size/PGSIZE; i++)
f0100d4e:	eb 26                	jmp    f0100d76 <boot_map_region+0x3f>
    {
        pte = pgdir_walk(pgdir,(void*)va,1);//1 mean create 
f0100d50:	50                   	push   %eax
boot_map_region(pde_t *pgdir, uintptr_t va, size_t size, physaddr_t pa, int perm)//perm means permission
{
    /* TODO */
    pte_t *pte;
    int i;
    for (i = 0; i < size/PGSIZE; i++)
f0100d51:	47                   	inc    %edi
    {
        pte = pgdir_walk(pgdir,(void*)va,1);//1 mean create 
f0100d52:	6a 01                	push   $0x1
f0100d54:	56                   	push   %esi
        *pte = (pa | perm | PTE_P);
        pa += PGSIZE;
        va += PGSIZE;
f0100d55:	81 c6 00 10 00 00    	add    $0x1000,%esi
    /* TODO */
    pte_t *pte;
    int i;
    for (i = 0; i < size/PGSIZE; i++)
    {
        pte = pgdir_walk(pgdir,(void*)va,1);//1 mean create 
f0100d5b:	53                   	push   %ebx
f0100d5c:	e8 69 ff ff ff       	call   f0100cca <pgdir_walk>
        *pte = (pa | perm | PTE_P);
f0100d61:	8b 54 24 34          	mov    0x34(%esp),%edx
f0100d65:	0b 54 24 30          	or     0x30(%esp),%edx
f0100d69:	89 10                	mov    %edx,(%eax)
        pa += PGSIZE;
f0100d6b:	81 44 24 30 00 10 00 	addl   $0x1000,0x30(%esp)
f0100d72:	00 
boot_map_region(pde_t *pgdir, uintptr_t va, size_t size, physaddr_t pa, int perm)//perm means permission
{
    /* TODO */
    pte_t *pte;
    int i;
    for (i = 0; i < size/PGSIZE; i++)
f0100d73:	83 c4 10             	add    $0x10,%esp
f0100d76:	39 ef                	cmp    %ebp,%edi
f0100d78:	72 d6                	jb     f0100d50 <boot_map_region+0x19>
        *pte = (pa | perm | PTE_P);
        pa += PGSIZE;
        va += PGSIZE;
    }
    
}
f0100d7a:	83 c4 0c             	add    $0xc,%esp
f0100d7d:	5b                   	pop    %ebx
f0100d7e:	5e                   	pop    %esi
f0100d7f:	5f                   	pop    %edi
f0100d80:	5d                   	pop    %ebp
f0100d81:	c3                   	ret    

f0100d82 <page_lookup>:
//
// Hint: the TA solution uses pgdir_walk and pa2page.
//
struct PageInfo *
page_lookup(pde_t *pgdir, void *va, pte_t **pte_store)
{
f0100d82:	53                   	push   %ebx
f0100d83:	83 ec 0c             	sub    $0xc,%esp
f0100d86:	8b 5c 24 1c          	mov    0x1c(%esp),%ebx
    /* TODO */
    pte_t *pte=pgdir_walk(pgdir,(void *)va,0);
f0100d8a:	6a 00                	push   $0x0
f0100d8c:	ff 74 24 1c          	pushl  0x1c(%esp)
f0100d90:	ff 74 24 1c          	pushl  0x1c(%esp)
f0100d94:	e8 31 ff ff ff       	call   f0100cca <pgdir_walk>
    if(pte==NULL)
f0100d99:	83 c4 10             	add    $0x10,%esp
//
struct PageInfo *
page_lookup(pde_t *pgdir, void *va, pte_t **pte_store)
{
    /* TODO */
    pte_t *pte=pgdir_walk(pgdir,(void *)va,0);
f0100d9c:	89 c2                	mov    %eax,%edx
    if(pte==NULL)
        return NULL;
f0100d9e:	31 c0                	xor    %eax,%eax
struct PageInfo *
page_lookup(pde_t *pgdir, void *va, pte_t **pte_store)
{
    /* TODO */
    pte_t *pte=pgdir_walk(pgdir,(void *)va,0);
    if(pte==NULL)
f0100da0:	85 d2                	test   %edx,%edx
f0100da2:	74 35                	je     f0100dd9 <page_lookup+0x57>
        return NULL;
    if(!(*pte & PTE_P))
f0100da4:	8b 0a                	mov    (%edx),%ecx
f0100da6:	f6 c1 01             	test   $0x1,%cl
f0100da9:	74 2e                	je     f0100dd9 <page_lookup+0x57>
        return NULL;
    if(pte_store)
f0100dab:	85 db                	test   %ebx,%ebx
f0100dad:	74 02                	je     f0100db1 <page_lookup+0x2f>
        *pte_store = pte;//if pte_store is not zero ,then put the pde to the pte_store
f0100daf:	89 13                	mov    %edx,(%ebx)
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100db1:	89 c8                	mov    %ecx,%eax
f0100db3:	c1 e8 0c             	shr    $0xc,%eax
f0100db6:	3b 05 44 0e 11 f0    	cmp    0xf0110e44,%eax
f0100dbc:	72 12                	jb     f0100dd0 <page_lookup+0x4e>
		panic("pa2page called with invalid pa");
f0100dbe:	52                   	push   %edx
f0100dbf:	68 df 38 10 f0       	push   $0xf01038df
f0100dc4:	6a 46                	push   $0x46
f0100dc6:	68 07 37 10 f0       	push   $0xf0103707
f0100dcb:	e8 d0 12 00 00       	call   f01020a0 <_panic>
	return &pages[PGNUM(pa)];
f0100dd0:	c1 e0 03             	shl    $0x3,%eax
f0100dd3:	03 05 4c 0e 11 f0    	add    0xf0110e4c,%eax
    return pa2page(PTE_ADDR(*pte));
}
f0100dd9:	83 c4 08             	add    $0x8,%esp
f0100ddc:	5b                   	pop    %ebx
f0100ddd:	c3                   	ret    

f0100dde <page_remove>:
// Hint: The TA solution is implemented using page_lookup,
// 	tlb_invalidate, and page_decref.
//
void
page_remove(pde_t *pgdir, void *va)
{
f0100dde:	53                   	push   %ebx
f0100ddf:	83 ec 1c             	sub    $0x1c,%esp
f0100de2:	8b 5c 24 28          	mov    0x28(%esp),%ebx
    /* TODO */
    pte_t *pte;
    struct PageInfo *page = page_lookup(pgdir,(void *)va,&pte);
f0100de6:	8d 44 24 10          	lea    0x10(%esp),%eax
f0100dea:	50                   	push   %eax
f0100deb:	53                   	push   %ebx
f0100dec:	ff 74 24 2c          	pushl  0x2c(%esp)
f0100df0:	e8 8d ff ff ff       	call   f0100d82 <page_lookup>
    if(page == NULL)
f0100df5:	83 c4 10             	add    $0x10,%esp
f0100df8:	85 c0                	test   %eax,%eax
f0100dfa:	74 19                	je     f0100e15 <page_remove+0x37>
        return NULL;
    page_decref(page);
f0100dfc:	83 ec 0c             	sub    $0xc,%esp
f0100dff:	50                   	push   %eax
f0100e00:	e8 a5 fe ff ff       	call   f0100caa <page_decref>
    *pte = 0;//the page table entry set to 0
f0100e05:	8b 44 24 1c          	mov    0x1c(%esp),%eax
f0100e09:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
}

static __inline void
invlpg(void *addr)
{
	__asm __volatile("invlpg (%0)" : : "r" (addr) : "memory");
f0100e0f:	0f 01 3b             	invlpg (%ebx)
f0100e12:	83 c4 10             	add    $0x10,%esp
    tlb_invalidate(pgdir, va);
}
f0100e15:	83 c4 18             	add    $0x18,%esp
f0100e18:	5b                   	pop    %ebx
f0100e19:	c3                   	ret    

f0100e1a <page_insert>:
// Hint: The TA solution is implemented using pgdir_walk, page_remove,
// and page2pa.
//
int
page_insert(pde_t *pgdir, struct PageInfo *pp, void *va, int perm)
{
f0100e1a:	55                   	push   %ebp
f0100e1b:	57                   	push   %edi
f0100e1c:	56                   	push   %esi
f0100e1d:	53                   	push   %ebx
f0100e1e:	83 ec 10             	sub    $0x10,%esp
f0100e21:	8b 6c 24 2c          	mov    0x2c(%esp),%ebp
f0100e25:	8b 7c 24 24          	mov    0x24(%esp),%edi
f0100e29:	8b 74 24 28          	mov    0x28(%esp),%esi
    
    /* TODO */
    
    pte_t *pte = pgdir_walk(pgdir,(void *)va,1);
f0100e2d:	6a 01                	push   $0x1
f0100e2f:	55                   	push   %ebp
f0100e30:	57                   	push   %edi
f0100e31:	e8 94 fe ff ff       	call   f0100cca <pgdir_walk>
    if(pte==NULL)
f0100e36:	83 c4 10             	add    $0x10,%esp
page_insert(pde_t *pgdir, struct PageInfo *pp, void *va, int perm)
{
    
    /* TODO */
    
    pte_t *pte = pgdir_walk(pgdir,(void *)va,1);
f0100e39:	89 c3                	mov    %eax,%ebx
    if(pte==NULL)
        return -E_NO_MEM;
f0100e3b:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
{
    
    /* TODO */
    
    pte_t *pte = pgdir_walk(pgdir,(void *)va,1);
    if(pte==NULL)
f0100e40:	85 db                	test   %ebx,%ebx
f0100e42:	74 29                	je     f0100e6d <page_insert+0x53>
        return -E_NO_MEM;
    pp->pp_ref++;
f0100e44:	66 ff 46 04          	incw   0x4(%esi)
    if(*pte &PTE_P)
f0100e48:	f6 03 01             	testb  $0x1,(%ebx)
f0100e4b:	74 0c                	je     f0100e59 <page_insert+0x3f>
        page_remove(pgdir,va);
f0100e4d:	51                   	push   %ecx
f0100e4e:	51                   	push   %ecx
f0100e4f:	55                   	push   %ebp
f0100e50:	57                   	push   %edi
f0100e51:	e8 88 ff ff ff       	call   f0100dde <page_remove>
f0100e56:	83 c4 10             	add    $0x10,%esp
    *pte = page2pa(pp) | perm | PTE_P;
f0100e59:	89 f0                	mov    %esi,%eax
f0100e5b:	e8 00 fa ff ff       	call   f0100860 <page2pa>
f0100e60:	8b 54 24 2c          	mov    0x2c(%esp),%edx
f0100e64:	83 ca 01             	or     $0x1,%edx
f0100e67:	09 c2                	or     %eax,%edx
    return 0;
f0100e69:	31 c0                	xor    %eax,%eax
    if(pte==NULL)
        return -E_NO_MEM;
    pp->pp_ref++;
    if(*pte &PTE_P)
        page_remove(pgdir,va);
    *pte = page2pa(pp) | perm | PTE_P;
f0100e6b:	89 13                	mov    %edx,(%ebx)
    return 0;
    
}
f0100e6d:	83 c4 0c             	add    $0xc,%esp
f0100e70:	5b                   	pop    %ebx
f0100e71:	5e                   	pop    %esi
f0100e72:	5f                   	pop    %edi
f0100e73:	5d                   	pop    %ebp
f0100e74:	c3                   	ret    

f0100e75 <mem_init>:
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
{
f0100e75:	55                   	push   %ebp
{
	size_t npages_extmem;

	// Use CMOS calls to measure available base & extended memory.
	// (CMOS calls return results in kilobytes.)
	npages_basemem = (nvram_read(NVRAM_BASELO) * 1024) / PGSIZE;
f0100e76:	b8 15 00 00 00       	mov    $0x15,%eax
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
{
f0100e7b:	57                   	push   %edi
f0100e7c:	56                   	push   %esi
f0100e7d:	53                   	push   %ebx
{
	size_t npages_extmem;

	// Use CMOS calls to measure available base & extended memory.
	// (CMOS calls return results in kilobytes.)
	npages_basemem = (nvram_read(NVRAM_BASELO) * 1024) / PGSIZE;
f0100e7e:	bb 04 00 00 00       	mov    $0x4,%ebx
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
{
f0100e83:	83 ec 2c             	sub    $0x2c,%esp
	uint32_t cr0;
    nextfree = 0;
f0100e86:	c7 05 24 02 11 f0 00 	movl   $0x0,0xf0110224
f0100e8d:	00 00 00 
    page_free_list = 0;
f0100e90:	c7 05 1c 02 11 f0 00 	movl   $0x0,0xf011021c
f0100e97:	00 00 00 
{
	size_t npages_extmem;

	// Use CMOS calls to measure available base & extended memory.
	// (CMOS calls return results in kilobytes.)
	npages_basemem = (nvram_read(NVRAM_BASELO) * 1024) / PGSIZE;
f0100e9a:	e8 ac fc ff ff       	call   f0100b4b <nvram_read>
f0100e9f:	99                   	cltd   
f0100ea0:	f7 fb                	idiv   %ebx
f0100ea2:	a3 20 02 11 f0       	mov    %eax,0xf0110220
	npages_extmem = (nvram_read(NVRAM_EXTLO) * 1024) / PGSIZE;
f0100ea7:	b8 17 00 00 00       	mov    $0x17,%eax
f0100eac:	e8 9a fc ff ff       	call   f0100b4b <nvram_read>
f0100eb1:	99                   	cltd   
f0100eb2:	f7 fb                	idiv   %ebx

	// Calculate the number of physical pages available in both base
	// and extended memory.
	if (npages_extmem)
f0100eb4:	85 c0                	test   %eax,%eax
		npages = (EXTPHYSMEM / PGSIZE) + npages_extmem;
f0100eb6:	8d 90 00 01 00 00    	lea    0x100(%eax),%edx
	npages_basemem = (nvram_read(NVRAM_BASELO) * 1024) / PGSIZE;
	npages_extmem = (nvram_read(NVRAM_EXTLO) * 1024) / PGSIZE;

	// Calculate the number of physical pages available in both base
	// and extended memory.
	if (npages_extmem)
f0100ebc:	75 06                	jne    f0100ec4 <mem_init+0x4f>
		npages = (EXTPHYSMEM / PGSIZE) + npages_extmem;
	else
		npages = npages_basemem;
f0100ebe:	8b 15 20 02 11 f0    	mov    0xf0110220,%edx

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
		npages * PGSIZE / 1024,
		npages_basemem * PGSIZE / 1024,
		npages_extmem * PGSIZE / 1024);
f0100ec4:	c1 e0 0c             	shl    $0xc,%eax
	if (npages_extmem)
		npages = (EXTPHYSMEM / PGSIZE) + npages_extmem;
	else
		npages = npages_basemem;

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f0100ec7:	c1 e8 0a             	shr    $0xa,%eax
f0100eca:	50                   	push   %eax
		npages * PGSIZE / 1024,
		npages_basemem * PGSIZE / 1024,
f0100ecb:	a1 20 02 11 f0       	mov    0xf0110220,%eax
	// Calculate the number of physical pages available in both base
	// and extended memory.
	if (npages_extmem)
		npages = (EXTPHYSMEM / PGSIZE) + npages_extmem;
	else
		npages = npages_basemem;
f0100ed0:	89 15 44 0e 11 f0    	mov    %edx,0xf0110e44

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
		npages * PGSIZE / 1024,
		npages_basemem * PGSIZE / 1024,
f0100ed6:	c1 e0 0c             	shl    $0xc,%eax
	if (npages_extmem)
		npages = (EXTPHYSMEM / PGSIZE) + npages_extmem;
	else
		npages = npages_basemem;

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f0100ed9:	c1 e8 0a             	shr    $0xa,%eax
f0100edc:	50                   	push   %eax
		npages * PGSIZE / 1024,
f0100edd:	a1 44 0e 11 f0       	mov    0xf0110e44,%eax
f0100ee2:	c1 e0 0c             	shl    $0xc,%eax
	if (npages_extmem)
		npages = (EXTPHYSMEM / PGSIZE) + npages_extmem;
	else
		npages = npages_basemem;

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f0100ee5:	c1 e8 0a             	shr    $0xa,%eax
f0100ee8:	50                   	push   %eax
f0100ee9:	68 fe 38 10 f0       	push   $0xf01038fe
f0100eee:	e8 53 f9 ff ff       	call   f0100846 <cprintf>
	// Find out how much memory the machine has (npages & npages_basemem).
	i386_detect_memory();//get the number of membase page(can be used) ,io hole page(not) ,extmem page(ok)

	//////////////////////////////////////////////////////////////////////
	//!!! create initial page directory.
	kern_pgdir = (pde_t *) boot_alloc(PGSIZE);//in inc/mmu.h PGSIZE is 4096b = 4KB
f0100ef3:	b8 00 10 00 00       	mov    $0x1000,%eax
f0100ef8:	e8 70 f9 ff ff       	call   f010086d <boot_alloc>
	memset(kern_pgdir, 0, PGSIZE);//memset(start addr , content, size)
f0100efd:	83 c4 0c             	add    $0xc,%esp
f0100f00:	68 00 10 00 00       	push   $0x1000
f0100f05:	6a 00                	push   $0x0
f0100f07:	50                   	push   %eax
	// Find out how much memory the machine has (npages & npages_basemem).
	i386_detect_memory();//get the number of membase page(can be used) ,io hole page(not) ,extmem page(ok)

	//////////////////////////////////////////////////////////////////////
	//!!! create initial page directory.
	kern_pgdir = (pde_t *) boot_alloc(PGSIZE);//in inc/mmu.h PGSIZE is 4096b = 4KB
f0100f08:	a3 48 0e 11 f0       	mov    %eax,0xf0110e48
	memset(kern_pgdir, 0, PGSIZE);//memset(start addr , content, size)
f0100f0d:	e8 9d 1d 00 00       	call   f0102caf <memset>
	// (For now, you don't have understand the greater purpose of the
	// following line.)

	// Permissions: kernel R, user R
    // UVPT is a virtual address in memlayout.h , the address is map to the kern_pgdir(physcial addr)
	kern_pgdir[PDX(UVPT)] = PADDR(kern_pgdir) | PTE_U | PTE_P;
f0100f12:	8b 1d 48 0e 11 f0    	mov    0xf0110e48,%ebx
f0100f18:	b8 8f 00 00 00       	mov    $0x8f,%eax
f0100f1d:	89 da                	mov    %ebx,%edx
f0100f1f:	e8 4a fc ff ff       	call   f0100b6e <_paddr.clone.0>
f0100f24:	83 c8 05             	or     $0x5,%eax
f0100f27:	89 83 f4 0e 00 00    	mov    %eax,0xef4(%ebx)
	// each physical page, there is a corresponding struct PageInfo in this
	// array.  'npages' is the number of physical pages in memory.  Use memset
	// to initialize all fields of each struct PageInfo to 0.
	// Your code goes here:
    /* TODO */
    pages = (struct PageInfo *)boot_alloc(sizeof(struct PageInfo)*npages);
f0100f2d:	a1 44 0e 11 f0       	mov    0xf0110e44,%eax
f0100f32:	c1 e0 03             	shl    $0x3,%eax
f0100f35:	e8 33 f9 ff ff       	call   f010086d <boot_alloc>
    memset(pages,0,npages*(sizeof(struct PageInfo)));
f0100f3a:	8b 15 44 0e 11 f0    	mov    0xf0110e44,%edx
f0100f40:	83 c4 0c             	add    $0xc,%esp
f0100f43:	c1 e2 03             	shl    $0x3,%edx
f0100f46:	52                   	push   %edx
f0100f47:	6a 00                	push   $0x0
f0100f49:	50                   	push   %eax
	// each physical page, there is a corresponding struct PageInfo in this
	// array.  'npages' is the number of physical pages in memory.  Use memset
	// to initialize all fields of each struct PageInfo to 0.
	// Your code goes here:
    /* TODO */
    pages = (struct PageInfo *)boot_alloc(sizeof(struct PageInfo)*npages);
f0100f4a:	a3 4c 0e 11 f0       	mov    %eax,0xf0110e4c
    memset(pages,0,npages*(sizeof(struct PageInfo)));
f0100f4f:	e8 5b 1d 00 00       	call   f0102caf <memset>
	// Now that we've allocated the initial kernel data structures, we set
	// up the list of free physical pages. Once we've done so, all further
	// memory management will go through the page_* functions. In
	// particular, we can now map memory using boot_map_region
	// or page_insert
	page_init();
f0100f54:	e8 3b fc ff ff       	call   f0100b94 <page_init>

	check_page_free_list(1);
f0100f59:	b8 01 00 00 00       	mov    $0x1,%eax
f0100f5e:	e8 d2 f9 ff ff       	call   f0100935 <check_page_free_list>
	int nfree;
	struct PageInfo *fl;
	char *c;
	int i;

	if (!pages)
f0100f63:	83 c4 10             	add    $0x10,%esp
f0100f66:	83 3d 4c 0e 11 f0 00 	cmpl   $0x0,0xf0110e4c
f0100f6d:	75 0d                	jne    f0100f7c <mem_init+0x107>
		panic("'pages' is a null pointer!");
f0100f6f:	51                   	push   %ecx
f0100f70:	68 3a 39 10 f0       	push   $0xf010393a
f0100f75:	68 6a 02 00 00       	push   $0x26a
f0100f7a:	eb 34                	jmp    f0100fb0 <mem_init+0x13b>

	// check number of free pages
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f0100f7c:	a1 1c 02 11 f0       	mov    0xf011021c,%eax
f0100f81:	31 f6                	xor    %esi,%esi
f0100f83:	eb 03                	jmp    f0100f88 <mem_init+0x113>
f0100f85:	8b 00                	mov    (%eax),%eax
		++nfree;
f0100f87:	46                   	inc    %esi

	if (!pages)
		panic("'pages' is a null pointer!");

	// check number of free pages
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f0100f88:	85 c0                	test   %eax,%eax
f0100f8a:	75 f9                	jne    f0100f85 <mem_init+0x110>
		++nfree;

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0100f8c:	83 ec 0c             	sub    $0xc,%esp
f0100f8f:	6a 00                	push   $0x0
f0100f91:	e8 9a fc ff ff       	call   f0100c30 <page_alloc>
f0100f96:	89 44 24 18          	mov    %eax,0x18(%esp)
f0100f9a:	83 c4 10             	add    $0x10,%esp
f0100f9d:	85 c0                	test   %eax,%eax
f0100f9f:	75 19                	jne    f0100fba <mem_init+0x145>
f0100fa1:	68 55 39 10 f0       	push   $0xf0103955
f0100fa6:	68 53 37 10 f0       	push   $0xf0103753
f0100fab:	68 72 02 00 00       	push   $0x272
f0100fb0:	68 16 37 10 f0       	push   $0xf0103716
f0100fb5:	e8 e6 10 00 00       	call   f01020a0 <_panic>
	assert((pp1 = page_alloc(0)));
f0100fba:	83 ec 0c             	sub    $0xc,%esp
f0100fbd:	6a 00                	push   $0x0
f0100fbf:	e8 6c fc ff ff       	call   f0100c30 <page_alloc>
f0100fc4:	83 c4 10             	add    $0x10,%esp
f0100fc7:	85 c0                	test   %eax,%eax
f0100fc9:	89 c7                	mov    %eax,%edi
f0100fcb:	75 11                	jne    f0100fde <mem_init+0x169>
f0100fcd:	68 6b 39 10 f0       	push   $0xf010396b
f0100fd2:	68 53 37 10 f0       	push   $0xf0103753
f0100fd7:	68 73 02 00 00       	push   $0x273
f0100fdc:	eb d2                	jmp    f0100fb0 <mem_init+0x13b>
	assert((pp2 = page_alloc(0)));
f0100fde:	83 ec 0c             	sub    $0xc,%esp
f0100fe1:	6a 00                	push   $0x0
f0100fe3:	e8 48 fc ff ff       	call   f0100c30 <page_alloc>
f0100fe8:	83 c4 10             	add    $0x10,%esp
f0100feb:	85 c0                	test   %eax,%eax
f0100fed:	89 c3                	mov    %eax,%ebx
f0100fef:	75 11                	jne    f0101002 <mem_init+0x18d>
f0100ff1:	68 81 39 10 f0       	push   $0xf0103981
f0100ff6:	68 53 37 10 f0       	push   $0xf0103753
f0100ffb:	68 74 02 00 00       	push   $0x274
f0101000:	eb ae                	jmp    f0100fb0 <mem_init+0x13b>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f0101002:	3b 7c 24 08          	cmp    0x8(%esp),%edi
f0101006:	75 11                	jne    f0101019 <mem_init+0x1a4>
f0101008:	68 97 39 10 f0       	push   $0xf0103997
f010100d:	68 53 37 10 f0       	push   $0xf0103753
f0101012:	68 77 02 00 00       	push   $0x277
f0101017:	eb 97                	jmp    f0100fb0 <mem_init+0x13b>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101019:	39 f8                	cmp    %edi,%eax
f010101b:	74 06                	je     f0101023 <mem_init+0x1ae>
f010101d:	3b 44 24 08          	cmp    0x8(%esp),%eax
f0101021:	75 14                	jne    f0101037 <mem_init+0x1c2>
f0101023:	68 a9 39 10 f0       	push   $0xf01039a9
f0101028:	68 53 37 10 f0       	push   $0xf0103753
f010102d:	68 78 02 00 00       	push   $0x278
f0101032:	e9 79 ff ff ff       	jmp    f0100fb0 <mem_init+0x13b>
	assert(page2pa(pp0) < npages*PGSIZE);
f0101037:	8b 44 24 08          	mov    0x8(%esp),%eax
f010103b:	e8 20 f8 ff ff       	call   f0100860 <page2pa>
f0101040:	8b 2d 44 0e 11 f0    	mov    0xf0110e44,%ebp
f0101046:	c1 e5 0c             	shl    $0xc,%ebp
f0101049:	39 e8                	cmp    %ebp,%eax
f010104b:	72 14                	jb     f0101061 <mem_init+0x1ec>
f010104d:	68 c9 39 10 f0       	push   $0xf01039c9
f0101052:	68 53 37 10 f0       	push   $0xf0103753
f0101057:	68 79 02 00 00       	push   $0x279
f010105c:	e9 4f ff ff ff       	jmp    f0100fb0 <mem_init+0x13b>
	assert(page2pa(pp1) < npages*PGSIZE);
f0101061:	89 f8                	mov    %edi,%eax
f0101063:	e8 f8 f7 ff ff       	call   f0100860 <page2pa>
f0101068:	39 e8                	cmp    %ebp,%eax
f010106a:	72 14                	jb     f0101080 <mem_init+0x20b>
f010106c:	68 e6 39 10 f0       	push   $0xf01039e6
f0101071:	68 53 37 10 f0       	push   $0xf0103753
f0101076:	68 7a 02 00 00       	push   $0x27a
f010107b:	e9 30 ff ff ff       	jmp    f0100fb0 <mem_init+0x13b>
	assert(page2pa(pp2) < npages*PGSIZE);
f0101080:	89 d8                	mov    %ebx,%eax
f0101082:	e8 d9 f7 ff ff       	call   f0100860 <page2pa>
f0101087:	39 e8                	cmp    %ebp,%eax
f0101089:	72 14                	jb     f010109f <mem_init+0x22a>
f010108b:	68 03 3a 10 f0       	push   $0xf0103a03
f0101090:	68 53 37 10 f0       	push   $0xf0103753
f0101095:	68 7b 02 00 00       	push   $0x27b
f010109a:	e9 11 ff ff ff       	jmp    f0100fb0 <mem_init+0x13b>
	// temporarily steal the rest of the free pages
	fl = page_free_list;
	page_free_list = 0;

	// should be no free memory
	assert(!page_alloc(0));
f010109f:	83 ec 0c             	sub    $0xc,%esp
	assert(page2pa(pp0) < npages*PGSIZE);
	assert(page2pa(pp1) < npages*PGSIZE);
	assert(page2pa(pp2) < npages*PGSIZE);

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f01010a2:	8b 2d 1c 02 11 f0    	mov    0xf011021c,%ebp
	page_free_list = 0;

	// should be no free memory
	assert(!page_alloc(0));
f01010a8:	6a 00                	push   $0x0
	assert(page2pa(pp1) < npages*PGSIZE);
	assert(page2pa(pp2) < npages*PGSIZE);

	// temporarily steal the rest of the free pages
	fl = page_free_list;
	page_free_list = 0;
f01010aa:	c7 05 1c 02 11 f0 00 	movl   $0x0,0xf011021c
f01010b1:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f01010b4:	e8 77 fb ff ff       	call   f0100c30 <page_alloc>
f01010b9:	83 c4 10             	add    $0x10,%esp
f01010bc:	85 c0                	test   %eax,%eax
f01010be:	74 14                	je     f01010d4 <mem_init+0x25f>
f01010c0:	68 20 3a 10 f0       	push   $0xf0103a20
f01010c5:	68 53 37 10 f0       	push   $0xf0103753
f01010ca:	68 82 02 00 00       	push   $0x282
f01010cf:	e9 dc fe ff ff       	jmp    f0100fb0 <mem_init+0x13b>

	// free and re-allocate?
	page_free(pp0);
f01010d4:	83 ec 0c             	sub    $0xc,%esp
f01010d7:	ff 74 24 14          	pushl  0x14(%esp)
f01010db:	e8 91 fb ff ff       	call   f0100c71 <page_free>
	page_free(pp1);
f01010e0:	89 3c 24             	mov    %edi,(%esp)
f01010e3:	e8 89 fb ff ff       	call   f0100c71 <page_free>
	page_free(pp2);
f01010e8:	89 1c 24             	mov    %ebx,(%esp)
f01010eb:	e8 81 fb ff ff       	call   f0100c71 <page_free>
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f01010f0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01010f7:	e8 34 fb ff ff       	call   f0100c30 <page_alloc>
f01010fc:	83 c4 10             	add    $0x10,%esp
f01010ff:	85 c0                	test   %eax,%eax
f0101101:	89 c3                	mov    %eax,%ebx
f0101103:	75 14                	jne    f0101119 <mem_init+0x2a4>
f0101105:	68 55 39 10 f0       	push   $0xf0103955
f010110a:	68 53 37 10 f0       	push   $0xf0103753
f010110f:	68 89 02 00 00       	push   $0x289
f0101114:	e9 97 fe ff ff       	jmp    f0100fb0 <mem_init+0x13b>
	assert((pp1 = page_alloc(0)));
f0101119:	83 ec 0c             	sub    $0xc,%esp
f010111c:	6a 00                	push   $0x0
f010111e:	e8 0d fb ff ff       	call   f0100c30 <page_alloc>
f0101123:	89 44 24 18          	mov    %eax,0x18(%esp)
f0101127:	83 c4 10             	add    $0x10,%esp
f010112a:	85 c0                	test   %eax,%eax
f010112c:	75 14                	jne    f0101142 <mem_init+0x2cd>
f010112e:	68 6b 39 10 f0       	push   $0xf010396b
f0101133:	68 53 37 10 f0       	push   $0xf0103753
f0101138:	68 8a 02 00 00       	push   $0x28a
f010113d:	e9 6e fe ff ff       	jmp    f0100fb0 <mem_init+0x13b>
	assert((pp2 = page_alloc(0)));
f0101142:	83 ec 0c             	sub    $0xc,%esp
f0101145:	6a 00                	push   $0x0
f0101147:	e8 e4 fa ff ff       	call   f0100c30 <page_alloc>
f010114c:	83 c4 10             	add    $0x10,%esp
f010114f:	85 c0                	test   %eax,%eax
f0101151:	89 c7                	mov    %eax,%edi
f0101153:	75 14                	jne    f0101169 <mem_init+0x2f4>
f0101155:	68 81 39 10 f0       	push   $0xf0103981
f010115a:	68 53 37 10 f0       	push   $0xf0103753
f010115f:	68 8b 02 00 00       	push   $0x28b
f0101164:	e9 47 fe ff ff       	jmp    f0100fb0 <mem_init+0x13b>
	assert(pp0);
	assert(pp1 && pp1 != pp0);
f0101169:	39 5c 24 08          	cmp    %ebx,0x8(%esp)
f010116d:	75 14                	jne    f0101183 <mem_init+0x30e>
f010116f:	68 97 39 10 f0       	push   $0xf0103997
f0101174:	68 53 37 10 f0       	push   $0xf0103753
f0101179:	68 8d 02 00 00       	push   $0x28d
f010117e:	e9 2d fe ff ff       	jmp    f0100fb0 <mem_init+0x13b>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101183:	3b 44 24 08          	cmp    0x8(%esp),%eax
f0101187:	74 04                	je     f010118d <mem_init+0x318>
f0101189:	39 d8                	cmp    %ebx,%eax
f010118b:	75 14                	jne    f01011a1 <mem_init+0x32c>
f010118d:	68 a9 39 10 f0       	push   $0xf01039a9
f0101192:	68 53 37 10 f0       	push   $0xf0103753
f0101197:	68 8e 02 00 00       	push   $0x28e
f010119c:	e9 0f fe ff ff       	jmp    f0100fb0 <mem_init+0x13b>
	assert(!page_alloc(0));
f01011a1:	83 ec 0c             	sub    $0xc,%esp
f01011a4:	6a 00                	push   $0x0
f01011a6:	e8 85 fa ff ff       	call   f0100c30 <page_alloc>
f01011ab:	83 c4 10             	add    $0x10,%esp
f01011ae:	85 c0                	test   %eax,%eax
f01011b0:	74 14                	je     f01011c6 <mem_init+0x351>
f01011b2:	68 20 3a 10 f0       	push   $0xf0103a20
f01011b7:	68 53 37 10 f0       	push   $0xf0103753
f01011bc:	68 8f 02 00 00       	push   $0x28f
f01011c1:	e9 ea fd ff ff       	jmp    f0100fb0 <mem_init+0x13b>

	// test flags
	memset(page2kva(pp0), 1, PGSIZE);
f01011c6:	89 d8                	mov    %ebx,%eax
f01011c8:	e8 04 f7 ff ff       	call   f01008d1 <page2kva>
f01011cd:	52                   	push   %edx
f01011ce:	68 00 10 00 00       	push   $0x1000
f01011d3:	6a 01                	push   $0x1
f01011d5:	50                   	push   %eax
f01011d6:	e8 d4 1a 00 00       	call   f0102caf <memset>
	page_free(pp0);
f01011db:	89 1c 24             	mov    %ebx,(%esp)
f01011de:	e8 8e fa ff ff       	call   f0100c71 <page_free>
	assert((pp = page_alloc(ALLOC_ZERO)));
f01011e3:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f01011ea:	e8 41 fa ff ff       	call   f0100c30 <page_alloc>
f01011ef:	83 c4 10             	add    $0x10,%esp
f01011f2:	85 c0                	test   %eax,%eax
f01011f4:	75 14                	jne    f010120a <mem_init+0x395>
f01011f6:	68 2f 3a 10 f0       	push   $0xf0103a2f
f01011fb:	68 53 37 10 f0       	push   $0xf0103753
f0101200:	68 94 02 00 00       	push   $0x294
f0101205:	e9 a6 fd ff ff       	jmp    f0100fb0 <mem_init+0x13b>
	assert(pp && pp0 == pp);
f010120a:	39 c3                	cmp    %eax,%ebx
f010120c:	74 14                	je     f0101222 <mem_init+0x3ad>
f010120e:	68 4d 3a 10 f0       	push   $0xf0103a4d
f0101213:	68 53 37 10 f0       	push   $0xf0103753
f0101218:	68 95 02 00 00       	push   $0x295
f010121d:	e9 8e fd ff ff       	jmp    f0100fb0 <mem_init+0x13b>
	c = page2kva(pp);
f0101222:	89 d8                	mov    %ebx,%eax
f0101224:	e8 a8 f6 ff ff       	call   f01008d1 <page2kva>
	for (i = 0; i < PGSIZE; i++)
f0101229:	31 d2                	xor    %edx,%edx
		assert(c[i] == 0);
f010122b:	80 3c 10 00          	cmpb   $0x0,(%eax,%edx,1)
f010122f:	74 14                	je     f0101245 <mem_init+0x3d0>
f0101231:	68 5d 3a 10 f0       	push   $0xf0103a5d
f0101236:	68 53 37 10 f0       	push   $0xf0103753
f010123b:	68 98 02 00 00       	push   $0x298
f0101240:	e9 6b fd ff ff       	jmp    f0100fb0 <mem_init+0x13b>
	memset(page2kva(pp0), 1, PGSIZE);
	page_free(pp0);
	assert((pp = page_alloc(ALLOC_ZERO)));
	assert(pp && pp0 == pp);
	c = page2kva(pp);
	for (i = 0; i < PGSIZE; i++)
f0101245:	42                   	inc    %edx
f0101246:	81 fa 00 10 00 00    	cmp    $0x1000,%edx
f010124c:	75 dd                	jne    f010122b <mem_init+0x3b6>

	// give free list back
	page_free_list = fl;

	// free the pages we took
	page_free(pp0);
f010124e:	83 ec 0c             	sub    $0xc,%esp
f0101251:	53                   	push   %ebx
	c = page2kva(pp);
	for (i = 0; i < PGSIZE; i++)
		assert(c[i] == 0);

	// give free list back
	page_free_list = fl;
f0101252:	89 2d 1c 02 11 f0    	mov    %ebp,0xf011021c

	// free the pages we took
	page_free(pp0);
f0101258:	e8 14 fa ff ff       	call   f0100c71 <page_free>
	page_free(pp1);
f010125d:	5b                   	pop    %ebx
f010125e:	ff 74 24 14          	pushl  0x14(%esp)
f0101262:	e8 0a fa ff ff       	call   f0100c71 <page_free>
	page_free(pp2);
f0101267:	89 3c 24             	mov    %edi,(%esp)
f010126a:	e8 02 fa ff ff       	call   f0100c71 <page_free>

	// number of free pages should be the same
	for (pp = page_free_list; pp; pp = pp->pp_link)
f010126f:	a1 1c 02 11 f0       	mov    0xf011021c,%eax
f0101274:	83 c4 10             	add    $0x10,%esp
f0101277:	eb 03                	jmp    f010127c <mem_init+0x407>
f0101279:	8b 00                	mov    (%eax),%eax
		--nfree;
f010127b:	4e                   	dec    %esi
	page_free(pp0);
	page_free(pp1);
	page_free(pp2);

	// number of free pages should be the same
	for (pp = page_free_list; pp; pp = pp->pp_link)
f010127c:	85 c0                	test   %eax,%eax
f010127e:	75 f9                	jne    f0101279 <mem_init+0x404>
		--nfree;
	assert(nfree == 0);
f0101280:	85 f6                	test   %esi,%esi
f0101282:	74 14                	je     f0101298 <mem_init+0x423>
f0101284:	68 67 3a 10 f0       	push   $0xf0103a67
f0101289:	68 53 37 10 f0       	push   $0xf0103753
f010128e:	68 a5 02 00 00       	push   $0x2a5
f0101293:	e9 18 fd ff ff       	jmp    f0100fb0 <mem_init+0x13b>

	cprintf("check_page_alloc() succeeded!\n");
f0101298:	83 ec 0c             	sub    $0xc,%esp
f010129b:	68 72 3a 10 f0       	push   $0xf0103a72
f01012a0:	e8 a1 f5 ff ff       	call   f0100846 <cprintf>
	int i;
	extern pde_t entry_pgdir[];

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f01012a5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01012ac:	e8 7f f9 ff ff       	call   f0100c30 <page_alloc>
f01012b1:	83 c4 10             	add    $0x10,%esp
f01012b4:	85 c0                	test   %eax,%eax
f01012b6:	89 c6                	mov    %eax,%esi
f01012b8:	75 14                	jne    f01012ce <mem_init+0x459>
f01012ba:	68 55 39 10 f0       	push   $0xf0103955
f01012bf:	68 53 37 10 f0       	push   $0xf0103753
f01012c4:	68 02 03 00 00       	push   $0x302
f01012c9:	e9 e2 fc ff ff       	jmp    f0100fb0 <mem_init+0x13b>
	assert((pp1 = page_alloc(0)));
f01012ce:	83 ec 0c             	sub    $0xc,%esp
f01012d1:	6a 00                	push   $0x0
f01012d3:	e8 58 f9 ff ff       	call   f0100c30 <page_alloc>
f01012d8:	83 c4 10             	add    $0x10,%esp
f01012db:	85 c0                	test   %eax,%eax
f01012dd:	89 c3                	mov    %eax,%ebx
f01012df:	75 14                	jne    f01012f5 <mem_init+0x480>
f01012e1:	68 6b 39 10 f0       	push   $0xf010396b
f01012e6:	68 53 37 10 f0       	push   $0xf0103753
f01012eb:	68 03 03 00 00       	push   $0x303
f01012f0:	e9 bb fc ff ff       	jmp    f0100fb0 <mem_init+0x13b>
	assert((pp2 = page_alloc(0)));
f01012f5:	83 ec 0c             	sub    $0xc,%esp
f01012f8:	6a 00                	push   $0x0
f01012fa:	e8 31 f9 ff ff       	call   f0100c30 <page_alloc>
f01012ff:	83 c4 10             	add    $0x10,%esp
f0101302:	85 c0                	test   %eax,%eax
f0101304:	89 c7                	mov    %eax,%edi
f0101306:	75 14                	jne    f010131c <mem_init+0x4a7>
f0101308:	68 81 39 10 f0       	push   $0xf0103981
f010130d:	68 53 37 10 f0       	push   $0xf0103753
f0101312:	68 04 03 00 00       	push   $0x304
f0101317:	e9 94 fc ff ff       	jmp    f0100fb0 <mem_init+0x13b>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f010131c:	39 f3                	cmp    %esi,%ebx
f010131e:	75 14                	jne    f0101334 <mem_init+0x4bf>
f0101320:	68 97 39 10 f0       	push   $0xf0103997
f0101325:	68 53 37 10 f0       	push   $0xf0103753
f010132a:	68 07 03 00 00       	push   $0x307
f010132f:	e9 7c fc ff ff       	jmp    f0100fb0 <mem_init+0x13b>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101334:	39 d8                	cmp    %ebx,%eax
f0101336:	74 04                	je     f010133c <mem_init+0x4c7>
f0101338:	39 f0                	cmp    %esi,%eax
f010133a:	75 14                	jne    f0101350 <mem_init+0x4db>
f010133c:	68 a9 39 10 f0       	push   $0xf01039a9
f0101341:	68 53 37 10 f0       	push   $0xf0103753
f0101346:	68 08 03 00 00       	push   $0x308
f010134b:	e9 60 fc ff ff       	jmp    f0100fb0 <mem_init+0x13b>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f0101350:	a1 1c 02 11 f0       	mov    0xf011021c,%eax
	page_free_list = 0;
f0101355:	c7 05 1c 02 11 f0 00 	movl   $0x0,0xf011021c
f010135c:	00 00 00 
	assert(pp0);
	assert(pp1 && pp1 != pp0);
	assert(pp2 && pp2 != pp1 && pp2 != pp0);

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f010135f:	89 44 24 08          	mov    %eax,0x8(%esp)
	page_free_list = 0;

	// should be no free memory
	assert(!page_alloc(0));
f0101363:	83 ec 0c             	sub    $0xc,%esp
f0101366:	6a 00                	push   $0x0
f0101368:	e8 c3 f8 ff ff       	call   f0100c30 <page_alloc>
f010136d:	83 c4 10             	add    $0x10,%esp
f0101370:	85 c0                	test   %eax,%eax
f0101372:	74 14                	je     f0101388 <mem_init+0x513>
f0101374:	68 20 3a 10 f0       	push   $0xf0103a20
f0101379:	68 53 37 10 f0       	push   $0xf0103753
f010137e:	68 0f 03 00 00       	push   $0x30f
f0101383:	e9 28 fc ff ff       	jmp    f0100fb0 <mem_init+0x13b>

	// there is no page allocated at address 0
	assert(page_lookup(kern_pgdir, (void *) 0x0, &ptep) == NULL);
f0101388:	51                   	push   %ecx
f0101389:	8d 44 24 20          	lea    0x20(%esp),%eax
f010138d:	50                   	push   %eax
f010138e:	6a 00                	push   $0x0
f0101390:	ff 35 48 0e 11 f0    	pushl  0xf0110e48
f0101396:	e8 e7 f9 ff ff       	call   f0100d82 <page_lookup>
f010139b:	83 c4 10             	add    $0x10,%esp
f010139e:	85 c0                	test   %eax,%eax
f01013a0:	74 14                	je     f01013b6 <mem_init+0x541>
f01013a2:	68 91 3a 10 f0       	push   $0xf0103a91
f01013a7:	68 53 37 10 f0       	push   $0xf0103753
f01013ac:	68 12 03 00 00       	push   $0x312
f01013b1:	e9 fa fb ff ff       	jmp    f0100fb0 <mem_init+0x13b>

	// there is no free memory, so we can't allocate a page table
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) < 0);
f01013b6:	6a 02                	push   $0x2
f01013b8:	6a 00                	push   $0x0
f01013ba:	53                   	push   %ebx
f01013bb:	ff 35 48 0e 11 f0    	pushl  0xf0110e48
f01013c1:	e8 54 fa ff ff       	call   f0100e1a <page_insert>
f01013c6:	83 c4 10             	add    $0x10,%esp
f01013c9:	85 c0                	test   %eax,%eax
f01013cb:	78 14                	js     f01013e1 <mem_init+0x56c>
f01013cd:	68 c6 3a 10 f0       	push   $0xf0103ac6
f01013d2:	68 53 37 10 f0       	push   $0xf0103753
f01013d7:	68 15 03 00 00       	push   $0x315
f01013dc:	e9 cf fb ff ff       	jmp    f0100fb0 <mem_init+0x13b>

	// free pp0 and try again: pp0 should be used for page table
	page_free(pp0);
f01013e1:	83 ec 0c             	sub    $0xc,%esp
f01013e4:	56                   	push   %esi
f01013e5:	e8 87 f8 ff ff       	call   f0100c71 <page_free>
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) == 0);
f01013ea:	6a 02                	push   $0x2
f01013ec:	6a 00                	push   $0x0
f01013ee:	53                   	push   %ebx
f01013ef:	ff 35 48 0e 11 f0    	pushl  0xf0110e48
f01013f5:	e8 20 fa ff ff       	call   f0100e1a <page_insert>
f01013fa:	83 c4 20             	add    $0x20,%esp
f01013fd:	85 c0                	test   %eax,%eax
f01013ff:	74 14                	je     f0101415 <mem_init+0x5a0>
f0101401:	68 f3 3a 10 f0       	push   $0xf0103af3
f0101406:	68 53 37 10 f0       	push   $0xf0103753
f010140b:	68 19 03 00 00       	push   $0x319
f0101410:	e9 9b fb ff ff       	jmp    f0100fb0 <mem_init+0x13b>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0101415:	8b 2d 48 0e 11 f0    	mov    0xf0110e48,%ebp
f010141b:	89 f0                	mov    %esi,%eax
f010141d:	e8 3e f4 ff ff       	call   f0100860 <page2pa>
f0101422:	8b 55 00             	mov    0x0(%ebp),%edx
f0101425:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f010142b:	39 c2                	cmp    %eax,%edx
f010142d:	74 14                	je     f0101443 <mem_init+0x5ce>
f010142f:	68 21 3b 10 f0       	push   $0xf0103b21
f0101434:	68 53 37 10 f0       	push   $0xf0103753
f0101439:	68 1a 03 00 00       	push   $0x31a
f010143e:	e9 6d fb ff ff       	jmp    f0100fb0 <mem_init+0x13b>
	assert(check_va2pa(kern_pgdir, 0x0) == page2pa(pp1));
f0101443:	31 d2                	xor    %edx,%edx
f0101445:	89 e8                	mov    %ebp,%eax
f0101447:	e8 9e f4 ff ff       	call   f01008ea <check_va2pa>
f010144c:	89 c5                	mov    %eax,%ebp
f010144e:	89 d8                	mov    %ebx,%eax
f0101450:	e8 0b f4 ff ff       	call   f0100860 <page2pa>
f0101455:	39 c5                	cmp    %eax,%ebp
f0101457:	74 14                	je     f010146d <mem_init+0x5f8>
f0101459:	68 49 3b 10 f0       	push   $0xf0103b49
f010145e:	68 53 37 10 f0       	push   $0xf0103753
f0101463:	68 1b 03 00 00       	push   $0x31b
f0101468:	e9 43 fb ff ff       	jmp    f0100fb0 <mem_init+0x13b>
	assert(pp1->pp_ref == 1);
f010146d:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0101472:	74 14                	je     f0101488 <mem_init+0x613>
f0101474:	68 76 3b 10 f0       	push   $0xf0103b76
f0101479:	68 53 37 10 f0       	push   $0xf0103753
f010147e:	68 1c 03 00 00       	push   $0x31c
f0101483:	e9 28 fb ff ff       	jmp    f0100fb0 <mem_init+0x13b>
	assert(pp0->pp_ref == 1);
f0101488:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f010148d:	74 14                	je     f01014a3 <mem_init+0x62e>
f010148f:	68 87 3b 10 f0       	push   $0xf0103b87
f0101494:	68 53 37 10 f0       	push   $0xf0103753
f0101499:	68 1d 03 00 00       	push   $0x31d
f010149e:	e9 0d fb ff ff       	jmp    f0100fb0 <mem_init+0x13b>

	// should be able to map pp2 at PGSIZE because pp0 is already allocated for page table
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f01014a3:	6a 02                	push   $0x2
f01014a5:	68 00 10 00 00       	push   $0x1000
f01014aa:	57                   	push   %edi
f01014ab:	ff 35 48 0e 11 f0    	pushl  0xf0110e48
f01014b1:	e8 64 f9 ff ff       	call   f0100e1a <page_insert>
f01014b6:	83 c4 10             	add    $0x10,%esp
f01014b9:	85 c0                	test   %eax,%eax
f01014bb:	74 14                	je     f01014d1 <mem_init+0x65c>
f01014bd:	68 98 3b 10 f0       	push   $0xf0103b98
f01014c2:	68 53 37 10 f0       	push   $0xf0103753
f01014c7:	68 20 03 00 00       	push   $0x320
f01014cc:	e9 df fa ff ff       	jmp    f0100fb0 <mem_init+0x13b>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f01014d1:	a1 48 0e 11 f0       	mov    0xf0110e48,%eax
f01014d6:	ba 00 10 00 00       	mov    $0x1000,%edx
f01014db:	e8 0a f4 ff ff       	call   f01008ea <check_va2pa>
f01014e0:	89 c5                	mov    %eax,%ebp
f01014e2:	89 f8                	mov    %edi,%eax
f01014e4:	e8 77 f3 ff ff       	call   f0100860 <page2pa>
f01014e9:	39 c5                	cmp    %eax,%ebp
f01014eb:	74 14                	je     f0101501 <mem_init+0x68c>
f01014ed:	68 d1 3b 10 f0       	push   $0xf0103bd1
f01014f2:	68 53 37 10 f0       	push   $0xf0103753
f01014f7:	68 21 03 00 00       	push   $0x321
f01014fc:	e9 af fa ff ff       	jmp    f0100fb0 <mem_init+0x13b>
	assert(pp2->pp_ref == 1);
f0101501:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f0101506:	74 14                	je     f010151c <mem_init+0x6a7>
f0101508:	68 01 3c 10 f0       	push   $0xf0103c01
f010150d:	68 53 37 10 f0       	push   $0xf0103753
f0101512:	68 22 03 00 00       	push   $0x322
f0101517:	e9 94 fa ff ff       	jmp    f0100fb0 <mem_init+0x13b>

	// should be no free memory
	assert(!page_alloc(0));
f010151c:	83 ec 0c             	sub    $0xc,%esp
f010151f:	6a 00                	push   $0x0
f0101521:	e8 0a f7 ff ff       	call   f0100c30 <page_alloc>
f0101526:	83 c4 10             	add    $0x10,%esp
f0101529:	85 c0                	test   %eax,%eax
f010152b:	74 14                	je     f0101541 <mem_init+0x6cc>
f010152d:	68 20 3a 10 f0       	push   $0xf0103a20
f0101532:	68 53 37 10 f0       	push   $0xf0103753
f0101537:	68 25 03 00 00       	push   $0x325
f010153c:	e9 6f fa ff ff       	jmp    f0100fb0 <mem_init+0x13b>

	// should be able to map pp2 at PGSIZE because it's already there
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101541:	6a 02                	push   $0x2
f0101543:	68 00 10 00 00       	push   $0x1000
f0101548:	57                   	push   %edi
f0101549:	ff 35 48 0e 11 f0    	pushl  0xf0110e48
f010154f:	e8 c6 f8 ff ff       	call   f0100e1a <page_insert>
f0101554:	83 c4 10             	add    $0x10,%esp
f0101557:	85 c0                	test   %eax,%eax
f0101559:	74 14                	je     f010156f <mem_init+0x6fa>
f010155b:	68 98 3b 10 f0       	push   $0xf0103b98
f0101560:	68 53 37 10 f0       	push   $0xf0103753
f0101565:	68 28 03 00 00       	push   $0x328
f010156a:	e9 41 fa ff ff       	jmp    f0100fb0 <mem_init+0x13b>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f010156f:	a1 48 0e 11 f0       	mov    0xf0110e48,%eax
f0101574:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101579:	e8 6c f3 ff ff       	call   f01008ea <check_va2pa>
f010157e:	89 c5                	mov    %eax,%ebp
f0101580:	89 f8                	mov    %edi,%eax
f0101582:	e8 d9 f2 ff ff       	call   f0100860 <page2pa>
f0101587:	39 c5                	cmp    %eax,%ebp
f0101589:	74 14                	je     f010159f <mem_init+0x72a>
f010158b:	68 d1 3b 10 f0       	push   $0xf0103bd1
f0101590:	68 53 37 10 f0       	push   $0xf0103753
f0101595:	68 29 03 00 00       	push   $0x329
f010159a:	e9 11 fa ff ff       	jmp    f0100fb0 <mem_init+0x13b>
	assert(pp2->pp_ref == 1);
f010159f:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f01015a4:	74 14                	je     f01015ba <mem_init+0x745>
f01015a6:	68 01 3c 10 f0       	push   $0xf0103c01
f01015ab:	68 53 37 10 f0       	push   $0xf0103753
f01015b0:	68 2a 03 00 00       	push   $0x32a
f01015b5:	e9 f6 f9 ff ff       	jmp    f0100fb0 <mem_init+0x13b>

	// pp2 should NOT be on the free list
	// could happen in ref counts are handled sloppily in page_insert
	assert(!page_alloc(0));
f01015ba:	83 ec 0c             	sub    $0xc,%esp
f01015bd:	6a 00                	push   $0x0
f01015bf:	e8 6c f6 ff ff       	call   f0100c30 <page_alloc>
f01015c4:	83 c4 10             	add    $0x10,%esp
f01015c7:	85 c0                	test   %eax,%eax
f01015c9:	74 14                	je     f01015df <mem_init+0x76a>
f01015cb:	68 20 3a 10 f0       	push   $0xf0103a20
f01015d0:	68 53 37 10 f0       	push   $0xf0103753
f01015d5:	68 2e 03 00 00       	push   $0x32e
f01015da:	e9 d1 f9 ff ff       	jmp    f0100fb0 <mem_init+0x13b>

	// check that pgdir_walk returns a pointer to the pte
	ptep = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(PGSIZE)]));
f01015df:	a1 48 0e 11 f0       	mov    0xf0110e48,%eax
f01015e4:	ba 31 03 00 00       	mov    $0x331,%edx
f01015e9:	8b 08                	mov    (%eax),%ecx
f01015eb:	b8 16 37 10 f0       	mov    $0xf0103716,%eax
f01015f0:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
f01015f6:	e8 ad f2 ff ff       	call   f01008a8 <_kaddr>
f01015fb:	89 44 24 1c          	mov    %eax,0x1c(%esp)
	assert(pgdir_walk(kern_pgdir, (void*)PGSIZE, 0) == ptep+PTX(PGSIZE));
f01015ff:	52                   	push   %edx
f0101600:	6a 00                	push   $0x0
f0101602:	68 00 10 00 00       	push   $0x1000
f0101607:	ff 35 48 0e 11 f0    	pushl  0xf0110e48
f010160d:	e8 b8 f6 ff ff       	call   f0100cca <pgdir_walk>
f0101612:	8b 54 24 2c          	mov    0x2c(%esp),%edx
f0101616:	83 c4 10             	add    $0x10,%esp
f0101619:	83 c2 04             	add    $0x4,%edx
f010161c:	39 d0                	cmp    %edx,%eax
f010161e:	74 14                	je     f0101634 <mem_init+0x7bf>
f0101620:	68 12 3c 10 f0       	push   $0xf0103c12
f0101625:	68 53 37 10 f0       	push   $0xf0103753
f010162a:	68 32 03 00 00       	push   $0x332
f010162f:	e9 7c f9 ff ff       	jmp    f0100fb0 <mem_init+0x13b>

	// should be able to change permissions too.
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W|PTE_U) == 0);
f0101634:	6a 06                	push   $0x6
f0101636:	68 00 10 00 00       	push   $0x1000
f010163b:	57                   	push   %edi
f010163c:	ff 35 48 0e 11 f0    	pushl  0xf0110e48
f0101642:	e8 d3 f7 ff ff       	call   f0100e1a <page_insert>
f0101647:	83 c4 10             	add    $0x10,%esp
f010164a:	85 c0                	test   %eax,%eax
f010164c:	74 14                	je     f0101662 <mem_init+0x7ed>
f010164e:	68 4f 3c 10 f0       	push   $0xf0103c4f
f0101653:	68 53 37 10 f0       	push   $0xf0103753
f0101658:	68 35 03 00 00       	push   $0x335
f010165d:	e9 4e f9 ff ff       	jmp    f0100fb0 <mem_init+0x13b>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101662:	a1 48 0e 11 f0       	mov    0xf0110e48,%eax
f0101667:	ba 00 10 00 00       	mov    $0x1000,%edx
f010166c:	e8 79 f2 ff ff       	call   f01008ea <check_va2pa>
f0101671:	89 c5                	mov    %eax,%ebp
f0101673:	89 f8                	mov    %edi,%eax
f0101675:	e8 e6 f1 ff ff       	call   f0100860 <page2pa>
f010167a:	39 c5                	cmp    %eax,%ebp
f010167c:	74 14                	je     f0101692 <mem_init+0x81d>
f010167e:	68 d1 3b 10 f0       	push   $0xf0103bd1
f0101683:	68 53 37 10 f0       	push   $0xf0103753
f0101688:	68 36 03 00 00       	push   $0x336
f010168d:	e9 1e f9 ff ff       	jmp    f0100fb0 <mem_init+0x13b>
	assert(pp2->pp_ref == 1);
f0101692:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f0101697:	74 14                	je     f01016ad <mem_init+0x838>
f0101699:	68 01 3c 10 f0       	push   $0xf0103c01
f010169e:	68 53 37 10 f0       	push   $0xf0103753
f01016a3:	68 37 03 00 00       	push   $0x337
f01016a8:	e9 03 f9 ff ff       	jmp    f0100fb0 <mem_init+0x13b>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U);
f01016ad:	50                   	push   %eax
f01016ae:	6a 00                	push   $0x0
f01016b0:	68 00 10 00 00       	push   $0x1000
f01016b5:	ff 35 48 0e 11 f0    	pushl  0xf0110e48
f01016bb:	e8 0a f6 ff ff       	call   f0100cca <pgdir_walk>
f01016c0:	83 c4 10             	add    $0x10,%esp
f01016c3:	f6 00 04             	testb  $0x4,(%eax)
f01016c6:	75 14                	jne    f01016dc <mem_init+0x867>
f01016c8:	68 8e 3c 10 f0       	push   $0xf0103c8e
f01016cd:	68 53 37 10 f0       	push   $0xf0103753
f01016d2:	68 38 03 00 00       	push   $0x338
f01016d7:	e9 d4 f8 ff ff       	jmp    f0100fb0 <mem_init+0x13b>
	assert(kern_pgdir[0] & PTE_U);
f01016dc:	a1 48 0e 11 f0       	mov    0xf0110e48,%eax
f01016e1:	f6 00 04             	testb  $0x4,(%eax)
f01016e4:	75 14                	jne    f01016fa <mem_init+0x885>
f01016e6:	68 c1 3c 10 f0       	push   $0xf0103cc1
f01016eb:	68 53 37 10 f0       	push   $0xf0103753
f01016f0:	68 39 03 00 00       	push   $0x339
f01016f5:	e9 b6 f8 ff ff       	jmp    f0100fb0 <mem_init+0x13b>

	// should be able to remap with fewer permissions
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f01016fa:	6a 02                	push   $0x2
f01016fc:	68 00 10 00 00       	push   $0x1000
f0101701:	57                   	push   %edi
f0101702:	50                   	push   %eax
f0101703:	e8 12 f7 ff ff       	call   f0100e1a <page_insert>
f0101708:	83 c4 10             	add    $0x10,%esp
f010170b:	85 c0                	test   %eax,%eax
f010170d:	74 14                	je     f0101723 <mem_init+0x8ae>
f010170f:	68 98 3b 10 f0       	push   $0xf0103b98
f0101714:	68 53 37 10 f0       	push   $0xf0103753
f0101719:	68 3c 03 00 00       	push   $0x33c
f010171e:	e9 8d f8 ff ff       	jmp    f0100fb0 <mem_init+0x13b>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_W);
f0101723:	55                   	push   %ebp
f0101724:	6a 00                	push   $0x0
f0101726:	68 00 10 00 00       	push   $0x1000
f010172b:	ff 35 48 0e 11 f0    	pushl  0xf0110e48
f0101731:	e8 94 f5 ff ff       	call   f0100cca <pgdir_walk>
f0101736:	83 c4 10             	add    $0x10,%esp
f0101739:	f6 00 02             	testb  $0x2,(%eax)
f010173c:	75 14                	jne    f0101752 <mem_init+0x8dd>
f010173e:	68 d7 3c 10 f0       	push   $0xf0103cd7
f0101743:	68 53 37 10 f0       	push   $0xf0103753
f0101748:	68 3d 03 00 00       	push   $0x33d
f010174d:	e9 5e f8 ff ff       	jmp    f0100fb0 <mem_init+0x13b>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0101752:	51                   	push   %ecx
f0101753:	6a 00                	push   $0x0
f0101755:	68 00 10 00 00       	push   $0x1000
f010175a:	ff 35 48 0e 11 f0    	pushl  0xf0110e48
f0101760:	e8 65 f5 ff ff       	call   f0100cca <pgdir_walk>
f0101765:	83 c4 10             	add    $0x10,%esp
f0101768:	f6 00 04             	testb  $0x4,(%eax)
f010176b:	74 14                	je     f0101781 <mem_init+0x90c>
f010176d:	68 0a 3d 10 f0       	push   $0xf0103d0a
f0101772:	68 53 37 10 f0       	push   $0xf0103753
f0101777:	68 3e 03 00 00       	push   $0x33e
f010177c:	e9 2f f8 ff ff       	jmp    f0100fb0 <mem_init+0x13b>

	// should not be able to map at PTSIZE because need free page for page table
	assert(page_insert(kern_pgdir, pp0, (void*) PTSIZE, PTE_W) < 0);
f0101781:	6a 02                	push   $0x2
f0101783:	68 00 00 40 00       	push   $0x400000
f0101788:	56                   	push   %esi
f0101789:	ff 35 48 0e 11 f0    	pushl  0xf0110e48
f010178f:	e8 86 f6 ff ff       	call   f0100e1a <page_insert>
f0101794:	83 c4 10             	add    $0x10,%esp
f0101797:	85 c0                	test   %eax,%eax
f0101799:	78 14                	js     f01017af <mem_init+0x93a>
f010179b:	68 40 3d 10 f0       	push   $0xf0103d40
f01017a0:	68 53 37 10 f0       	push   $0xf0103753
f01017a5:	68 41 03 00 00       	push   $0x341
f01017aa:	e9 01 f8 ff ff       	jmp    f0100fb0 <mem_init+0x13b>

	// insert pp1 at PGSIZE (replacing pp2)
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W) == 0);
f01017af:	6a 02                	push   $0x2
f01017b1:	68 00 10 00 00       	push   $0x1000
f01017b6:	53                   	push   %ebx
f01017b7:	ff 35 48 0e 11 f0    	pushl  0xf0110e48
f01017bd:	e8 58 f6 ff ff       	call   f0100e1a <page_insert>
f01017c2:	83 c4 10             	add    $0x10,%esp
f01017c5:	85 c0                	test   %eax,%eax
f01017c7:	74 14                	je     f01017dd <mem_init+0x968>
f01017c9:	68 78 3d 10 f0       	push   $0xf0103d78
f01017ce:	68 53 37 10 f0       	push   $0xf0103753
f01017d3:	68 44 03 00 00       	push   $0x344
f01017d8:	e9 d3 f7 ff ff       	jmp    f0100fb0 <mem_init+0x13b>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f01017dd:	52                   	push   %edx
f01017de:	6a 00                	push   $0x0
f01017e0:	68 00 10 00 00       	push   $0x1000
f01017e5:	ff 35 48 0e 11 f0    	pushl  0xf0110e48
f01017eb:	e8 da f4 ff ff       	call   f0100cca <pgdir_walk>
f01017f0:	83 c4 10             	add    $0x10,%esp
f01017f3:	f6 00 04             	testb  $0x4,(%eax)
f01017f6:	74 14                	je     f010180c <mem_init+0x997>
f01017f8:	68 0a 3d 10 f0       	push   $0xf0103d0a
f01017fd:	68 53 37 10 f0       	push   $0xf0103753
f0101802:	68 45 03 00 00       	push   $0x345
f0101807:	e9 a4 f7 ff ff       	jmp    f0100fb0 <mem_init+0x13b>

	// should have pp1 at both 0 and PGSIZE, pp2 nowhere, ...
	assert(check_va2pa(kern_pgdir, 0) == page2pa(pp1));
f010180c:	a1 48 0e 11 f0       	mov    0xf0110e48,%eax
f0101811:	31 d2                	xor    %edx,%edx
f0101813:	e8 d2 f0 ff ff       	call   f01008ea <check_va2pa>
f0101818:	89 c5                	mov    %eax,%ebp
f010181a:	89 d8                	mov    %ebx,%eax
f010181c:	e8 3f f0 ff ff       	call   f0100860 <page2pa>
f0101821:	39 c5                	cmp    %eax,%ebp
f0101823:	74 14                	je     f0101839 <mem_init+0x9c4>
f0101825:	68 b1 3d 10 f0       	push   $0xf0103db1
f010182a:	68 53 37 10 f0       	push   $0xf0103753
f010182f:	68 48 03 00 00       	push   $0x348
f0101834:	e9 77 f7 ff ff       	jmp    f0100fb0 <mem_init+0x13b>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0101839:	a1 48 0e 11 f0       	mov    0xf0110e48,%eax
f010183e:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101843:	e8 a2 f0 ff ff       	call   f01008ea <check_va2pa>
f0101848:	89 c5                	mov    %eax,%ebp
f010184a:	89 d8                	mov    %ebx,%eax
f010184c:	e8 0f f0 ff ff       	call   f0100860 <page2pa>
f0101851:	39 c5                	cmp    %eax,%ebp
f0101853:	74 14                	je     f0101869 <mem_init+0x9f4>
f0101855:	68 dc 3d 10 f0       	push   $0xf0103ddc
f010185a:	68 53 37 10 f0       	push   $0xf0103753
f010185f:	68 49 03 00 00       	push   $0x349
f0101864:	e9 47 f7 ff ff       	jmp    f0100fb0 <mem_init+0x13b>
	// ... and ref counts should reflect this
	assert(pp1->pp_ref == 2);
f0101869:	66 83 7b 04 02       	cmpw   $0x2,0x4(%ebx)
f010186e:	74 14                	je     f0101884 <mem_init+0xa0f>
f0101870:	68 0c 3e 10 f0       	push   $0xf0103e0c
f0101875:	68 53 37 10 f0       	push   $0xf0103753
f010187a:	68 4b 03 00 00       	push   $0x34b
f010187f:	e9 2c f7 ff ff       	jmp    f0100fb0 <mem_init+0x13b>
	assert(pp2->pp_ref == 0);
f0101884:	66 83 7f 04 00       	cmpw   $0x0,0x4(%edi)
f0101889:	74 14                	je     f010189f <mem_init+0xa2a>
f010188b:	68 1d 3e 10 f0       	push   $0xf0103e1d
f0101890:	68 53 37 10 f0       	push   $0xf0103753
f0101895:	68 4c 03 00 00       	push   $0x34c
f010189a:	e9 11 f7 ff ff       	jmp    f0100fb0 <mem_init+0x13b>

	// pp2 should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp2);
f010189f:	83 ec 0c             	sub    $0xc,%esp
f01018a2:	6a 00                	push   $0x0
f01018a4:	e8 87 f3 ff ff       	call   f0100c30 <page_alloc>
f01018a9:	83 c4 10             	add    $0x10,%esp
f01018ac:	85 c0                	test   %eax,%eax
f01018ae:	89 c5                	mov    %eax,%ebp
f01018b0:	74 04                	je     f01018b6 <mem_init+0xa41>
f01018b2:	39 f8                	cmp    %edi,%eax
f01018b4:	74 14                	je     f01018ca <mem_init+0xa55>
f01018b6:	68 2e 3e 10 f0       	push   $0xf0103e2e
f01018bb:	68 53 37 10 f0       	push   $0xf0103753
f01018c0:	68 4f 03 00 00       	push   $0x34f
f01018c5:	e9 e6 f6 ff ff       	jmp    f0100fb0 <mem_init+0x13b>

	// unmapping pp1 at 0 should keep pp1 at PGSIZE
	page_remove(kern_pgdir, 0x0);
f01018ca:	50                   	push   %eax
f01018cb:	50                   	push   %eax
f01018cc:	6a 00                	push   $0x0
f01018ce:	ff 35 48 0e 11 f0    	pushl  0xf0110e48
f01018d4:	e8 05 f5 ff ff       	call   f0100dde <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f01018d9:	a1 48 0e 11 f0       	mov    0xf0110e48,%eax
f01018de:	31 d2                	xor    %edx,%edx
f01018e0:	e8 05 f0 ff ff       	call   f01008ea <check_va2pa>
f01018e5:	83 c4 10             	add    $0x10,%esp
f01018e8:	40                   	inc    %eax
f01018e9:	74 14                	je     f01018ff <mem_init+0xa8a>
f01018eb:	68 50 3e 10 f0       	push   $0xf0103e50
f01018f0:	68 53 37 10 f0       	push   $0xf0103753
f01018f5:	68 53 03 00 00       	push   $0x353
f01018fa:	e9 b1 f6 ff ff       	jmp    f0100fb0 <mem_init+0x13b>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f01018ff:	a1 48 0e 11 f0       	mov    0xf0110e48,%eax
f0101904:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101909:	e8 dc ef ff ff       	call   f01008ea <check_va2pa>
f010190e:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0101912:	89 d8                	mov    %ebx,%eax
f0101914:	e8 47 ef ff ff       	call   f0100860 <page2pa>
f0101919:	39 44 24 0c          	cmp    %eax,0xc(%esp)
f010191d:	74 14                	je     f0101933 <mem_init+0xabe>
f010191f:	68 dc 3d 10 f0       	push   $0xf0103ddc
f0101924:	68 53 37 10 f0       	push   $0xf0103753
f0101929:	68 54 03 00 00       	push   $0x354
f010192e:	e9 7d f6 ff ff       	jmp    f0100fb0 <mem_init+0x13b>
	assert(pp1->pp_ref == 1);
f0101933:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0101938:	74 14                	je     f010194e <mem_init+0xad9>
f010193a:	68 76 3b 10 f0       	push   $0xf0103b76
f010193f:	68 53 37 10 f0       	push   $0xf0103753
f0101944:	68 55 03 00 00       	push   $0x355
f0101949:	e9 62 f6 ff ff       	jmp    f0100fb0 <mem_init+0x13b>
	assert(pp2->pp_ref == 0);
f010194e:	66 83 7f 04 00       	cmpw   $0x0,0x4(%edi)
f0101953:	74 14                	je     f0101969 <mem_init+0xaf4>
f0101955:	68 1d 3e 10 f0       	push   $0xf0103e1d
f010195a:	68 53 37 10 f0       	push   $0xf0103753
f010195f:	68 56 03 00 00       	push   $0x356
f0101964:	e9 47 f6 ff ff       	jmp    f0100fb0 <mem_init+0x13b>

	// test re-inserting pp1 at PGSIZE
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, 0) == 0);
f0101969:	6a 00                	push   $0x0
f010196b:	68 00 10 00 00       	push   $0x1000
f0101970:	53                   	push   %ebx
f0101971:	ff 35 48 0e 11 f0    	pushl  0xf0110e48
f0101977:	e8 9e f4 ff ff       	call   f0100e1a <page_insert>
f010197c:	83 c4 10             	add    $0x10,%esp
f010197f:	85 c0                	test   %eax,%eax
f0101981:	74 14                	je     f0101997 <mem_init+0xb22>
f0101983:	68 73 3e 10 f0       	push   $0xf0103e73
f0101988:	68 53 37 10 f0       	push   $0xf0103753
f010198d:	68 59 03 00 00       	push   $0x359
f0101992:	e9 19 f6 ff ff       	jmp    f0100fb0 <mem_init+0x13b>
	assert(pp1->pp_ref);
f0101997:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f010199c:	75 14                	jne    f01019b2 <mem_init+0xb3d>
f010199e:	68 a8 3e 10 f0       	push   $0xf0103ea8
f01019a3:	68 53 37 10 f0       	push   $0xf0103753
f01019a8:	68 5a 03 00 00       	push   $0x35a
f01019ad:	e9 fe f5 ff ff       	jmp    f0100fb0 <mem_init+0x13b>
	assert(pp1->pp_link == NULL);
f01019b2:	83 3b 00             	cmpl   $0x0,(%ebx)
f01019b5:	74 14                	je     f01019cb <mem_init+0xb56>
f01019b7:	68 b4 3e 10 f0       	push   $0xf0103eb4
f01019bc:	68 53 37 10 f0       	push   $0xf0103753
f01019c1:	68 5b 03 00 00       	push   $0x35b
f01019c6:	e9 e5 f5 ff ff       	jmp    f0100fb0 <mem_init+0x13b>

	// unmapping pp1 at PGSIZE should free it
	page_remove(kern_pgdir, (void*) PGSIZE);
f01019cb:	51                   	push   %ecx
f01019cc:	51                   	push   %ecx
f01019cd:	68 00 10 00 00       	push   $0x1000
f01019d2:	ff 35 48 0e 11 f0    	pushl  0xf0110e48
f01019d8:	e8 01 f4 ff ff       	call   f0100dde <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f01019dd:	a1 48 0e 11 f0       	mov    0xf0110e48,%eax
f01019e2:	31 d2                	xor    %edx,%edx
f01019e4:	e8 01 ef ff ff       	call   f01008ea <check_va2pa>
f01019e9:	83 c4 10             	add    $0x10,%esp
f01019ec:	40                   	inc    %eax
f01019ed:	74 14                	je     f0101a03 <mem_init+0xb8e>
f01019ef:	68 50 3e 10 f0       	push   $0xf0103e50
f01019f4:	68 53 37 10 f0       	push   $0xf0103753
f01019f9:	68 5f 03 00 00       	push   $0x35f
f01019fe:	e9 ad f5 ff ff       	jmp    f0100fb0 <mem_init+0x13b>
	assert(check_va2pa(kern_pgdir, PGSIZE) == ~0);
f0101a03:	a1 48 0e 11 f0       	mov    0xf0110e48,%eax
f0101a08:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101a0d:	e8 d8 ee ff ff       	call   f01008ea <check_va2pa>
f0101a12:	40                   	inc    %eax
f0101a13:	74 14                	je     f0101a29 <mem_init+0xbb4>
f0101a15:	68 c9 3e 10 f0       	push   $0xf0103ec9
f0101a1a:	68 53 37 10 f0       	push   $0xf0103753
f0101a1f:	68 60 03 00 00       	push   $0x360
f0101a24:	e9 87 f5 ff ff       	jmp    f0100fb0 <mem_init+0x13b>
	assert(pp1->pp_ref == 0);
f0101a29:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f0101a2e:	74 14                	je     f0101a44 <mem_init+0xbcf>
f0101a30:	68 ef 3e 10 f0       	push   $0xf0103eef
f0101a35:	68 53 37 10 f0       	push   $0xf0103753
f0101a3a:	68 61 03 00 00       	push   $0x361
f0101a3f:	e9 6c f5 ff ff       	jmp    f0100fb0 <mem_init+0x13b>
	assert(pp2->pp_ref == 0);
f0101a44:	66 83 7d 04 00       	cmpw   $0x0,0x4(%ebp)
f0101a49:	74 14                	je     f0101a5f <mem_init+0xbea>
f0101a4b:	68 1d 3e 10 f0       	push   $0xf0103e1d
f0101a50:	68 53 37 10 f0       	push   $0xf0103753
f0101a55:	68 62 03 00 00       	push   $0x362
f0101a5a:	e9 51 f5 ff ff       	jmp    f0100fb0 <mem_init+0x13b>

	// so it should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp1);
f0101a5f:	83 ec 0c             	sub    $0xc,%esp
f0101a62:	6a 00                	push   $0x0
f0101a64:	e8 c7 f1 ff ff       	call   f0100c30 <page_alloc>
f0101a69:	83 c4 10             	add    $0x10,%esp
f0101a6c:	85 c0                	test   %eax,%eax
f0101a6e:	89 c7                	mov    %eax,%edi
f0101a70:	74 04                	je     f0101a76 <mem_init+0xc01>
f0101a72:	39 d8                	cmp    %ebx,%eax
f0101a74:	74 14                	je     f0101a8a <mem_init+0xc15>
f0101a76:	68 00 3f 10 f0       	push   $0xf0103f00
f0101a7b:	68 53 37 10 f0       	push   $0xf0103753
f0101a80:	68 65 03 00 00       	push   $0x365
f0101a85:	e9 26 f5 ff ff       	jmp    f0100fb0 <mem_init+0x13b>

	// should be no free memory
	assert(!page_alloc(0));
f0101a8a:	83 ec 0c             	sub    $0xc,%esp
f0101a8d:	6a 00                	push   $0x0
f0101a8f:	e8 9c f1 ff ff       	call   f0100c30 <page_alloc>
f0101a94:	83 c4 10             	add    $0x10,%esp
f0101a97:	85 c0                	test   %eax,%eax
f0101a99:	74 14                	je     f0101aaf <mem_init+0xc3a>
f0101a9b:	68 20 3a 10 f0       	push   $0xf0103a20
f0101aa0:	68 53 37 10 f0       	push   $0xf0103753
f0101aa5:	68 68 03 00 00       	push   $0x368
f0101aaa:	e9 01 f5 ff ff       	jmp    f0100fb0 <mem_init+0x13b>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0101aaf:	8b 1d 48 0e 11 f0    	mov    0xf0110e48,%ebx
f0101ab5:	89 f0                	mov    %esi,%eax
f0101ab7:	e8 a4 ed ff ff       	call   f0100860 <page2pa>
f0101abc:	8b 13                	mov    (%ebx),%edx
f0101abe:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0101ac4:	39 c2                	cmp    %eax,%edx
f0101ac6:	74 14                	je     f0101adc <mem_init+0xc67>
f0101ac8:	68 21 3b 10 f0       	push   $0xf0103b21
f0101acd:	68 53 37 10 f0       	push   $0xf0103753
f0101ad2:	68 6b 03 00 00       	push   $0x36b
f0101ad7:	e9 d4 f4 ff ff       	jmp    f0100fb0 <mem_init+0x13b>
	kern_pgdir[0] = 0;
	assert(pp0->pp_ref == 1);
f0101adc:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
	// should be no free memory
	assert(!page_alloc(0));

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
	kern_pgdir[0] = 0;
f0101ae1:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	assert(pp0->pp_ref == 1);
f0101ae7:	74 14                	je     f0101afd <mem_init+0xc88>
f0101ae9:	68 87 3b 10 f0       	push   $0xf0103b87
f0101aee:	68 53 37 10 f0       	push   $0xf0103753
f0101af3:	68 6d 03 00 00       	push   $0x36d
f0101af8:	e9 b3 f4 ff ff       	jmp    f0100fb0 <mem_init+0x13b>
	pp0->pp_ref = 0;

	// check pointer arithmetic in pgdir_walk
	page_free(pp0);
f0101afd:	83 ec 0c             	sub    $0xc,%esp

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
	kern_pgdir[0] = 0;
	assert(pp0->pp_ref == 1);
	pp0->pp_ref = 0;
f0101b00:	66 c7 46 04 00 00    	movw   $0x0,0x4(%esi)

	// check pointer arithmetic in pgdir_walk
	page_free(pp0);
f0101b06:	56                   	push   %esi
f0101b07:	e8 65 f1 ff ff       	call   f0100c71 <page_free>
	va = (void*)(PGSIZE * NPDENTRIES + PGSIZE);
	ptep = pgdir_walk(kern_pgdir, va, 1);
f0101b0c:	83 c4 0c             	add    $0xc,%esp
f0101b0f:	6a 01                	push   $0x1
f0101b11:	68 00 10 40 00       	push   $0x401000
f0101b16:	ff 35 48 0e 11 f0    	pushl  0xf0110e48
f0101b1c:	e8 a9 f1 ff ff       	call   f0100cca <pgdir_walk>
	ptep1 = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(va)]));
f0101b21:	ba 74 03 00 00       	mov    $0x374,%edx
	pp0->pp_ref = 0;

	// check pointer arithmetic in pgdir_walk
	page_free(pp0);
	va = (void*)(PGSIZE * NPDENTRIES + PGSIZE);
	ptep = pgdir_walk(kern_pgdir, va, 1);
f0101b26:	89 44 24 2c          	mov    %eax,0x2c(%esp)
	ptep1 = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(va)]));
f0101b2a:	a1 48 0e 11 f0       	mov    0xf0110e48,%eax
f0101b2f:	8b 48 04             	mov    0x4(%eax),%ecx
f0101b32:	b8 16 37 10 f0       	mov    $0xf0103716,%eax
f0101b37:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
f0101b3d:	e8 66 ed ff ff       	call   f01008a8 <_kaddr>
	assert(ptep == ptep1 + PTX(va));
f0101b42:	83 c4 10             	add    $0x10,%esp
f0101b45:	83 c0 04             	add    $0x4,%eax
f0101b48:	39 44 24 1c          	cmp    %eax,0x1c(%esp)
f0101b4c:	74 14                	je     f0101b62 <mem_init+0xced>
f0101b4e:	68 22 3f 10 f0       	push   $0xf0103f22
f0101b53:	68 53 37 10 f0       	push   $0xf0103753
f0101b58:	68 75 03 00 00       	push   $0x375
f0101b5d:	e9 4e f4 ff ff       	jmp    f0100fb0 <mem_init+0x13b>
	kern_pgdir[PDX(va)] = 0;
f0101b62:	a1 48 0e 11 f0       	mov    0xf0110e48,%eax
f0101b67:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
	pp0->pp_ref = 0;

	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
f0101b6e:	89 f0                	mov    %esi,%eax
	va = (void*)(PGSIZE * NPDENTRIES + PGSIZE);
	ptep = pgdir_walk(kern_pgdir, va, 1);
	ptep1 = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(va)]));
	assert(ptep == ptep1 + PTX(va));
	kern_pgdir[PDX(va)] = 0;
	pp0->pp_ref = 0;
f0101b70:	66 c7 46 04 00 00    	movw   $0x0,0x4(%esi)

	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
f0101b76:	e8 56 ed ff ff       	call   f01008d1 <page2kva>
f0101b7b:	52                   	push   %edx
f0101b7c:	68 00 10 00 00       	push   $0x1000
f0101b81:	68 ff 00 00 00       	push   $0xff
f0101b86:	50                   	push   %eax
f0101b87:	e8 23 11 00 00       	call   f0102caf <memset>
	page_free(pp0);
f0101b8c:	89 34 24             	mov    %esi,(%esp)
f0101b8f:	e8 dd f0 ff ff       	call   f0100c71 <page_free>
	pgdir_walk(kern_pgdir, 0x0, 1);
f0101b94:	83 c4 0c             	add    $0xc,%esp
f0101b97:	6a 01                	push   $0x1
f0101b99:	6a 00                	push   $0x0
f0101b9b:	ff 35 48 0e 11 f0    	pushl  0xf0110e48
f0101ba1:	e8 24 f1 ff ff       	call   f0100cca <pgdir_walk>
	ptep = (pte_t *) page2kva(pp0);
f0101ba6:	89 f0                	mov    %esi,%eax
f0101ba8:	e8 24 ed ff ff       	call   f01008d1 <page2kva>
	for(i=0; i<NPTENTRIES; i++)
f0101bad:	31 d2                	xor    %edx,%edx

	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
	page_free(pp0);
	pgdir_walk(kern_pgdir, 0x0, 1);
	ptep = (pte_t *) page2kva(pp0);
f0101baf:	89 44 24 2c          	mov    %eax,0x2c(%esp)
f0101bb3:	83 c4 10             	add    $0x10,%esp
	for(i=0; i<NPTENTRIES; i++)
		assert((ptep[i] & PTE_P) == 0);
f0101bb6:	f6 04 90 01          	testb  $0x1,(%eax,%edx,4)
f0101bba:	74 14                	je     f0101bd0 <mem_init+0xd5b>
f0101bbc:	68 3a 3f 10 f0       	push   $0xf0103f3a
f0101bc1:	68 53 37 10 f0       	push   $0xf0103753
f0101bc6:	68 7f 03 00 00       	push   $0x37f
f0101bcb:	e9 e0 f3 ff ff       	jmp    f0100fb0 <mem_init+0x13b>
	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
	page_free(pp0);
	pgdir_walk(kern_pgdir, 0x0, 1);
	ptep = (pte_t *) page2kva(pp0);
	for(i=0; i<NPTENTRIES; i++)
f0101bd0:	42                   	inc    %edx
f0101bd1:	81 fa 00 04 00 00    	cmp    $0x400,%edx
f0101bd7:	75 dd                	jne    f0101bb6 <mem_init+0xd41>
		assert((ptep[i] & PTE_P) == 0);
	kern_pgdir[0] = 0;
f0101bd9:	a1 48 0e 11 f0       	mov    0xf0110e48,%eax
f0101bde:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	pp0->pp_ref = 0;

	// give free list back
	page_free_list = fl;
f0101be4:	8b 44 24 08          	mov    0x8(%esp),%eax

	// free the pages we took
	page_free(pp0);
f0101be8:	83 ec 0c             	sub    $0xc,%esp
	pgdir_walk(kern_pgdir, 0x0, 1);
	ptep = (pte_t *) page2kva(pp0);
	for(i=0; i<NPTENTRIES; i++)
		assert((ptep[i] & PTE_P) == 0);
	kern_pgdir[0] = 0;
	pp0->pp_ref = 0;
f0101beb:	66 c7 46 04 00 00    	movw   $0x0,0x4(%esi)

	// give free list back
	page_free_list = fl;

	// free the pages we took
	page_free(pp0);
f0101bf1:	56                   	push   %esi
		assert((ptep[i] & PTE_P) == 0);
	kern_pgdir[0] = 0;
	pp0->pp_ref = 0;

	// give free list back
	page_free_list = fl;
f0101bf2:	a3 1c 02 11 f0       	mov    %eax,0xf011021c

	// free the pages we took
	page_free(pp0);
f0101bf7:	e8 75 f0 ff ff       	call   f0100c71 <page_free>
	page_free(pp1);
f0101bfc:	89 3c 24             	mov    %edi,(%esp)
f0101bff:	e8 6d f0 ff ff       	call   f0100c71 <page_free>
	page_free(pp2);
f0101c04:	89 2c 24             	mov    %ebp,(%esp)
f0101c07:	e8 65 f0 ff ff       	call   f0100c71 <page_free>

	cprintf("check_page() succeeded!\n");
f0101c0c:	c7 04 24 51 3f 10 f0 	movl   $0xf0103f51,(%esp)
f0101c13:	e8 2e ec ff ff       	call   f0100846 <cprintf>
	// Permissions:
	//    - the new image at UPAGES -- kernel R, user R
	//      (ie. perm = PTE_U | PTE_P)
	//    - pages itself -- kernel RW, user NONE
	// Your code goes here:
    boot_map_region(kern_pgdir, UPAGES, ROUNDUP((sizeof(struct PageInfo) * npages), PGSIZE), PADDR(pages), (PTE_U | PTE_P));
f0101c18:	8b 15 4c 0e 11 f0    	mov    0xf0110e4c,%edx
f0101c1e:	b8 b0 00 00 00       	mov    $0xb0,%eax
f0101c23:	e8 46 ef ff ff       	call   f0100b6e <_paddr.clone.0>
f0101c28:	8b 15 44 0e 11 f0    	mov    0xf0110e44,%edx
f0101c2e:	5e                   	pop    %esi
	pde_t *pgdir;

	pgdir = kern_pgdir;

    // check IO mem
    for (i = IOPHYSMEM; i < ROUNDUP(EXTPHYSMEM, PGSIZE); i += PGSIZE)
f0101c2f:	be 00 00 0a 00       	mov    $0xa0000,%esi
	// Permissions:
	//    - the new image at UPAGES -- kernel R, user R
	//      (ie. perm = PTE_U | PTE_P)
	//    - pages itself -- kernel RW, user NONE
	// Your code goes here:
    boot_map_region(kern_pgdir, UPAGES, ROUNDUP((sizeof(struct PageInfo) * npages), PGSIZE), PADDR(pages), (PTE_U | PTE_P));
f0101c34:	5f                   	pop    %edi
f0101c35:	8d 0c d5 ff 0f 00 00 	lea    0xfff(,%edx,8),%ecx
f0101c3c:	ba 00 00 00 ef       	mov    $0xef000000,%edx
f0101c41:	6a 05                	push   $0x5
f0101c43:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
f0101c49:	50                   	push   %eax
f0101c4a:	a1 48 0e 11 f0       	mov    0xf0110e48,%eax
f0101c4f:	e8 e3 f0 ff ff       	call   f0100d37 <boot_map_region>
	//       the kernel overflows its stack, it will fault rather than
	//       overwrite memory.  Known as a "guard page".
	//     Permissions: kernel RW, user NONE
	// Your code goes here:
    /* TODO */
    boot_map_region(kern_pgdir,KSTACKTOP - KSTKSIZE,KSTKSIZE,PADDR(bootstack),PTE_W);
f0101c54:	ba 00 80 10 f0       	mov    $0xf0108000,%edx
f0101c59:	b8 bf 00 00 00       	mov    $0xbf,%eax
f0101c5e:	e8 0b ef ff ff       	call   f0100b6e <_paddr.clone.0>
f0101c63:	ba 00 80 ff ef       	mov    $0xefff8000,%edx
f0101c68:	59                   	pop    %ecx
f0101c69:	b9 00 80 00 00       	mov    $0x8000,%ecx
f0101c6e:	5b                   	pop    %ebx
f0101c6f:	6a 02                	push   $0x2
f0101c71:	50                   	push   %eax
f0101c72:	a1 48 0e 11 f0       	mov    0xf0110e48,%eax
f0101c77:	e8 bb f0 ff ff       	call   f0100d37 <boot_map_region>
	// We might not have 2^32 - KERNBASE bytes of physical memory, but
	// we just set up the mapping anyway.
	// Permissions: kernel RW, user NONE
	// Your code goes here:
    /* TODO */
    boot_map_region(kern_pgdir,KERNBASE,0xffffffff-KERNBASE,0,PTE_W);
f0101c7c:	b9 ff ff ff 0f       	mov    $0xfffffff,%ecx
f0101c81:	58                   	pop    %eax
f0101c82:	5a                   	pop    %edx
f0101c83:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
f0101c88:	a1 48 0e 11 f0       	mov    0xf0110e48,%eax
f0101c8d:	6a 02                	push   $0x2
f0101c8f:	6a 00                	push   $0x0
f0101c91:	e8 a1 f0 ff ff       	call   f0100d37 <boot_map_region>
	//////////////////////////////////////////////////////////////////////
	// Map VA range [IOPHYSMEM, EXTPHYSMEM) to PA range [IOPHYSMEM, EXTPHYSMEM)
    boot_map_region(kern_pgdir, IOPHYSMEM, ROUNDUP((EXTPHYSMEM - IOPHYSMEM), PGSIZE), IOPHYSMEM, (PTE_W) | (PTE_P));
f0101c96:	a1 48 0e 11 f0       	mov    0xf0110e48,%eax
f0101c9b:	b9 00 00 06 00       	mov    $0x60000,%ecx
f0101ca0:	5f                   	pop    %edi
f0101ca1:	ba 00 00 0a 00       	mov    $0xa0000,%edx
f0101ca6:	5d                   	pop    %ebp
f0101ca7:	6a 03                	push   $0x3
f0101ca9:	68 00 00 0a 00       	push   $0xa0000
f0101cae:	e8 84 f0 ff ff       	call   f0100d37 <boot_map_region>
check_kern_pgdir(void)
{
	uint32_t i, n;
	pde_t *pgdir;

	pgdir = kern_pgdir;
f0101cb3:	8b 1d 48 0e 11 f0    	mov    0xf0110e48,%ebx
f0101cb9:	83 c4 10             	add    $0x10,%esp

    // check IO mem
    for (i = IOPHYSMEM; i < ROUNDUP(EXTPHYSMEM, PGSIZE); i += PGSIZE)
		assert(check_va2pa(pgdir, i) == i);
f0101cbc:	89 f2                	mov    %esi,%edx
f0101cbe:	89 d8                	mov    %ebx,%eax
f0101cc0:	e8 25 ec ff ff       	call   f01008ea <check_va2pa>
f0101cc5:	39 f0                	cmp    %esi,%eax
f0101cc7:	74 14                	je     f0101cdd <mem_init+0xe68>
f0101cc9:	68 6a 3f 10 f0       	push   $0xf0103f6a
f0101cce:	68 53 37 10 f0       	push   $0xf0103753
f0101cd3:	68 bc 02 00 00       	push   $0x2bc
f0101cd8:	e9 d3 f2 ff ff       	jmp    f0100fb0 <mem_init+0x13b>
	pde_t *pgdir;

	pgdir = kern_pgdir;

    // check IO mem
    for (i = IOPHYSMEM; i < ROUNDUP(EXTPHYSMEM, PGSIZE); i += PGSIZE)
f0101cdd:	81 c6 00 10 00 00    	add    $0x1000,%esi
f0101ce3:	81 fe 00 00 10 00    	cmp    $0x100000,%esi
f0101ce9:	75 d1                	jne    f0101cbc <mem_init+0xe47>
		assert(check_va2pa(pgdir, i) == i);

	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
f0101ceb:	a1 44 0e 11 f0       	mov    0xf0110e44,%eax
	for (i = 0; i < n; i += PGSIZE)
f0101cf0:	31 f6                	xor    %esi,%esi
    // check IO mem
    for (i = IOPHYSMEM; i < ROUNDUP(EXTPHYSMEM, PGSIZE); i += PGSIZE)
		assert(check_va2pa(pgdir, i) == i);

	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
f0101cf2:	8d 3c c5 ff 0f 00 00 	lea    0xfff(,%eax,8),%edi
f0101cf9:	81 e7 00 f0 ff ff    	and    $0xfffff000,%edi
f0101cff:	eb 3f                	jmp    f0101d40 <mem_init+0xecb>
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f0101d01:	8d 96 00 00 00 ef    	lea    -0x11000000(%esi),%edx
f0101d07:	89 d8                	mov    %ebx,%eax
f0101d09:	e8 dc eb ff ff       	call   f01008ea <check_va2pa>
f0101d0e:	8b 15 4c 0e 11 f0    	mov    0xf0110e4c,%edx
f0101d14:	89 c5                	mov    %eax,%ebp
f0101d16:	b8 c1 02 00 00       	mov    $0x2c1,%eax
f0101d1b:	e8 4e ee ff ff       	call   f0100b6e <_paddr.clone.0>
f0101d20:	01 f0                	add    %esi,%eax
f0101d22:	39 c5                	cmp    %eax,%ebp
f0101d24:	74 14                	je     f0101d3a <mem_init+0xec5>
f0101d26:	68 85 3f 10 f0       	push   $0xf0103f85
f0101d2b:	68 53 37 10 f0       	push   $0xf0103753
f0101d30:	68 c1 02 00 00       	push   $0x2c1
f0101d35:	e9 76 f2 ff ff       	jmp    f0100fb0 <mem_init+0x13b>
    for (i = IOPHYSMEM; i < ROUNDUP(EXTPHYSMEM, PGSIZE); i += PGSIZE)
		assert(check_va2pa(pgdir, i) == i);

	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
f0101d3a:	81 c6 00 10 00 00    	add    $0x1000,%esi
f0101d40:	39 fe                	cmp    %edi,%esi
f0101d42:	72 bd                	jb     f0101d01 <mem_init+0xe8c>
f0101d44:	31 f6                	xor    %esi,%esi
f0101d46:	eb 2b                	jmp    f0101d73 <mem_init+0xefe>
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
    
	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KERNBASE + i) == i);
f0101d48:	8d 96 00 00 00 f0    	lea    -0x10000000(%esi),%edx
f0101d4e:	89 d8                	mov    %ebx,%eax
f0101d50:	e8 95 eb ff ff       	call   f01008ea <check_va2pa>
f0101d55:	39 f0                	cmp    %esi,%eax
f0101d57:	74 14                	je     f0101d6d <mem_init+0xef8>
f0101d59:	68 b8 3f 10 f0       	push   $0xf0103fb8
f0101d5e:	68 53 37 10 f0       	push   $0xf0103753
f0101d63:	68 c5 02 00 00       	push   $0x2c5
f0101d68:	e9 43 f2 ff ff       	jmp    f0100fb0 <mem_init+0x13b>
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
    
	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f0101d6d:	81 c6 00 10 00 00    	add    $0x1000,%esi
f0101d73:	a1 44 0e 11 f0       	mov    0xf0110e44,%eax
f0101d78:	c1 e0 0c             	shl    $0xc,%eax
f0101d7b:	39 c6                	cmp    %eax,%esi
f0101d7d:	72 c9                	jb     f0101d48 <mem_init+0xed3>
f0101d7f:	31 f6                	xor    %esi,%esi
		assert(check_va2pa(pgdir, KERNBASE + i) == i);

	// check kernel stack
	for (i = 0; i < KSTKSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
f0101d81:	8d 96 00 80 ff ef    	lea    -0x10008000(%esi),%edx
f0101d87:	89 d8                	mov    %ebx,%eax
f0101d89:	e8 5c eb ff ff       	call   f01008ea <check_va2pa>
f0101d8e:	ba 00 80 10 f0       	mov    $0xf0108000,%edx
f0101d93:	89 c7                	mov    %eax,%edi
f0101d95:	b8 c9 02 00 00       	mov    $0x2c9,%eax
f0101d9a:	e8 cf ed ff ff       	call   f0100b6e <_paddr.clone.0>
f0101d9f:	8d 04 06             	lea    (%esi,%eax,1),%eax
f0101da2:	39 c7                	cmp    %eax,%edi
f0101da4:	74 14                	je     f0101dba <mem_init+0xf45>
f0101da6:	68 de 3f 10 f0       	push   $0xf0103fde
f0101dab:	68 53 37 10 f0       	push   $0xf0103753
f0101db0:	68 c9 02 00 00       	push   $0x2c9
f0101db5:	e9 f6 f1 ff ff       	jmp    f0100fb0 <mem_init+0x13b>
	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KERNBASE + i) == i);

	// check kernel stack
	for (i = 0; i < KSTKSIZE; i += PGSIZE)
f0101dba:	81 c6 00 10 00 00    	add    $0x1000,%esi
f0101dc0:	81 fe 00 80 00 00    	cmp    $0x8000,%esi
f0101dc6:	75 b9                	jne    f0101d81 <mem_init+0xf0c>
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
	assert(check_va2pa(pgdir, KSTACKTOP - PTSIZE) == ~0);
f0101dc8:	ba 00 00 c0 ef       	mov    $0xefc00000,%edx
f0101dcd:	89 d8                	mov    %ebx,%eax
f0101dcf:	e8 16 eb ff ff       	call   f01008ea <check_va2pa>
f0101dd4:	31 d2                	xor    %edx,%edx
f0101dd6:	40                   	inc    %eax
f0101dd7:	74 14                	je     f0101ded <mem_init+0xf78>
f0101dd9:	68 23 40 10 f0       	push   $0xf0104023
f0101dde:	68 53 37 10 f0       	push   $0xf0103753
f0101de3:	68 ca 02 00 00       	push   $0x2ca
f0101de8:	e9 c3 f1 ff ff       	jmp    f0100fb0 <mem_init+0x13b>

	// check PDE permissions
	for (i = 0; i < NPDENTRIES; i++) {
		switch (i) {
f0101ded:	81 fa bd 03 00 00    	cmp    $0x3bd,%edx
f0101df3:	77 0c                	ja     f0101e01 <mem_init+0xf8c>
f0101df5:	81 fa bc 03 00 00    	cmp    $0x3bc,%edx
f0101dfb:	73 0c                	jae    f0101e09 <mem_init+0xf94>
f0101dfd:	85 d2                	test   %edx,%edx
f0101dff:	eb 06                	jmp    f0101e07 <mem_init+0xf92>
f0101e01:	81 fa bf 03 00 00    	cmp    $0x3bf,%edx
f0101e07:	75 1a                	jne    f0101e23 <mem_init+0xfae>
        case PDX(IOPHYSMEM):
		case PDX(UVPT):
		case PDX(KSTACKTOP-1):
		case PDX(UPAGES):
			assert(pgdir[i] & PTE_P);
f0101e09:	f6 04 93 01          	testb  $0x1,(%ebx,%edx,4)
f0101e0d:	75 69                	jne    f0101e78 <mem_init+0x1003>
f0101e0f:	68 50 40 10 f0       	push   $0xf0104050
f0101e14:	68 53 37 10 f0       	push   $0xf0103753
f0101e19:	68 d3 02 00 00       	push   $0x2d3
f0101e1e:	e9 8d f1 ff ff       	jmp    f0100fb0 <mem_init+0x13b>
			break;
		default:
			if (i >= PDX(KERNBASE)) {
f0101e23:	81 fa bf 03 00 00    	cmp    $0x3bf,%edx
f0101e29:	76 33                	jbe    f0101e5e <mem_init+0xfe9>
				assert(pgdir[i] & PTE_P);
f0101e2b:	8b 04 93             	mov    (%ebx,%edx,4),%eax
f0101e2e:	a8 01                	test   $0x1,%al
f0101e30:	75 14                	jne    f0101e46 <mem_init+0xfd1>
f0101e32:	68 50 40 10 f0       	push   $0xf0104050
f0101e37:	68 53 37 10 f0       	push   $0xf0103753
f0101e3c:	68 d7 02 00 00       	push   $0x2d7
f0101e41:	e9 6a f1 ff ff       	jmp    f0100fb0 <mem_init+0x13b>
				assert(pgdir[i] & PTE_W);
f0101e46:	a8 02                	test   $0x2,%al
f0101e48:	75 2e                	jne    f0101e78 <mem_init+0x1003>
f0101e4a:	68 61 40 10 f0       	push   $0xf0104061
f0101e4f:	68 53 37 10 f0       	push   $0xf0103753
f0101e54:	68 d8 02 00 00       	push   $0x2d8
f0101e59:	e9 52 f1 ff ff       	jmp    f0100fb0 <mem_init+0x13b>
			} else
				assert(pgdir[i] == 0);
f0101e5e:	83 3c 93 00          	cmpl   $0x0,(%ebx,%edx,4)
f0101e62:	74 14                	je     f0101e78 <mem_init+0x1003>
f0101e64:	68 72 40 10 f0       	push   $0xf0104072
f0101e69:	68 53 37 10 f0       	push   $0xf0103753
f0101e6e:	68 da 02 00 00       	push   $0x2da
f0101e73:	e9 38 f1 ff ff       	jmp    f0100fb0 <mem_init+0x13b>
	for (i = 0; i < KSTKSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
	assert(check_va2pa(pgdir, KSTACKTOP - PTSIZE) == ~0);

	// check PDE permissions
	for (i = 0; i < NPDENTRIES; i++) {
f0101e78:	42                   	inc    %edx
f0101e79:	81 fa 00 04 00 00    	cmp    $0x400,%edx
f0101e7f:	0f 85 68 ff ff ff    	jne    f0101ded <mem_init+0xf78>
			} else
				assert(pgdir[i] == 0);
			break;
		}
	}
	cprintf("check_kern_pgdir() succeeded!\n");
f0101e85:	83 ec 0c             	sub    $0xc,%esp
f0101e88:	68 80 40 10 f0       	push   $0xf0104080
f0101e8d:	e8 b4 e9 ff ff       	call   f0100846 <cprintf>
	// somewhere between KERNBASE and KERNBASE+4MB right now, which is
	// mapped the same way by both page tables.
	//
	// If the machine reboots at this point, you've probably set up your
	// kern_pgdir wrong.
	lcr3(PADDR(kern_pgdir));
f0101e92:	8b 15 48 0e 11 f0    	mov    0xf0110e48,%edx
f0101e98:	b8 d8 00 00 00       	mov    $0xd8,%eax
f0101e9d:	e8 cc ec ff ff       	call   f0100b6e <_paddr.clone.0>
}

static __inline void
lcr3(uint32_t val)
{
	__asm __volatile("movl %0,%%cr3" : : "r" (val));
f0101ea2:	0f 22 d8             	mov    %eax,%cr3

	check_page_free_list(0);
f0101ea5:	31 c0                	xor    %eax,%eax
f0101ea7:	e8 89 ea ff ff       	call   f0100935 <check_page_free_list>

static __inline uint32_t
rcr0(void)
{
	uint32_t val;
	__asm __volatile("movl %%cr0,%0" : "=r" (val));
f0101eac:	0f 20 c0             	mov    %cr0,%eax

	// entry.S set the really important flags in cr0 (including enabling
	// paging).  Here we configure the rest of the flags that we care about.
	cr0 = rcr0();
	cr0 |= CR0_PE|CR0_PG|CR0_AM|CR0_WP|CR0_NE|CR0_MP;
f0101eaf:	0d 23 00 05 80       	or     $0x80050023,%eax
	cr0 &= ~(CR0_TS|CR0_EM);
f0101eb4:	83 e0 f3             	and    $0xfffffff3,%eax
}

static __inline void
lcr0(uint32_t val)
{
	__asm __volatile("movl %0,%%cr0" : : "r" (val));
f0101eb7:	0f 22 c0             	mov    %eax,%cr0
	uintptr_t va;
	int i;

	// check that we can read and write installed pages
	pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0101eba:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101ec1:	e8 6a ed ff ff       	call   f0100c30 <page_alloc>
f0101ec6:	83 c4 10             	add    $0x10,%esp
f0101ec9:	85 c0                	test   %eax,%eax
f0101ecb:	89 c7                	mov    %eax,%edi
f0101ecd:	75 14                	jne    f0101ee3 <mem_init+0x106e>
f0101ecf:	68 55 39 10 f0       	push   $0xf0103955
f0101ed4:	68 53 37 10 f0       	push   $0xf0103753
f0101ed9:	68 9a 03 00 00       	push   $0x39a
f0101ede:	e9 cd f0 ff ff       	jmp    f0100fb0 <mem_init+0x13b>
	assert((pp1 = page_alloc(0)));
f0101ee3:	83 ec 0c             	sub    $0xc,%esp
f0101ee6:	6a 00                	push   $0x0
f0101ee8:	e8 43 ed ff ff       	call   f0100c30 <page_alloc>
f0101eed:	83 c4 10             	add    $0x10,%esp
f0101ef0:	85 c0                	test   %eax,%eax
f0101ef2:	89 c6                	mov    %eax,%esi
f0101ef4:	75 14                	jne    f0101f0a <mem_init+0x1095>
f0101ef6:	68 6b 39 10 f0       	push   $0xf010396b
f0101efb:	68 53 37 10 f0       	push   $0xf0103753
f0101f00:	68 9b 03 00 00       	push   $0x39b
f0101f05:	e9 a6 f0 ff ff       	jmp    f0100fb0 <mem_init+0x13b>
	assert((pp2 = page_alloc(0)));
f0101f0a:	83 ec 0c             	sub    $0xc,%esp
f0101f0d:	6a 00                	push   $0x0
f0101f0f:	e8 1c ed ff ff       	call   f0100c30 <page_alloc>
f0101f14:	83 c4 10             	add    $0x10,%esp
f0101f17:	85 c0                	test   %eax,%eax
f0101f19:	89 c3                	mov    %eax,%ebx
f0101f1b:	75 14                	jne    f0101f31 <mem_init+0x10bc>
f0101f1d:	68 81 39 10 f0       	push   $0xf0103981
f0101f22:	68 53 37 10 f0       	push   $0xf0103753
f0101f27:	68 9c 03 00 00       	push   $0x39c
f0101f2c:	e9 7f f0 ff ff       	jmp    f0100fb0 <mem_init+0x13b>
	page_free(pp0);
f0101f31:	83 ec 0c             	sub    $0xc,%esp
f0101f34:	57                   	push   %edi
f0101f35:	e8 37 ed ff ff       	call   f0100c71 <page_free>
	memset(page2kva(pp1), 1, PGSIZE);
f0101f3a:	89 f0                	mov    %esi,%eax
f0101f3c:	e8 90 e9 ff ff       	call   f01008d1 <page2kva>
f0101f41:	83 c4 0c             	add    $0xc,%esp
f0101f44:	68 00 10 00 00       	push   $0x1000
f0101f49:	6a 01                	push   $0x1
f0101f4b:	50                   	push   %eax
f0101f4c:	e8 5e 0d 00 00       	call   f0102caf <memset>
	memset(page2kva(pp2), 2, PGSIZE);
f0101f51:	89 d8                	mov    %ebx,%eax
f0101f53:	e8 79 e9 ff ff       	call   f01008d1 <page2kva>
f0101f58:	83 c4 0c             	add    $0xc,%esp
f0101f5b:	68 00 10 00 00       	push   $0x1000
f0101f60:	6a 02                	push   $0x2
f0101f62:	50                   	push   %eax
f0101f63:	e8 47 0d 00 00       	call   f0102caf <memset>
	page_insert(kern_pgdir, pp1, (void*) EXTPHYSMEM, PTE_W);
f0101f68:	6a 02                	push   $0x2
f0101f6a:	68 00 00 10 00       	push   $0x100000
f0101f6f:	56                   	push   %esi
f0101f70:	ff 35 48 0e 11 f0    	pushl  0xf0110e48
f0101f76:	e8 9f ee ff ff       	call   f0100e1a <page_insert>
	assert(pp1->pp_ref == 1);
f0101f7b:	83 c4 20             	add    $0x20,%esp
f0101f7e:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0101f83:	74 14                	je     f0101f99 <mem_init+0x1124>
f0101f85:	68 76 3b 10 f0       	push   $0xf0103b76
f0101f8a:	68 53 37 10 f0       	push   $0xf0103753
f0101f8f:	68 a1 03 00 00       	push   $0x3a1
f0101f94:	e9 17 f0 ff ff       	jmp    f0100fb0 <mem_init+0x13b>
	assert(*(uint32_t *)EXTPHYSMEM == 0x01010101U);
f0101f99:	81 3d 00 00 10 00 01 	cmpl   $0x1010101,0x100000
f0101fa0:	01 01 01 
f0101fa3:	74 14                	je     f0101fb9 <mem_init+0x1144>
f0101fa5:	68 9f 40 10 f0       	push   $0xf010409f
f0101faa:	68 53 37 10 f0       	push   $0xf0103753
f0101faf:	68 a2 03 00 00       	push   $0x3a2
f0101fb4:	e9 f7 ef ff ff       	jmp    f0100fb0 <mem_init+0x13b>
	page_insert(kern_pgdir, pp2, (void*) EXTPHYSMEM, PTE_W);
f0101fb9:	6a 02                	push   $0x2
f0101fbb:	68 00 00 10 00       	push   $0x100000
f0101fc0:	53                   	push   %ebx
f0101fc1:	ff 35 48 0e 11 f0    	pushl  0xf0110e48
f0101fc7:	e8 4e ee ff ff       	call   f0100e1a <page_insert>
	assert(*(uint32_t *)EXTPHYSMEM == 0x02020202U);
f0101fcc:	83 c4 10             	add    $0x10,%esp
f0101fcf:	81 3d 00 00 10 00 02 	cmpl   $0x2020202,0x100000
f0101fd6:	02 02 02 
f0101fd9:	74 14                	je     f0101fef <mem_init+0x117a>
f0101fdb:	68 c6 40 10 f0       	push   $0xf01040c6
f0101fe0:	68 53 37 10 f0       	push   $0xf0103753
f0101fe5:	68 a4 03 00 00       	push   $0x3a4
f0101fea:	e9 c1 ef ff ff       	jmp    f0100fb0 <mem_init+0x13b>
	assert(pp2->pp_ref == 1);
f0101fef:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0101ff4:	74 14                	je     f010200a <mem_init+0x1195>
f0101ff6:	68 01 3c 10 f0       	push   $0xf0103c01
f0101ffb:	68 53 37 10 f0       	push   $0xf0103753
f0102000:	68 a5 03 00 00       	push   $0x3a5
f0102005:	e9 a6 ef ff ff       	jmp    f0100fb0 <mem_init+0x13b>
	assert(pp1->pp_ref == 0);
f010200a:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f010200f:	74 14                	je     f0102025 <mem_init+0x11b0>
f0102011:	68 ef 3e 10 f0       	push   $0xf0103eef
f0102016:	68 53 37 10 f0       	push   $0xf0103753
f010201b:	68 a6 03 00 00       	push   $0x3a6
f0102020:	e9 8b ef ff ff       	jmp    f0100fb0 <mem_init+0x13b>
	*(uint32_t *)EXTPHYSMEM = 0x03030303U;
	assert(*(uint32_t *)page2kva(pp2) == 0x03030303U);
f0102025:	89 d8                	mov    %ebx,%eax
	assert(*(uint32_t *)EXTPHYSMEM == 0x01010101U);
	page_insert(kern_pgdir, pp2, (void*) EXTPHYSMEM, PTE_W);
	assert(*(uint32_t *)EXTPHYSMEM == 0x02020202U);
	assert(pp2->pp_ref == 1);
	assert(pp1->pp_ref == 0);
	*(uint32_t *)EXTPHYSMEM = 0x03030303U;
f0102027:	c7 05 00 00 10 00 03 	movl   $0x3030303,0x100000
f010202e:	03 03 03 
	assert(*(uint32_t *)page2kva(pp2) == 0x03030303U);
f0102031:	e8 9b e8 ff ff       	call   f01008d1 <page2kva>
f0102036:	81 38 03 03 03 03    	cmpl   $0x3030303,(%eax)
f010203c:	74 14                	je     f0102052 <mem_init+0x11dd>
f010203e:	68 ed 40 10 f0       	push   $0xf01040ed
f0102043:	68 53 37 10 f0       	push   $0xf0103753
f0102048:	68 a8 03 00 00       	push   $0x3a8
f010204d:	e9 5e ef ff ff       	jmp    f0100fb0 <mem_init+0x13b>
	page_remove(kern_pgdir, (void*) EXTPHYSMEM);
f0102052:	56                   	push   %esi
f0102053:	56                   	push   %esi
f0102054:	68 00 00 10 00       	push   $0x100000
f0102059:	ff 35 48 0e 11 f0    	pushl  0xf0110e48
f010205f:	e8 7a ed ff ff       	call   f0100dde <page_remove>
	assert(pp2->pp_ref == 0);
f0102064:	83 c4 10             	add    $0x10,%esp
f0102067:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f010206c:	74 14                	je     f0102082 <mem_init+0x120d>
f010206e:	68 1d 3e 10 f0       	push   $0xf0103e1d
f0102073:	68 53 37 10 f0       	push   $0xf0103753
f0102078:	68 aa 03 00 00       	push   $0x3aa
f010207d:	e9 2e ef ff ff       	jmp    f0100fb0 <mem_init+0x13b>

	cprintf("check_page_installed_pgdir() succeeded!\n");
f0102082:	83 ec 0c             	sub    $0xc,%esp
f0102085:	68 17 41 10 f0       	push   $0xf0104117
f010208a:	e8 b7 e7 ff ff       	call   f0100846 <cprintf>
	cr0 &= ~(CR0_TS|CR0_EM);
	lcr0(cr0);

	// Some more checks, only possible after kern_pgdir is installed.
	check_page_installed_pgdir();
}
f010208f:	83 c4 3c             	add    $0x3c,%esp
f0102092:	5b                   	pop    %ebx
f0102093:	5e                   	pop    %esi
f0102094:	5f                   	pop    %edi
f0102095:	5d                   	pop    %ebp
f0102096:	c3                   	ret    

f0102097 <tlb_invalidate>:
}

static __inline void
invlpg(void *addr)
{
	__asm __volatile("invlpg (%0)" : : "r" (addr) : "memory");
f0102097:	8b 44 24 08          	mov    0x8(%esp),%eax
f010209b:	0f 01 38             	invlpg (%eax)
tlb_invalidate(pde_t *pgdir, void *va)
{
	// Flush the entry only if we're modifying the current address space.
	// For now, there is only one address space, so always invalidate.
	invlpg(va);
}
f010209e:	c3                   	ret    
	...

f01020a0 <_panic>:
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: mesg", and then enters the kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt,...)
{
f01020a0:	56                   	push   %esi
f01020a1:	53                   	push   %ebx
f01020a2:	83 ec 04             	sub    $0x4,%esp
	va_list ap;

	if (panicstr)
f01020a5:	83 3d 50 0e 11 f0 00 	cmpl   $0x0,0xf0110e50
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: mesg", and then enters the kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt,...)
{
f01020ac:	8b 5c 24 18          	mov    0x18(%esp),%ebx
	va_list ap;

	if (panicstr)
f01020b0:	75 37                	jne    f01020e9 <_panic+0x49>
		goto dead;
	panicstr = fmt;
f01020b2:	89 1d 50 0e 11 f0    	mov    %ebx,0xf0110e50

	// Be extra sure that the machine is in as reasonable state
	__asm __volatile("cli; cld");
f01020b8:	fa                   	cli    
f01020b9:	fc                   	cld    

	va_start(ap, fmt);
f01020ba:	8d 74 24 1c          	lea    0x1c(%esp),%esi
	cprintf("kernel panic at %s:%d: ", file, line);
f01020be:	51                   	push   %ecx
f01020bf:	ff 74 24 18          	pushl  0x18(%esp)
f01020c3:	ff 74 24 18          	pushl  0x18(%esp)
f01020c7:	68 40 41 10 f0       	push   $0xf0104140
f01020cc:	e8 75 e7 ff ff       	call   f0100846 <cprintf>
	vcprintf(fmt, ap);
f01020d1:	58                   	pop    %eax
f01020d2:	5a                   	pop    %edx
f01020d3:	56                   	push   %esi
f01020d4:	53                   	push   %ebx
f01020d5:	e8 42 e7 ff ff       	call   f010081c <vcprintf>
	cprintf("\n");
f01020da:	c7 04 24 7a 34 10 f0 	movl   $0xf010347a,(%esp)
f01020e1:	e8 60 e7 ff ff       	call   f0100846 <cprintf>
	va_end(ap);
f01020e6:	83 c4 10             	add    $0x10,%esp
f01020e9:	eb fe                	jmp    f01020e9 <_panic+0x49>

f01020eb <_warn>:
}

/* like panic, but don't */
void
_warn(const char *file, int line, const char *fmt,...)
{
f01020eb:	53                   	push   %ebx
f01020ec:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
f01020ef:	8d 5c 24 1c          	lea    0x1c(%esp),%ebx
	cprintf("kernel warning at %s:%d: ", file, line);
f01020f3:	51                   	push   %ecx
f01020f4:	ff 74 24 18          	pushl  0x18(%esp)
f01020f8:	ff 74 24 18          	pushl  0x18(%esp)
f01020fc:	68 58 41 10 f0       	push   $0xf0104158
f0102101:	e8 40 e7 ff ff       	call   f0100846 <cprintf>
	vcprintf(fmt, ap);
f0102106:	58                   	pop    %eax
f0102107:	5a                   	pop    %edx
f0102108:	53                   	push   %ebx
f0102109:	ff 74 24 24          	pushl  0x24(%esp)
f010210d:	e8 0a e7 ff ff       	call   f010081c <vcprintf>
	cprintf("\n");
f0102112:	c7 04 24 7a 34 10 f0 	movl   $0xf010347a,(%esp)
f0102119:	e8 28 e7 ff ff       	call   f0100846 <cprintf>
	va_end(ap);
}
f010211e:	83 c4 18             	add    $0x18,%esp
f0102121:	5b                   	pop    %ebx
f0102122:	c3                   	ret    
	...

f0102124 <mc146818_read>:
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0102124:	8b 44 24 04          	mov    0x4(%esp),%eax
f0102128:	ba 70 00 00 00       	mov    $0x70,%edx
f010212d:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010212e:	b2 71                	mov    $0x71,%dl
f0102130:	ec                   	in     (%dx),%al

unsigned
mc146818_read(unsigned reg)
{
	outb(IO_RTC, reg);
	return inb(IO_RTC+1);
f0102131:	0f b6 c0             	movzbl %al,%eax
}
f0102134:	c3                   	ret    

f0102135 <mc146818_write>:
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0102135:	ba 70 00 00 00       	mov    $0x70,%edx
f010213a:	8b 44 24 04          	mov    0x4(%esp),%eax
f010213e:	ee                   	out    %al,(%dx)
f010213f:	b2 71                	mov    $0x71,%dl
f0102141:	8b 44 24 08          	mov    0x8(%esp),%eax
f0102145:	ee                   	out    %al,(%dx)
void
mc146818_write(unsigned reg, unsigned datum)
{
	outb(IO_RTC, reg);
	outb(IO_RTC+1, datum);
}
f0102146:	c3                   	ret    
	...

f0102148 <mon_kerninfo>:
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
	return 0;
}

int mon_kerninfo(int argc, char **argv)
{
f0102148:	53                   	push   %ebx
   */
    extern int etext;
    extern int data_start;
    extern int end;
    extern int kernel_load_addr;
    cprintf("Kernel code base start=0x%10x size = %ld\n",&kernel_load_addr,(int)&etext-(int)&kernel_load_addr);
f0102149:	b8 75 31 10 f0       	mov    $0xf0103175,%eax
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
	return 0;
}

int mon_kerninfo(int argc, char **argv)
{
f010214e:	83 ec 0c             	sub    $0xc,%esp
   */
    extern int etext;
    extern int data_start;
    extern int end;
    extern int kernel_load_addr;
    cprintf("Kernel code base start=0x%10x size = %ld\n",&kernel_load_addr,(int)&etext-(int)&kernel_load_addr);
f0102151:	2d 00 00 10 f0       	sub    $0xf0100000,%eax
f0102156:	50                   	push   %eax
    cprintf("Kernel data base start=0x%10x size = %ld\n",&data_start,(int)&end-(int)&data_start);
f0102157:	bb 54 0e 11 f0       	mov    $0xf0110e54,%ebx
   */
    extern int etext;
    extern int data_start;
    extern int end;
    extern int kernel_load_addr;
    cprintf("Kernel code base start=0x%10x size = %ld\n",&kernel_load_addr,(int)&etext-(int)&kernel_load_addr);
f010215c:	68 00 00 10 f0       	push   $0xf0100000
f0102161:	68 72 41 10 f0       	push   $0xf0104172
f0102166:	e8 db e6 ff ff       	call   f0100846 <cprintf>
    cprintf("Kernel data base start=0x%10x size = %ld\n",&data_start,(int)&end-(int)&data_start);
f010216b:	89 d8                	mov    %ebx,%eax
f010216d:	83 c4 0c             	add    $0xc,%esp
f0102170:	2d 00 50 10 f0       	sub    $0xf0105000,%eax
f0102175:	50                   	push   %eax
f0102176:	68 00 50 10 f0       	push   $0xf0105000
f010217b:	68 9c 41 10 f0       	push   $0xf010419c
f0102180:	e8 c1 e6 ff ff       	call   f0100846 <cprintf>
    cprintf("Kernel executable memory footprint: %ldKB\n",((int)&end-(int)&kernel_load_addr)/1024);
f0102185:	b9 00 04 00 00       	mov    $0x400,%ecx
f010218a:	58                   	pop    %eax
f010218b:	89 d8                	mov    %ebx,%eax
f010218d:	2d 00 00 10 f0       	sub    $0xf0100000,%eax
f0102192:	5a                   	pop    %edx
f0102193:	99                   	cltd   
f0102194:	f7 f9                	idiv   %ecx
f0102196:	50                   	push   %eax
f0102197:	68 c6 41 10 f0       	push   $0xf01041c6
f010219c:	e8 a5 e6 ff ff       	call   f0100846 <cprintf>
	return 0;
}
f01021a1:	31 c0                	xor    %eax,%eax
f01021a3:	83 c4 18             	add    $0x18,%esp
f01021a6:	5b                   	pop    %ebx
f01021a7:	c3                   	ret    

f01021a8 <mon_help>:
}
#define NCOMMANDS (sizeof(commands)/sizeof(commands[0]))


int mon_help(int argc, char **argv)
{
f01021a8:	83 ec 10             	sub    $0x10,%esp
	int i;

	for (i = 0; i < NCOMMANDS; i++)
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
f01021ab:	68 f1 41 10 f0       	push   $0xf01041f1
f01021b0:	68 0f 42 10 f0       	push   $0xf010420f
f01021b5:	68 14 42 10 f0       	push   $0xf0104214
f01021ba:	e8 87 e6 ff ff       	call   f0100846 <cprintf>
f01021bf:	83 c4 0c             	add    $0xc,%esp
f01021c2:	68 1d 42 10 f0       	push   $0xf010421d
f01021c7:	68 42 42 10 f0       	push   $0xf0104242
f01021cc:	68 14 42 10 f0       	push   $0xf0104214
f01021d1:	e8 70 e6 ff ff       	call   f0100846 <cprintf>
f01021d6:	83 c4 0c             	add    $0xc,%esp
f01021d9:	68 4b 42 10 f0       	push   $0xf010424b
f01021de:	68 5f 42 10 f0       	push   $0xf010425f
f01021e3:	68 14 42 10 f0       	push   $0xf0104214
f01021e8:	e8 59 e6 ff ff       	call   f0100846 <cprintf>
f01021ed:	83 c4 0c             	add    $0xc,%esp
f01021f0:	68 6a 42 10 f0       	push   $0xf010426a
f01021f5:	68 7f 42 10 f0       	push   $0xf010427f
f01021fa:	68 14 42 10 f0       	push   $0xf0104214
f01021ff:	e8 42 e6 ff ff       	call   f0100846 <cprintf>
	return 0;
}
f0102204:	31 c0                	xor    %eax,%eax
f0102206:	83 c4 1c             	add    $0x1c,%esp
f0102209:	c3                   	ret    

f010220a <print_tick>:
    cprintf("Kernel data base start=0x%10x size = %ld\n",&data_start,(int)&end-(int)&data_start);
    cprintf("Kernel executable memory footprint: %ldKB\n",((int)&end-(int)&kernel_load_addr)/1024);
	return 0;
}
int print_tick(int argc, char **argv)
{
f010220a:	83 ec 0c             	sub    $0xc,%esp
	cprintf("Now tick = %d\n", get_tick());
f010220d:	e8 8b 01 00 00       	call   f010239d <get_tick>
f0102212:	c7 44 24 10 88 42 10 	movl   $0xf0104288,0x10(%esp)
f0102219:	f0 
f010221a:	89 44 24 14          	mov    %eax,0x14(%esp)
}
f010221e:	83 c4 0c             	add    $0xc,%esp
    cprintf("Kernel executable memory footprint: %ldKB\n",((int)&end-(int)&kernel_load_addr)/1024);
	return 0;
}
int print_tick(int argc, char **argv)
{
	cprintf("Now tick = %d\n", get_tick());
f0102221:	e9 20 e6 ff ff       	jmp    f0100846 <cprintf>

f0102226 <chgcolor>:
	{ "help", "Display this list of commands", mon_help },
	{ "kerninfo", "Display information about the kernel", mon_kerninfo },
	{ "print_tick", "Display system tick", print_tick },
    { "chgcolor","change color of text", chgcolor }
};
int chgcolor(int argc, char *argv[]){
f0102226:	53                   	push   %ebx
f0102227:	83 ec 08             	sub    $0x8,%esp
    if(argc == 1)
f010222a:	83 7c 24 10 01       	cmpl   $0x1,0x10(%esp)
	{ "help", "Display this list of commands", mon_help },
	{ "kerninfo", "Display information about the kernel", mon_kerninfo },
	{ "print_tick", "Display system tick", print_tick },
    { "chgcolor","change color of text", chgcolor }
};
int chgcolor(int argc, char *argv[]){
f010222f:	8b 5c 24 14          	mov    0x14(%esp),%ebx
    if(argc == 1)
f0102233:	75 0a                	jne    f010223f <chgcolor+0x19>
        cprintf("NO input text colors!\n");
f0102235:	83 ec 0c             	sub    $0xc,%esp
f0102238:	68 97 42 10 f0       	push   $0xf0104297
f010223d:	eb 1e                	jmp    f010225d <chgcolor+0x37>
    else{
        settextcolor((unsigned char)(*argv[1]),0);
f010223f:	52                   	push   %edx
f0102240:	52                   	push   %edx
f0102241:	6a 00                	push   $0x0
f0102243:	8b 43 04             	mov    0x4(%ebx),%eax
f0102246:	0f b6 00             	movzbl (%eax),%eax
f0102249:	50                   	push   %eax
f010224a:	e8 b0 e2 ff ff       	call   f01004ff <settextcolor>
        cprintf("Change color %c!\n",*argv[1]);
f010224f:	59                   	pop    %ecx
f0102250:	58                   	pop    %eax
f0102251:	8b 43 04             	mov    0x4(%ebx),%eax
f0102254:	0f be 00             	movsbl (%eax),%eax
f0102257:	50                   	push   %eax
f0102258:	68 ae 42 10 f0       	push   $0xf01042ae
f010225d:	e8 e4 e5 ff ff       	call   f0100846 <cprintf>
    }   
    return 0;
                            
}
f0102262:	31 c0                	xor    %eax,%eax
f0102264:	83 c4 18             	add    $0x18,%esp
f0102267:	5b                   	pop    %ebx
f0102268:	c3                   	ret    

f0102269 <shell>:
	}
	cprintf("Unknown command '%s'\n", argv[0]);
	return 0;
}
void shell()
{
f0102269:	55                   	push   %ebp
f010226a:	57                   	push   %edi
f010226b:	56                   	push   %esi
f010226c:	53                   	push   %ebx
f010226d:	83 ec 58             	sub    $0x58,%esp
	char *buf;
	cprintf("Welcome to the OSDI course!\n");
f0102270:	68 c0 42 10 f0       	push   $0xf01042c0
f0102275:	e8 cc e5 ff ff       	call   f0100846 <cprintf>
	cprintf("Type 'help' for a list of commands.\n");
f010227a:	c7 04 24 dd 42 10 f0 	movl   $0xf01042dd,(%esp)
f0102281:	e8 c0 e5 ff ff       	call   f0100846 <cprintf>
f0102286:	83 c4 10             	add    $0x10,%esp
	// Lookup and invoke the command
	if (argc == 0)
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
		if (strcmp(argv[0], commands[i].name) == 0)
			return commands[i].func(argc, argv);
f0102289:	89 e5                	mov    %esp,%ebp
	cprintf("Welcome to the OSDI course!\n");
	cprintf("Type 'help' for a list of commands.\n");

	while(1)
	{
		buf = readline("OSDI> ");
f010228b:	83 ec 0c             	sub    $0xc,%esp
f010228e:	68 02 43 10 f0       	push   $0xf0104302
f0102293:	e8 98 07 00 00       	call   f0102a30 <readline>
		if (buf != NULL)
f0102298:	83 c4 10             	add    $0x10,%esp
f010229b:	85 c0                	test   %eax,%eax
	cprintf("Welcome to the OSDI course!\n");
	cprintf("Type 'help' for a list of commands.\n");

	while(1)
	{
		buf = readline("OSDI> ");
f010229d:	89 c3                	mov    %eax,%ebx
		if (buf != NULL)
f010229f:	74 ea                	je     f010228b <shell+0x22>
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
f01022a1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
	int argc;
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
f01022a8:	31 f6                	xor    %esi,%esi
f01022aa:	eb 04                	jmp    f01022b0 <shell+0x47>
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
			*buf++ = 0;
f01022ac:	c6 03 00             	movb   $0x0,(%ebx)
f01022af:	43                   	inc    %ebx
	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
f01022b0:	8a 03                	mov    (%ebx),%al
f01022b2:	84 c0                	test   %al,%al
f01022b4:	74 17                	je     f01022cd <shell+0x64>
f01022b6:	57                   	push   %edi
f01022b7:	0f be c0             	movsbl %al,%eax
f01022ba:	57                   	push   %edi
f01022bb:	50                   	push   %eax
f01022bc:	68 09 43 10 f0       	push   $0xf0104309
f01022c1:	e8 8b 09 00 00       	call   f0102c51 <strchr>
f01022c6:	83 c4 10             	add    $0x10,%esp
f01022c9:	85 c0                	test   %eax,%eax
f01022cb:	75 df                	jne    f01022ac <shell+0x43>
			*buf++ = 0;
		if (*buf == 0)
f01022cd:	80 3b 00             	cmpb   $0x0,(%ebx)
f01022d0:	74 36                	je     f0102308 <shell+0x9f>
			break;

		// save and scan past next arg
		if (argc == MAXARGS-1) {
f01022d2:	83 fe 0f             	cmp    $0xf,%esi
f01022d5:	75 0b                	jne    f01022e2 <shell+0x79>
			cprintf("Too many arguments (max %d)\n", MAXARGS);
f01022d7:	51                   	push   %ecx
f01022d8:	51                   	push   %ecx
f01022d9:	6a 10                	push   $0x10
f01022db:	68 0e 43 10 f0       	push   $0xf010430e
f01022e0:	eb 7d                	jmp    f010235f <shell+0xf6>
			return 0;
		}
		argv[argc++] = buf;
f01022e2:	89 1c b4             	mov    %ebx,(%esp,%esi,4)
f01022e5:	46                   	inc    %esi
f01022e6:	eb 01                	jmp    f01022e9 <shell+0x80>
		while (*buf && !strchr(WHITESPACE, *buf))
			buf++;
f01022e8:	43                   	inc    %ebx
		if (argc == MAXARGS-1) {
			cprintf("Too many arguments (max %d)\n", MAXARGS);
			return 0;
		}
		argv[argc++] = buf;
		while (*buf && !strchr(WHITESPACE, *buf))
f01022e9:	8a 03                	mov    (%ebx),%al
f01022eb:	84 c0                	test   %al,%al
f01022ed:	74 c1                	je     f01022b0 <shell+0x47>
f01022ef:	52                   	push   %edx
f01022f0:	0f be c0             	movsbl %al,%eax
f01022f3:	52                   	push   %edx
f01022f4:	50                   	push   %eax
f01022f5:	68 09 43 10 f0       	push   $0xf0104309
f01022fa:	e8 52 09 00 00       	call   f0102c51 <strchr>
f01022ff:	83 c4 10             	add    $0x10,%esp
f0102302:	85 c0                	test   %eax,%eax
f0102304:	74 e2                	je     f01022e8 <shell+0x7f>
f0102306:	eb a8                	jmp    f01022b0 <shell+0x47>
			buf++;
	}
	argv[argc] = 0;

	// Lookup and invoke the command
	if (argc == 0)
f0102308:	85 f6                	test   %esi,%esi
		}
		argv[argc++] = buf;
		while (*buf && !strchr(WHITESPACE, *buf))
			buf++;
	}
	argv[argc] = 0;
f010230a:	c7 04 b4 00 00 00 00 	movl   $0x0,(%esp,%esi,4)

	// Lookup and invoke the command
	if (argc == 0)
f0102311:	0f 84 74 ff ff ff    	je     f010228b <shell+0x22>
f0102317:	bf 44 43 10 f0       	mov    $0xf0104344,%edi
f010231c:	31 db                	xor    %ebx,%ebx
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
		if (strcmp(argv[0], commands[i].name) == 0)
f010231e:	50                   	push   %eax
f010231f:	50                   	push   %eax
f0102320:	ff 37                	pushl  (%edi)
f0102322:	83 c7 0c             	add    $0xc,%edi
f0102325:	ff 74 24 0c          	pushl  0xc(%esp)
f0102329:	e8 ac 08 00 00       	call   f0102bda <strcmp>
f010232e:	83 c4 10             	add    $0x10,%esp
f0102331:	85 c0                	test   %eax,%eax
f0102333:	75 19                	jne    f010234e <shell+0xe5>
			return commands[i].func(argc, argv);
f0102335:	6b db 0c             	imul   $0xc,%ebx,%ebx
f0102338:	57                   	push   %edi
f0102339:	57                   	push   %edi
f010233a:	55                   	push   %ebp
f010233b:	56                   	push   %esi
f010233c:	ff 93 4c 43 10 f0    	call   *-0xfefbcb4(%ebx)
	while(1)
	{
		buf = readline("OSDI> ");
		if (buf != NULL)
		{
			if (runcmd(buf) < 0)
f0102342:	83 c4 10             	add    $0x10,%esp
f0102345:	85 c0                	test   %eax,%eax
f0102347:	78 23                	js     f010236c <shell+0x103>
f0102349:	e9 3d ff ff ff       	jmp    f010228b <shell+0x22>
	argv[argc] = 0;

	// Lookup and invoke the command
	if (argc == 0)
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
f010234e:	43                   	inc    %ebx
f010234f:	83 fb 04             	cmp    $0x4,%ebx
f0102352:	75 ca                	jne    f010231e <shell+0xb5>
		if (strcmp(argv[0], commands[i].name) == 0)
			return commands[i].func(argc, argv);
	}
	cprintf("Unknown command '%s'\n", argv[0]);
f0102354:	51                   	push   %ecx
f0102355:	51                   	push   %ecx
f0102356:	ff 74 24 08          	pushl  0x8(%esp)
f010235a:	68 2b 43 10 f0       	push   $0xf010432b
f010235f:	e8 e2 e4 ff ff       	call   f0100846 <cprintf>
f0102364:	83 c4 10             	add    $0x10,%esp
f0102367:	e9 1f ff ff ff       	jmp    f010228b <shell+0x22>
		{
			if (runcmd(buf) < 0)
				break;
		}
	}
}
f010236c:	83 c4 4c             	add    $0x4c,%esp
f010236f:	5b                   	pop    %ebx
f0102370:	5e                   	pop    %esi
f0102371:	5f                   	pop    %edi
f0102372:	5d                   	pop    %ebp
f0102373:	c3                   	ret    

f0102374 <set_timer>:

static unsigned long jiffies = 0;

void set_timer(int hz)
{
    int divisor = 1193180 / hz;       /* Calculate our divisor */
f0102374:	b9 dc 34 12 00       	mov    $0x1234dc,%ecx
f0102379:	89 c8                	mov    %ecx,%eax
f010237b:	99                   	cltd   
f010237c:	f7 7c 24 04          	idivl  0x4(%esp)
f0102380:	ba 43 00 00 00       	mov    $0x43,%edx
f0102385:	89 c1                	mov    %eax,%ecx
f0102387:	b0 36                	mov    $0x36,%al
f0102389:	ee                   	out    %al,(%dx)
f010238a:	b2 40                	mov    $0x40,%dl
f010238c:	88 c8                	mov    %cl,%al
f010238e:	ee                   	out    %al,(%dx)
    outb(0x43, 0x36);             /* Set our command byte 0x36 */
    outb(0x40, divisor & 0xFF);   /* Set low byte of divisor */
    outb(0x40, divisor >> 8);     /* Set high byte of divisor */
f010238f:	89 c8                	mov    %ecx,%eax
f0102391:	c1 f8 08             	sar    $0x8,%eax
f0102394:	ee                   	out    %al,(%dx)
}
f0102395:	c3                   	ret    

f0102396 <timer_handler>:
/* 
 * Timer interrupt handler
 */
void timer_handler()
{
	jiffies++;
f0102396:	ff 05 28 02 11 f0    	incl   0xf0110228
}
f010239c:	c3                   	ret    

f010239d <get_tick>:

unsigned long get_tick()
{
	return jiffies;
}
f010239d:	a1 28 02 11 f0       	mov    0xf0110228,%eax
f01023a2:	c3                   	ret    

f01023a3 <timer_init>:
void timer_init()
{
f01023a3:	83 ec 0c             	sub    $0xc,%esp
	set_timer(TIME_HZ);
f01023a6:	6a 64                	push   $0x64
f01023a8:	e8 c7 ff ff ff       	call   f0102374 <set_timer>

	/* Enable interrupt */
	irq_setmask_8259A(irq_mask_8259A & ~(1<<IRQ_TIMER));
f01023ad:	50                   	push   %eax
f01023ae:	50                   	push   %eax
f01023af:	0f b7 05 00 50 10 f0 	movzwl 0xf0105000,%eax
f01023b6:	25 fe ff 00 00       	and    $0xfffe,%eax
f01023bb:	50                   	push   %eax
f01023bc:	e8 cf dc ff ff       	call   f0100090 <irq_setmask_8259A>
}
f01023c1:	83 c4 1c             	add    $0x1c,%esp
f01023c4:	c3                   	ret    
	...

f01023d0 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
f01023d0:	55                   	push   %ebp
f01023d1:	57                   	push   %edi
f01023d2:	56                   	push   %esi
f01023d3:	53                   	push   %ebx
f01023d4:	83 ec 3c             	sub    $0x3c,%esp
f01023d7:	89 c5                	mov    %eax,%ebp
f01023d9:	89 d6                	mov    %edx,%esi
f01023db:	8b 44 24 50          	mov    0x50(%esp),%eax
f01023df:	89 44 24 24          	mov    %eax,0x24(%esp)
f01023e3:	8b 54 24 54          	mov    0x54(%esp),%edx
f01023e7:	89 54 24 20          	mov    %edx,0x20(%esp)
f01023eb:	8b 5c 24 5c          	mov    0x5c(%esp),%ebx
f01023ef:	8b 7c 24 60          	mov    0x60(%esp),%edi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
f01023f3:	b8 00 00 00 00       	mov    $0x0,%eax
f01023f8:	39 d0                	cmp    %edx,%eax
f01023fa:	72 13                	jb     f010240f <printnum+0x3f>
f01023fc:	8b 4c 24 24          	mov    0x24(%esp),%ecx
f0102400:	39 4c 24 58          	cmp    %ecx,0x58(%esp)
f0102404:	76 09                	jbe    f010240f <printnum+0x3f>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
f0102406:	83 eb 01             	sub    $0x1,%ebx
f0102409:	85 db                	test   %ebx,%ebx
f010240b:	7f 63                	jg     f0102470 <printnum+0xa0>
f010240d:	eb 71                	jmp    f0102480 <printnum+0xb0>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
f010240f:	89 7c 24 10          	mov    %edi,0x10(%esp)
f0102413:	83 eb 01             	sub    $0x1,%ebx
f0102416:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f010241a:	8b 5c 24 58          	mov    0x58(%esp),%ebx
f010241e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f0102422:	8b 44 24 08          	mov    0x8(%esp),%eax
f0102426:	8b 54 24 0c          	mov    0xc(%esp),%edx
f010242a:	89 44 24 28          	mov    %eax,0x28(%esp)
f010242e:	89 54 24 2c          	mov    %edx,0x2c(%esp)
f0102432:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
f0102439:	00 
f010243a:	8b 54 24 24          	mov    0x24(%esp),%edx
f010243e:	89 14 24             	mov    %edx,(%esp)
f0102441:	8b 4c 24 20          	mov    0x20(%esp),%ecx
f0102445:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f0102449:	e8 d2 0a 00 00       	call   f0102f20 <__udivdi3>
f010244e:	8b 4c 24 28          	mov    0x28(%esp),%ecx
f0102452:	8b 5c 24 2c          	mov    0x2c(%esp),%ebx
f0102456:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f010245a:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f010245e:	89 04 24             	mov    %eax,(%esp)
f0102461:	89 54 24 04          	mov    %edx,0x4(%esp)
f0102465:	89 f2                	mov    %esi,%edx
f0102467:	89 e8                	mov    %ebp,%eax
f0102469:	e8 62 ff ff ff       	call   f01023d0 <printnum>
f010246e:	eb 10                	jmp    f0102480 <printnum+0xb0>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
f0102470:	89 74 24 04          	mov    %esi,0x4(%esp)
f0102474:	89 3c 24             	mov    %edi,(%esp)
f0102477:	ff d5                	call   *%ebp
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
f0102479:	83 eb 01             	sub    $0x1,%ebx
f010247c:	85 db                	test   %ebx,%ebx
f010247e:	7f f0                	jg     f0102470 <printnum+0xa0>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f0102480:	89 74 24 04          	mov    %esi,0x4(%esp)
f0102484:	8b 74 24 04          	mov    0x4(%esp),%esi
f0102488:	8b 44 24 58          	mov    0x58(%esp),%eax
f010248c:	89 44 24 08          	mov    %eax,0x8(%esp)
f0102490:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
f0102497:	00 
f0102498:	8b 54 24 24          	mov    0x24(%esp),%edx
f010249c:	89 14 24             	mov    %edx,(%esp)
f010249f:	8b 4c 24 20          	mov    0x20(%esp),%ecx
f01024a3:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f01024a7:	e8 84 0b 00 00       	call   f0103030 <__umoddi3>
f01024ac:	89 74 24 04          	mov    %esi,0x4(%esp)
f01024b0:	0f be 80 74 43 10 f0 	movsbl -0xfefbc8c(%eax),%eax
f01024b7:	89 04 24             	mov    %eax,(%esp)
f01024ba:	ff d5                	call   *%ebp
}
f01024bc:	83 c4 3c             	add    $0x3c,%esp
f01024bf:	5b                   	pop    %ebx
f01024c0:	5e                   	pop    %esi
f01024c1:	5f                   	pop    %edi
f01024c2:	5d                   	pop    %ebp
f01024c3:	c3                   	ret    

f01024c4 <getuint>:
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
f01024c4:	83 fa 01             	cmp    $0x1,%edx
f01024c7:	7e 0d                	jle    f01024d6 <getuint+0x12>
		return va_arg(*ap, unsigned long long);
f01024c9:	8b 10                	mov    (%eax),%edx
f01024cb:	8d 4a 08             	lea    0x8(%edx),%ecx
f01024ce:	89 08                	mov    %ecx,(%eax)
f01024d0:	8b 02                	mov    (%edx),%eax
f01024d2:	8b 52 04             	mov    0x4(%edx),%edx
f01024d5:	c3                   	ret    
	else if (lflag)
f01024d6:	85 d2                	test   %edx,%edx
f01024d8:	74 0f                	je     f01024e9 <getuint+0x25>
		return va_arg(*ap, unsigned long);
f01024da:	8b 10                	mov    (%eax),%edx
f01024dc:	8d 4a 04             	lea    0x4(%edx),%ecx
f01024df:	89 08                	mov    %ecx,(%eax)
f01024e1:	8b 02                	mov    (%edx),%eax
f01024e3:	ba 00 00 00 00       	mov    $0x0,%edx
f01024e8:	c3                   	ret    
	else
		return va_arg(*ap, unsigned int);
f01024e9:	8b 10                	mov    (%eax),%edx
f01024eb:	8d 4a 04             	lea    0x4(%edx),%ecx
f01024ee:	89 08                	mov    %ecx,(%eax)
f01024f0:	8b 02                	mov    (%edx),%eax
f01024f2:	ba 00 00 00 00       	mov    $0x0,%edx
}
f01024f7:	c3                   	ret    

f01024f8 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f01024f8:	8b 44 24 08          	mov    0x8(%esp),%eax
	b->cnt++;
f01024fc:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
f0102500:	8b 10                	mov    (%eax),%edx
f0102502:	3b 50 04             	cmp    0x4(%eax),%edx
f0102505:	73 0b                	jae    f0102512 <sprintputch+0x1a>
		*b->buf++ = ch;
f0102507:	8b 4c 24 04          	mov    0x4(%esp),%ecx
f010250b:	88 0a                	mov    %cl,(%edx)
f010250d:	83 c2 01             	add    $0x1,%edx
f0102510:	89 10                	mov    %edx,(%eax)
f0102512:	f3 c3                	repz ret 

f0102514 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
f0102514:	83 ec 1c             	sub    $0x1c,%esp
	va_list ap;

	va_start(ap, fmt);
f0102517:	8d 44 24 2c          	lea    0x2c(%esp),%eax
	vprintfmt(putch, putdat, fmt, ap);
f010251b:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010251f:	8b 44 24 28          	mov    0x28(%esp),%eax
f0102523:	89 44 24 08          	mov    %eax,0x8(%esp)
f0102527:	8b 44 24 24          	mov    0x24(%esp),%eax
f010252b:	89 44 24 04          	mov    %eax,0x4(%esp)
f010252f:	8b 44 24 20          	mov    0x20(%esp),%eax
f0102533:	89 04 24             	mov    %eax,(%esp)
f0102536:	e8 04 00 00 00       	call   f010253f <vprintfmt>
	va_end(ap);
}
f010253b:	83 c4 1c             	add    $0x1c,%esp
f010253e:	c3                   	ret    

f010253f <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
f010253f:	55                   	push   %ebp
f0102540:	57                   	push   %edi
f0102541:	56                   	push   %esi
f0102542:	53                   	push   %ebx
f0102543:	83 ec 4c             	sub    $0x4c,%esp
f0102546:	8b 6c 24 60          	mov    0x60(%esp),%ebp
f010254a:	8b 7c 24 64          	mov    0x64(%esp),%edi
f010254e:	8b 5c 24 68          	mov    0x68(%esp),%ebx
f0102552:	eb 11                	jmp    f0102565 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
f0102554:	85 c0                	test   %eax,%eax
f0102556:	0f 84 40 04 00 00    	je     f010299c <vprintfmt+0x45d>
				return;
			putch(ch, putdat);
f010255c:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0102560:	89 04 24             	mov    %eax,(%esp)
f0102563:	ff d5                	call   *%ebp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
f0102565:	0f b6 03             	movzbl (%ebx),%eax
f0102568:	83 c3 01             	add    $0x1,%ebx
f010256b:	83 f8 25             	cmp    $0x25,%eax
f010256e:	75 e4                	jne    f0102554 <vprintfmt+0x15>
f0102570:	c6 44 24 28 20       	movb   $0x20,0x28(%esp)
f0102575:	c7 44 24 2c 00 00 00 	movl   $0x0,0x2c(%esp)
f010257c:	00 
f010257d:	be ff ff ff ff       	mov    $0xffffffff,%esi
f0102582:	c7 44 24 30 ff ff ff 	movl   $0xffffffff,0x30(%esp)
f0102589:	ff 
f010258a:	b9 00 00 00 00       	mov    $0x0,%ecx
f010258f:	89 74 24 34          	mov    %esi,0x34(%esp)
f0102593:	eb 34                	jmp    f01025c9 <vprintfmt+0x8a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0102595:	8b 5c 24 24          	mov    0x24(%esp),%ebx

		// flag to pad on the right
		case '-':
			padc = '-';
f0102599:	c6 44 24 28 2d       	movb   $0x2d,0x28(%esp)
f010259e:	eb 29                	jmp    f01025c9 <vprintfmt+0x8a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01025a0:	8b 5c 24 24          	mov    0x24(%esp),%ebx
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
f01025a4:	c6 44 24 28 30       	movb   $0x30,0x28(%esp)
f01025a9:	eb 1e                	jmp    f01025c9 <vprintfmt+0x8a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01025ab:	8b 5c 24 24          	mov    0x24(%esp),%ebx
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
f01025af:	c7 44 24 30 00 00 00 	movl   $0x0,0x30(%esp)
f01025b6:	00 
f01025b7:	eb 10                	jmp    f01025c9 <vprintfmt+0x8a>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
f01025b9:	8b 44 24 34          	mov    0x34(%esp),%eax
f01025bd:	89 44 24 30          	mov    %eax,0x30(%esp)
f01025c1:	c7 44 24 34 ff ff ff 	movl   $0xffffffff,0x34(%esp)
f01025c8:	ff 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01025c9:	0f b6 03             	movzbl (%ebx),%eax
f01025cc:	0f b6 d0             	movzbl %al,%edx
f01025cf:	8d 73 01             	lea    0x1(%ebx),%esi
f01025d2:	89 74 24 24          	mov    %esi,0x24(%esp)
f01025d6:	83 e8 23             	sub    $0x23,%eax
f01025d9:	3c 55                	cmp    $0x55,%al
f01025db:	0f 87 9c 03 00 00    	ja     f010297d <vprintfmt+0x43e>
f01025e1:	0f b6 c0             	movzbl %al,%eax
f01025e4:	ff 24 85 40 44 10 f0 	jmp    *-0xfefbbc0(,%eax,4)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
f01025eb:	83 ea 30             	sub    $0x30,%edx
f01025ee:	89 54 24 34          	mov    %edx,0x34(%esp)
				ch = *fmt;
f01025f2:	8b 54 24 24          	mov    0x24(%esp),%edx
f01025f6:	0f be 02             	movsbl (%edx),%eax
				if (ch < '0' || ch > '9')
f01025f9:	8d 50 d0             	lea    -0x30(%eax),%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01025fc:	8b 5c 24 24          	mov    0x24(%esp),%ebx
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
f0102600:	83 fa 09             	cmp    $0x9,%edx
f0102603:	77 5b                	ja     f0102660 <vprintfmt+0x121>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0102605:	8b 74 24 34          	mov    0x34(%esp),%esi
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
f0102609:	83 c3 01             	add    $0x1,%ebx
				precision = precision * 10 + ch - '0';
f010260c:	8d 14 b6             	lea    (%esi,%esi,4),%edx
f010260f:	8d 74 50 d0          	lea    -0x30(%eax,%edx,2),%esi
				ch = *fmt;
f0102613:	0f be 03             	movsbl (%ebx),%eax
				if (ch < '0' || ch > '9')
f0102616:	8d 50 d0             	lea    -0x30(%eax),%edx
f0102619:	83 fa 09             	cmp    $0x9,%edx
f010261c:	76 eb                	jbe    f0102609 <vprintfmt+0xca>
f010261e:	89 74 24 34          	mov    %esi,0x34(%esp)
f0102622:	eb 3c                	jmp    f0102660 <vprintfmt+0x121>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
f0102624:	8b 44 24 6c          	mov    0x6c(%esp),%eax
f0102628:	8d 50 04             	lea    0x4(%eax),%edx
f010262b:	89 54 24 6c          	mov    %edx,0x6c(%esp)
f010262f:	8b 00                	mov    (%eax),%eax
f0102631:	89 44 24 34          	mov    %eax,0x34(%esp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0102635:	8b 5c 24 24          	mov    0x24(%esp),%ebx
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
f0102639:	eb 25                	jmp    f0102660 <vprintfmt+0x121>

		case '.':
			if (width < 0)
f010263b:	83 7c 24 30 00       	cmpl   $0x0,0x30(%esp)
f0102640:	0f 88 65 ff ff ff    	js     f01025ab <vprintfmt+0x6c>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0102646:	8b 5c 24 24          	mov    0x24(%esp),%ebx
f010264a:	e9 7a ff ff ff       	jmp    f01025c9 <vprintfmt+0x8a>
f010264f:	8b 5c 24 24          	mov    0x24(%esp),%ebx
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
f0102653:	c7 44 24 2c 01 00 00 	movl   $0x1,0x2c(%esp)
f010265a:	00 
			goto reswitch;
f010265b:	e9 69 ff ff ff       	jmp    f01025c9 <vprintfmt+0x8a>

		process_precision:
			if (width < 0)
f0102660:	83 7c 24 30 00       	cmpl   $0x0,0x30(%esp)
f0102665:	0f 89 5e ff ff ff    	jns    f01025c9 <vprintfmt+0x8a>
f010266b:	e9 49 ff ff ff       	jmp    f01025b9 <vprintfmt+0x7a>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
f0102670:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0102673:	8b 5c 24 24          	mov    0x24(%esp),%ebx
f0102677:	e9 4d ff ff ff       	jmp    f01025c9 <vprintfmt+0x8a>
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
f010267c:	8b 44 24 6c          	mov    0x6c(%esp),%eax
f0102680:	8d 50 04             	lea    0x4(%eax),%edx
f0102683:	89 54 24 6c          	mov    %edx,0x6c(%esp)
f0102687:	89 7c 24 04          	mov    %edi,0x4(%esp)
f010268b:	8b 00                	mov    (%eax),%eax
f010268d:	89 04 24             	mov    %eax,(%esp)
f0102690:	ff d5                	call   *%ebp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0102692:	8b 5c 24 24          	mov    0x24(%esp),%ebx
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
f0102696:	e9 ca fe ff ff       	jmp    f0102565 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
f010269b:	8b 44 24 6c          	mov    0x6c(%esp),%eax
f010269f:	8d 50 04             	lea    0x4(%eax),%edx
f01026a2:	89 54 24 6c          	mov    %edx,0x6c(%esp)
f01026a6:	8b 00                	mov    (%eax),%eax
f01026a8:	89 c2                	mov    %eax,%edx
f01026aa:	c1 fa 1f             	sar    $0x1f,%edx
f01026ad:	31 d0                	xor    %edx,%eax
f01026af:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f01026b1:	83 f8 08             	cmp    $0x8,%eax
f01026b4:	7f 0b                	jg     f01026c1 <vprintfmt+0x182>
f01026b6:	8b 14 85 a0 45 10 f0 	mov    -0xfefba60(,%eax,4),%edx
f01026bd:	85 d2                	test   %edx,%edx
f01026bf:	75 21                	jne    f01026e2 <vprintfmt+0x1a3>
				printfmt(putch, putdat, "error %d", err);
f01026c1:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01026c5:	c7 44 24 08 8c 43 10 	movl   $0xf010438c,0x8(%esp)
f01026cc:	f0 
f01026cd:	89 7c 24 04          	mov    %edi,0x4(%esp)
f01026d1:	89 2c 24             	mov    %ebp,(%esp)
f01026d4:	e8 3b fe ff ff       	call   f0102514 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01026d9:	8b 5c 24 24          	mov    0x24(%esp),%ebx
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
f01026dd:	e9 83 fe ff ff       	jmp    f0102565 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
f01026e2:	89 54 24 0c          	mov    %edx,0xc(%esp)
f01026e6:	c7 44 24 08 65 37 10 	movl   $0xf0103765,0x8(%esp)
f01026ed:	f0 
f01026ee:	89 7c 24 04          	mov    %edi,0x4(%esp)
f01026f2:	89 2c 24             	mov    %ebp,(%esp)
f01026f5:	e8 1a fe ff ff       	call   f0102514 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01026fa:	8b 5c 24 24          	mov    0x24(%esp),%ebx
f01026fe:	e9 62 fe ff ff       	jmp    f0102565 <vprintfmt+0x26>
f0102703:	8b 74 24 34          	mov    0x34(%esp),%esi
f0102707:	8b 5c 24 24          	mov    0x24(%esp),%ebx
f010270b:	8b 44 24 30          	mov    0x30(%esp),%eax
f010270f:	89 44 24 38          	mov    %eax,0x38(%esp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
f0102713:	8b 44 24 6c          	mov    0x6c(%esp),%eax
f0102717:	8d 50 04             	lea    0x4(%eax),%edx
f010271a:	89 54 24 6c          	mov    %edx,0x6c(%esp)
f010271e:	8b 00                	mov    (%eax),%eax
				p = "(null)";
f0102720:	85 c0                	test   %eax,%eax
f0102722:	ba 85 43 10 f0       	mov    $0xf0104385,%edx
f0102727:	0f 45 d0             	cmovne %eax,%edx
f010272a:	89 54 24 34          	mov    %edx,0x34(%esp)
			if (width > 0 && padc != '-')
f010272e:	83 7c 24 38 00       	cmpl   $0x0,0x38(%esp)
f0102733:	7e 07                	jle    f010273c <vprintfmt+0x1fd>
f0102735:	80 7c 24 28 2d       	cmpb   $0x2d,0x28(%esp)
f010273a:	75 14                	jne    f0102750 <vprintfmt+0x211>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f010273c:	8b 54 24 34          	mov    0x34(%esp),%edx
f0102740:	0f be 02             	movsbl (%edx),%eax
f0102743:	85 c0                	test   %eax,%eax
f0102745:	0f 85 ac 00 00 00    	jne    f01027f7 <vprintfmt+0x2b8>
f010274b:	e9 97 00 00 00       	jmp    f01027e7 <vprintfmt+0x2a8>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f0102750:	89 74 24 04          	mov    %esi,0x4(%esp)
f0102754:	8b 44 24 34          	mov    0x34(%esp),%eax
f0102758:	89 04 24             	mov    %eax,(%esp)
f010275b:	e8 99 03 00 00       	call   f0102af9 <strnlen>
f0102760:	8b 54 24 38          	mov    0x38(%esp),%edx
f0102764:	29 c2                	sub    %eax,%edx
f0102766:	89 54 24 30          	mov    %edx,0x30(%esp)
f010276a:	85 d2                	test   %edx,%edx
f010276c:	7e ce                	jle    f010273c <vprintfmt+0x1fd>
					putch(padc, putdat);
f010276e:	0f be 44 24 28       	movsbl 0x28(%esp),%eax
f0102773:	89 74 24 38          	mov    %esi,0x38(%esp)
f0102777:	89 5c 24 3c          	mov    %ebx,0x3c(%esp)
f010277b:	89 d3                	mov    %edx,%ebx
f010277d:	89 c6                	mov    %eax,%esi
f010277f:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0102783:	89 34 24             	mov    %esi,(%esp)
f0102786:	ff d5                	call   *%ebp
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f0102788:	83 eb 01             	sub    $0x1,%ebx
f010278b:	85 db                	test   %ebx,%ebx
f010278d:	7f f0                	jg     f010277f <vprintfmt+0x240>
f010278f:	8b 74 24 38          	mov    0x38(%esp),%esi
f0102793:	8b 5c 24 3c          	mov    0x3c(%esp),%ebx
f0102797:	c7 44 24 30 00 00 00 	movl   $0x0,0x30(%esp)
f010279e:	00 
f010279f:	eb 9b                	jmp    f010273c <vprintfmt+0x1fd>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
f01027a1:	83 7c 24 2c 00       	cmpl   $0x0,0x2c(%esp)
f01027a6:	74 19                	je     f01027c1 <vprintfmt+0x282>
f01027a8:	8d 50 e0             	lea    -0x20(%eax),%edx
f01027ab:	83 fa 5e             	cmp    $0x5e,%edx
f01027ae:	76 11                	jbe    f01027c1 <vprintfmt+0x282>
					putch('?', putdat);
f01027b0:	89 7c 24 04          	mov    %edi,0x4(%esp)
f01027b4:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
f01027bb:	ff 54 24 28          	call   *0x28(%esp)
f01027bf:	eb 0b                	jmp    f01027cc <vprintfmt+0x28d>
				else
					putch(ch, putdat);
f01027c1:	89 7c 24 04          	mov    %edi,0x4(%esp)
f01027c5:	89 04 24             	mov    %eax,(%esp)
f01027c8:	ff 54 24 28          	call   *0x28(%esp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f01027cc:	83 ed 01             	sub    $0x1,%ebp
f01027cf:	0f be 03             	movsbl (%ebx),%eax
f01027d2:	85 c0                	test   %eax,%eax
f01027d4:	74 05                	je     f01027db <vprintfmt+0x29c>
f01027d6:	83 c3 01             	add    $0x1,%ebx
f01027d9:	eb 31                	jmp    f010280c <vprintfmt+0x2cd>
f01027db:	89 6c 24 30          	mov    %ebp,0x30(%esp)
f01027df:	8b 6c 24 28          	mov    0x28(%esp),%ebp
f01027e3:	8b 5c 24 38          	mov    0x38(%esp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
f01027e7:	83 7c 24 30 00       	cmpl   $0x0,0x30(%esp)
f01027ec:	7f 35                	jg     f0102823 <vprintfmt+0x2e4>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01027ee:	8b 5c 24 24          	mov    0x24(%esp),%ebx
f01027f2:	e9 6e fd ff ff       	jmp    f0102565 <vprintfmt+0x26>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f01027f7:	8b 54 24 34          	mov    0x34(%esp),%edx
f01027fb:	83 c2 01             	add    $0x1,%edx
f01027fe:	89 6c 24 28          	mov    %ebp,0x28(%esp)
f0102802:	8b 6c 24 30          	mov    0x30(%esp),%ebp
f0102806:	89 5c 24 38          	mov    %ebx,0x38(%esp)
f010280a:	89 d3                	mov    %edx,%ebx
f010280c:	85 f6                	test   %esi,%esi
f010280e:	78 91                	js     f01027a1 <vprintfmt+0x262>
f0102810:	83 ee 01             	sub    $0x1,%esi
f0102813:	79 8c                	jns    f01027a1 <vprintfmt+0x262>
f0102815:	89 6c 24 30          	mov    %ebp,0x30(%esp)
f0102819:	8b 6c 24 28          	mov    0x28(%esp),%ebp
f010281d:	8b 5c 24 38          	mov    0x38(%esp),%ebx
f0102821:	eb c4                	jmp    f01027e7 <vprintfmt+0x2a8>
f0102823:	89 de                	mov    %ebx,%esi
f0102825:	8b 5c 24 30          	mov    0x30(%esp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
f0102829:	89 7c 24 04          	mov    %edi,0x4(%esp)
f010282d:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
f0102834:	ff d5                	call   *%ebp
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
f0102836:	83 eb 01             	sub    $0x1,%ebx
f0102839:	85 db                	test   %ebx,%ebx
f010283b:	7f ec                	jg     f0102829 <vprintfmt+0x2ea>
f010283d:	89 f3                	mov    %esi,%ebx
f010283f:	e9 21 fd ff ff       	jmp    f0102565 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
f0102844:	83 f9 01             	cmp    $0x1,%ecx
f0102847:	7e 12                	jle    f010285b <vprintfmt+0x31c>
		return va_arg(*ap, long long);
f0102849:	8b 44 24 6c          	mov    0x6c(%esp),%eax
f010284d:	8d 50 08             	lea    0x8(%eax),%edx
f0102850:	89 54 24 6c          	mov    %edx,0x6c(%esp)
f0102854:	8b 18                	mov    (%eax),%ebx
f0102856:	8b 70 04             	mov    0x4(%eax),%esi
f0102859:	eb 2a                	jmp    f0102885 <vprintfmt+0x346>
	else if (lflag)
f010285b:	85 c9                	test   %ecx,%ecx
f010285d:	74 14                	je     f0102873 <vprintfmt+0x334>
		return va_arg(*ap, long);
f010285f:	8b 44 24 6c          	mov    0x6c(%esp),%eax
f0102863:	8d 50 04             	lea    0x4(%eax),%edx
f0102866:	89 54 24 6c          	mov    %edx,0x6c(%esp)
f010286a:	8b 18                	mov    (%eax),%ebx
f010286c:	89 de                	mov    %ebx,%esi
f010286e:	c1 fe 1f             	sar    $0x1f,%esi
f0102871:	eb 12                	jmp    f0102885 <vprintfmt+0x346>
	else
		return va_arg(*ap, int);
f0102873:	8b 44 24 6c          	mov    0x6c(%esp),%eax
f0102877:	8d 50 04             	lea    0x4(%eax),%edx
f010287a:	89 54 24 6c          	mov    %edx,0x6c(%esp)
f010287e:	8b 18                	mov    (%eax),%ebx
f0102880:	89 de                	mov    %ebx,%esi
f0102882:	c1 fe 1f             	sar    $0x1f,%esi
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
f0102885:	b8 0a 00 00 00       	mov    $0xa,%eax
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
f010288a:	85 f6                	test   %esi,%esi
f010288c:	0f 89 ab 00 00 00    	jns    f010293d <vprintfmt+0x3fe>
				putch('-', putdat);
f0102892:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0102896:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
f010289d:	ff d5                	call   *%ebp
				num = -(long long) num;
f010289f:	f7 db                	neg    %ebx
f01028a1:	83 d6 00             	adc    $0x0,%esi
f01028a4:	f7 de                	neg    %esi
			}
			base = 10;
f01028a6:	b8 0a 00 00 00       	mov    $0xa,%eax
f01028ab:	e9 8d 00 00 00       	jmp    f010293d <vprintfmt+0x3fe>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
f01028b0:	89 ca                	mov    %ecx,%edx
f01028b2:	8d 44 24 6c          	lea    0x6c(%esp),%eax
f01028b6:	e8 09 fc ff ff       	call   f01024c4 <getuint>
f01028bb:	89 c3                	mov    %eax,%ebx
f01028bd:	89 d6                	mov    %edx,%esi
			base = 10;
f01028bf:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
f01028c4:	eb 77                	jmp    f010293d <vprintfmt+0x3fe>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
f01028c6:	89 7c 24 04          	mov    %edi,0x4(%esp)
f01028ca:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
f01028d1:	ff d5                	call   *%ebp
			putch('X', putdat);
f01028d3:	89 7c 24 04          	mov    %edi,0x4(%esp)
f01028d7:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
f01028de:	ff d5                	call   *%ebp
			putch('X', putdat);
f01028e0:	89 7c 24 04          	mov    %edi,0x4(%esp)
f01028e4:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
f01028eb:	ff d5                	call   *%ebp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01028ed:	8b 5c 24 24          	mov    0x24(%esp),%ebx
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
			putch('X', putdat);
			putch('X', putdat);
			break;
f01028f1:	e9 6f fc ff ff       	jmp    f0102565 <vprintfmt+0x26>

		// pointer
		case 'p':
			putch('0', putdat);
f01028f6:	89 7c 24 04          	mov    %edi,0x4(%esp)
f01028fa:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
f0102901:	ff d5                	call   *%ebp
			putch('x', putdat);
f0102903:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0102907:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
f010290e:	ff d5                	call   *%ebp
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
f0102910:	8b 44 24 6c          	mov    0x6c(%esp),%eax
f0102914:	8d 50 04             	lea    0x4(%eax),%edx
f0102917:	89 54 24 6c          	mov    %edx,0x6c(%esp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
f010291b:	8b 18                	mov    (%eax),%ebx
f010291d:	be 00 00 00 00       	mov    $0x0,%esi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
f0102922:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
f0102927:	eb 14                	jmp    f010293d <vprintfmt+0x3fe>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
f0102929:	89 ca                	mov    %ecx,%edx
f010292b:	8d 44 24 6c          	lea    0x6c(%esp),%eax
f010292f:	e8 90 fb ff ff       	call   f01024c4 <getuint>
f0102934:	89 c3                	mov    %eax,%ebx
f0102936:	89 d6                	mov    %edx,%esi
			base = 16;
f0102938:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
f010293d:	0f be 54 24 28       	movsbl 0x28(%esp),%edx
f0102942:	89 54 24 10          	mov    %edx,0x10(%esp)
f0102946:	8b 54 24 30          	mov    0x30(%esp),%edx
f010294a:	89 54 24 0c          	mov    %edx,0xc(%esp)
f010294e:	89 44 24 08          	mov    %eax,0x8(%esp)
f0102952:	89 1c 24             	mov    %ebx,(%esp)
f0102955:	89 74 24 04          	mov    %esi,0x4(%esp)
f0102959:	89 fa                	mov    %edi,%edx
f010295b:	89 e8                	mov    %ebp,%eax
f010295d:	e8 6e fa ff ff       	call   f01023d0 <printnum>
			break;
f0102962:	8b 5c 24 24          	mov    0x24(%esp),%ebx
f0102966:	e9 fa fb ff ff       	jmp    f0102565 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
f010296b:	89 7c 24 04          	mov    %edi,0x4(%esp)
f010296f:	89 14 24             	mov    %edx,(%esp)
f0102972:	ff d5                	call   *%ebp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0102974:	8b 5c 24 24          	mov    0x24(%esp),%ebx
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
f0102978:	e9 e8 fb ff ff       	jmp    f0102565 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
f010297d:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0102981:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
f0102988:	ff d5                	call   *%ebp
			for (fmt--; fmt[-1] != '%'; fmt--)
f010298a:	eb 02                	jmp    f010298e <vprintfmt+0x44f>
f010298c:	89 c3                	mov    %eax,%ebx
f010298e:	8d 43 ff             	lea    -0x1(%ebx),%eax
f0102991:	80 7b ff 25          	cmpb   $0x25,-0x1(%ebx)
f0102995:	75 f5                	jne    f010298c <vprintfmt+0x44d>
f0102997:	e9 c9 fb ff ff       	jmp    f0102565 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
f010299c:	83 c4 4c             	add    $0x4c,%esp
f010299f:	5b                   	pop    %ebx
f01029a0:	5e                   	pop    %esi
f01029a1:	5f                   	pop    %edi
f01029a2:	5d                   	pop    %ebp
f01029a3:	c3                   	ret    

f01029a4 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f01029a4:	83 ec 2c             	sub    $0x2c,%esp
f01029a7:	8b 44 24 30          	mov    0x30(%esp),%eax
f01029ab:	8b 54 24 34          	mov    0x34(%esp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
f01029af:	89 44 24 14          	mov    %eax,0x14(%esp)
f01029b3:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
f01029b7:	89 4c 24 18          	mov    %ecx,0x18(%esp)
f01029bb:	c7 44 24 1c 00 00 00 	movl   $0x0,0x1c(%esp)
f01029c2:	00 

	if (buf == NULL || n < 1)
f01029c3:	85 c0                	test   %eax,%eax
f01029c5:	74 35                	je     f01029fc <vsnprintf+0x58>
f01029c7:	85 d2                	test   %edx,%edx
f01029c9:	7e 31                	jle    f01029fc <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
f01029cb:	8b 44 24 3c          	mov    0x3c(%esp),%eax
f01029cf:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01029d3:	8b 44 24 38          	mov    0x38(%esp),%eax
f01029d7:	89 44 24 08          	mov    %eax,0x8(%esp)
f01029db:	8d 44 24 14          	lea    0x14(%esp),%eax
f01029df:	89 44 24 04          	mov    %eax,0x4(%esp)
f01029e3:	c7 04 24 f8 24 10 f0 	movl   $0xf01024f8,(%esp)
f01029ea:	e8 50 fb ff ff       	call   f010253f <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f01029ef:	8b 44 24 14          	mov    0x14(%esp),%eax
f01029f3:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f01029f6:	8b 44 24 1c          	mov    0x1c(%esp),%eax
f01029fa:	eb 05                	jmp    f0102a01 <vsnprintf+0x5d>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
f01029fc:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
f0102a01:	83 c4 2c             	add    $0x2c,%esp
f0102a04:	c3                   	ret    

f0102a05 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
f0102a05:	83 ec 1c             	sub    $0x1c,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
f0102a08:	8d 44 24 2c          	lea    0x2c(%esp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
f0102a0c:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0102a10:	8b 44 24 28          	mov    0x28(%esp),%eax
f0102a14:	89 44 24 08          	mov    %eax,0x8(%esp)
f0102a18:	8b 44 24 24          	mov    0x24(%esp),%eax
f0102a1c:	89 44 24 04          	mov    %eax,0x4(%esp)
f0102a20:	8b 44 24 20          	mov    0x20(%esp),%eax
f0102a24:	89 04 24             	mov    %eax,(%esp)
f0102a27:	e8 78 ff ff ff       	call   f01029a4 <vsnprintf>
	va_end(ap);

	return rc;
}
f0102a2c:	83 c4 1c             	add    $0x1c,%esp
f0102a2f:	c3                   	ret    

f0102a30 <readline>:

#define BUFLEN 1024
static char buf[BUFLEN];

char *readline(const char *prompt)
{
f0102a30:	56                   	push   %esi
f0102a31:	53                   	push   %ebx
f0102a32:	83 ec 14             	sub    $0x14,%esp
f0102a35:	8b 44 24 20          	mov    0x20(%esp),%eax
	int i, c, echoing;

	if (prompt != NULL)
f0102a39:	85 c0                	test   %eax,%eax
f0102a3b:	74 10                	je     f0102a4d <readline+0x1d>
		cprintf("%s", prompt);
f0102a3d:	89 44 24 04          	mov    %eax,0x4(%esp)
f0102a41:	c7 04 24 65 37 10 f0 	movl   $0xf0103765,(%esp)
f0102a48:	e8 f9 dd ff ff       	call   f0100846 <cprintf>

#define BUFLEN 1024
static char buf[BUFLEN];

char *readline(const char *prompt)
{
f0102a4d:	be 00 00 00 00       	mov    $0x0,%esi
	if (prompt != NULL)
		cprintf("%s", prompt);

	i = 0;
	while (1) {
		c = getc();
f0102a52:	e8 b4 d8 ff ff       	call   f010030b <getc>
f0102a57:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
f0102a59:	85 c0                	test   %eax,%eax
f0102a5b:	79 17                	jns    f0102a74 <readline+0x44>
			cprintf("read error: %e\n", c);
f0102a5d:	89 44 24 04          	mov    %eax,0x4(%esp)
f0102a61:	c7 04 24 c4 45 10 f0 	movl   $0xf01045c4,(%esp)
f0102a68:	e8 d9 dd ff ff       	call   f0100846 <cprintf>
			return NULL;
f0102a6d:	b8 00 00 00 00       	mov    $0x0,%eax
f0102a72:	eb 64                	jmp    f0102ad8 <readline+0xa8>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f0102a74:	83 f8 08             	cmp    $0x8,%eax
f0102a77:	74 05                	je     f0102a7e <readline+0x4e>
f0102a79:	83 f8 7f             	cmp    $0x7f,%eax
f0102a7c:	75 15                	jne    f0102a93 <readline+0x63>
f0102a7e:	85 f6                	test   %esi,%esi
f0102a80:	7e 11                	jle    f0102a93 <readline+0x63>
			putch('\b');
f0102a82:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
f0102a89:	e8 7b d9 ff ff       	call   f0100409 <putch>
			i--;
f0102a8e:	83 ee 01             	sub    $0x1,%esi
f0102a91:	eb bf                	jmp    f0102a52 <readline+0x22>
		} else if (c >= ' ' && i < BUFLEN-1) {
f0102a93:	83 fb 1f             	cmp    $0x1f,%ebx
f0102a96:	7e 1e                	jle    f0102ab6 <readline+0x86>
f0102a98:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
f0102a9e:	7f 16                	jg     f0102ab6 <readline+0x86>
			putch(c);
f0102aa0:	0f b6 c3             	movzbl %bl,%eax
f0102aa3:	89 04 24             	mov    %eax,(%esp)
f0102aa6:	e8 5e d9 ff ff       	call   f0100409 <putch>
			buf[i++] = c;
f0102aab:	88 9e 40 02 11 f0    	mov    %bl,-0xfeefdc0(%esi)
f0102ab1:	83 c6 01             	add    $0x1,%esi
f0102ab4:	eb 9c                	jmp    f0102a52 <readline+0x22>
		} else if (c == '\n' || c == '\r') {
f0102ab6:	83 fb 0a             	cmp    $0xa,%ebx
f0102ab9:	74 05                	je     f0102ac0 <readline+0x90>
f0102abb:	83 fb 0d             	cmp    $0xd,%ebx
f0102abe:	75 92                	jne    f0102a52 <readline+0x22>
			putch('\n');
f0102ac0:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
f0102ac7:	e8 3d d9 ff ff       	call   f0100409 <putch>
			buf[i] = 0;
f0102acc:	c6 86 40 02 11 f0 00 	movb   $0x0,-0xfeefdc0(%esi)
			return buf;
f0102ad3:	b8 40 02 11 f0       	mov    $0xf0110240,%eax
		}
	}
}
f0102ad8:	83 c4 14             	add    $0x14,%esp
f0102adb:	5b                   	pop    %ebx
f0102adc:	5e                   	pop    %esi
f0102add:	c3                   	ret    
	...

f0102ae0 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
f0102ae0:	8b 54 24 04          	mov    0x4(%esp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
f0102ae4:	b8 00 00 00 00       	mov    $0x0,%eax
f0102ae9:	80 3a 00             	cmpb   $0x0,(%edx)
f0102aec:	74 09                	je     f0102af7 <strlen+0x17>
		n++;
f0102aee:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
f0102af1:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
f0102af5:	75 f7                	jne    f0102aee <strlen+0xe>
		n++;
	return n;
}
f0102af7:	f3 c3                	repz ret 

f0102af9 <strnlen>:

int
strnlen(const char *s, size_t size)
{
f0102af9:	8b 4c 24 04          	mov    0x4(%esp),%ecx
f0102afd:	8b 54 24 08          	mov    0x8(%esp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0102b01:	b8 00 00 00 00       	mov    $0x0,%eax
f0102b06:	85 d2                	test   %edx,%edx
f0102b08:	74 12                	je     f0102b1c <strnlen+0x23>
f0102b0a:	80 39 00             	cmpb   $0x0,(%ecx)
f0102b0d:	74 0d                	je     f0102b1c <strnlen+0x23>
		n++;
f0102b0f:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0102b12:	39 d0                	cmp    %edx,%eax
f0102b14:	74 06                	je     f0102b1c <strnlen+0x23>
f0102b16:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
f0102b1a:	75 f3                	jne    f0102b0f <strnlen+0x16>
		n++;
	return n;
}
f0102b1c:	f3 c3                	repz ret 

f0102b1e <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f0102b1e:	53                   	push   %ebx
f0102b1f:	8b 44 24 08          	mov    0x8(%esp),%eax
f0102b23:	8b 5c 24 0c          	mov    0xc(%esp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
f0102b27:	ba 00 00 00 00       	mov    $0x0,%edx
f0102b2c:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
f0102b30:	88 0c 10             	mov    %cl,(%eax,%edx,1)
f0102b33:	83 c2 01             	add    $0x1,%edx
f0102b36:	84 c9                	test   %cl,%cl
f0102b38:	75 f2                	jne    f0102b2c <strcpy+0xe>
		/* do nothing */;
	return ret;
}
f0102b3a:	5b                   	pop    %ebx
f0102b3b:	c3                   	ret    

f0102b3c <strcat>:

char *
strcat(char *dst, const char *src)
{
f0102b3c:	53                   	push   %ebx
f0102b3d:	83 ec 08             	sub    $0x8,%esp
f0102b40:	8b 5c 24 10          	mov    0x10(%esp),%ebx
	int len = strlen(dst);
f0102b44:	89 1c 24             	mov    %ebx,(%esp)
f0102b47:	e8 94 ff ff ff       	call   f0102ae0 <strlen>
	strcpy(dst + len, src);
f0102b4c:	8b 54 24 14          	mov    0x14(%esp),%edx
f0102b50:	89 54 24 04          	mov    %edx,0x4(%esp)
f0102b54:	8d 04 03             	lea    (%ebx,%eax,1),%eax
f0102b57:	89 04 24             	mov    %eax,(%esp)
f0102b5a:	e8 bf ff ff ff       	call   f0102b1e <strcpy>
	return dst;
}
f0102b5f:	89 d8                	mov    %ebx,%eax
f0102b61:	83 c4 08             	add    $0x8,%esp
f0102b64:	5b                   	pop    %ebx
f0102b65:	c3                   	ret    

f0102b66 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
f0102b66:	56                   	push   %esi
f0102b67:	53                   	push   %ebx
f0102b68:	8b 44 24 0c          	mov    0xc(%esp),%eax
f0102b6c:	8b 54 24 10          	mov    0x10(%esp),%edx
f0102b70:	8b 74 24 14          	mov    0x14(%esp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0102b74:	85 f6                	test   %esi,%esi
f0102b76:	74 18                	je     f0102b90 <strncpy+0x2a>
f0102b78:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
f0102b7d:	0f b6 1a             	movzbl (%edx),%ebx
f0102b80:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
f0102b83:	80 3a 01             	cmpb   $0x1,(%edx)
f0102b86:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0102b89:	83 c1 01             	add    $0x1,%ecx
f0102b8c:	39 ce                	cmp    %ecx,%esi
f0102b8e:	77 ed                	ja     f0102b7d <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
f0102b90:	5b                   	pop    %ebx
f0102b91:	5e                   	pop    %esi
f0102b92:	c3                   	ret    

f0102b93 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
f0102b93:	57                   	push   %edi
f0102b94:	56                   	push   %esi
f0102b95:	53                   	push   %ebx
f0102b96:	8b 7c 24 10          	mov    0x10(%esp),%edi
f0102b9a:	8b 5c 24 14          	mov    0x14(%esp),%ebx
f0102b9e:	8b 74 24 18          	mov    0x18(%esp),%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f0102ba2:	89 f8                	mov    %edi,%eax
f0102ba4:	85 f6                	test   %esi,%esi
f0102ba6:	74 2c                	je     f0102bd4 <strlcpy+0x41>
		while (--size > 0 && *src != '\0')
f0102ba8:	83 fe 01             	cmp    $0x1,%esi
f0102bab:	74 24                	je     f0102bd1 <strlcpy+0x3e>
f0102bad:	0f b6 0b             	movzbl (%ebx),%ecx
f0102bb0:	84 c9                	test   %cl,%cl
f0102bb2:	74 1d                	je     f0102bd1 <strlcpy+0x3e>
f0102bb4:	ba 00 00 00 00       	mov    $0x0,%edx
	}
	return ret;
}

size_t
strlcpy(char *dst, const char *src, size_t size)
f0102bb9:	83 ee 02             	sub    $0x2,%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
f0102bbc:	88 08                	mov    %cl,(%eax)
f0102bbe:	83 c0 01             	add    $0x1,%eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
f0102bc1:	39 f2                	cmp    %esi,%edx
f0102bc3:	74 0c                	je     f0102bd1 <strlcpy+0x3e>
f0102bc5:	0f b6 4c 13 01       	movzbl 0x1(%ebx,%edx,1),%ecx
f0102bca:	83 c2 01             	add    $0x1,%edx
f0102bcd:	84 c9                	test   %cl,%cl
f0102bcf:	75 eb                	jne    f0102bbc <strlcpy+0x29>
			*dst++ = *src++;
		*dst = '\0';
f0102bd1:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
f0102bd4:	29 f8                	sub    %edi,%eax
}
f0102bd6:	5b                   	pop    %ebx
f0102bd7:	5e                   	pop    %esi
f0102bd8:	5f                   	pop    %edi
f0102bd9:	c3                   	ret    

f0102bda <strcmp>:

int
strcmp(const char *p, const char *q)
{
f0102bda:	8b 4c 24 04          	mov    0x4(%esp),%ecx
f0102bde:	8b 54 24 08          	mov    0x8(%esp),%edx
	while (*p && *p == *q)
f0102be2:	0f b6 01             	movzbl (%ecx),%eax
f0102be5:	84 c0                	test   %al,%al
f0102be7:	74 15                	je     f0102bfe <strcmp+0x24>
f0102be9:	3a 02                	cmp    (%edx),%al
f0102beb:	75 11                	jne    f0102bfe <strcmp+0x24>
		p++, q++;
f0102bed:	83 c1 01             	add    $0x1,%ecx
f0102bf0:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
f0102bf3:	0f b6 01             	movzbl (%ecx),%eax
f0102bf6:	84 c0                	test   %al,%al
f0102bf8:	74 04                	je     f0102bfe <strcmp+0x24>
f0102bfa:	3a 02                	cmp    (%edx),%al
f0102bfc:	74 ef                	je     f0102bed <strcmp+0x13>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
f0102bfe:	0f b6 c0             	movzbl %al,%eax
f0102c01:	0f b6 12             	movzbl (%edx),%edx
f0102c04:	29 d0                	sub    %edx,%eax
}
f0102c06:	c3                   	ret    

f0102c07 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
f0102c07:	53                   	push   %ebx
f0102c08:	8b 4c 24 08          	mov    0x8(%esp),%ecx
f0102c0c:	8b 5c 24 0c          	mov    0xc(%esp),%ebx
f0102c10:	8b 54 24 10          	mov    0x10(%esp),%edx
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
f0102c14:	b8 00 00 00 00       	mov    $0x0,%eax
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
f0102c19:	85 d2                	test   %edx,%edx
f0102c1b:	74 28                	je     f0102c45 <strncmp+0x3e>
f0102c1d:	0f b6 01             	movzbl (%ecx),%eax
f0102c20:	84 c0                	test   %al,%al
f0102c22:	74 23                	je     f0102c47 <strncmp+0x40>
f0102c24:	3a 03                	cmp    (%ebx),%al
f0102c26:	75 1f                	jne    f0102c47 <strncmp+0x40>
f0102c28:	83 ea 01             	sub    $0x1,%edx
f0102c2b:	74 13                	je     f0102c40 <strncmp+0x39>
		n--, p++, q++;
f0102c2d:	83 c1 01             	add    $0x1,%ecx
f0102c30:	83 c3 01             	add    $0x1,%ebx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
f0102c33:	0f b6 01             	movzbl (%ecx),%eax
f0102c36:	84 c0                	test   %al,%al
f0102c38:	74 0d                	je     f0102c47 <strncmp+0x40>
f0102c3a:	3a 03                	cmp    (%ebx),%al
f0102c3c:	74 ea                	je     f0102c28 <strncmp+0x21>
f0102c3e:	eb 07                	jmp    f0102c47 <strncmp+0x40>
		n--, p++, q++;
	if (n == 0)
		return 0;
f0102c40:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
f0102c45:	5b                   	pop    %ebx
f0102c46:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f0102c47:	0f b6 01             	movzbl (%ecx),%eax
f0102c4a:	0f b6 13             	movzbl (%ebx),%edx
f0102c4d:	29 d0                	sub    %edx,%eax
f0102c4f:	eb f4                	jmp    f0102c45 <strncmp+0x3e>

f0102c51 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f0102c51:	8b 44 24 04          	mov    0x4(%esp),%eax
f0102c55:	0f b6 4c 24 08       	movzbl 0x8(%esp),%ecx
	for (; *s; s++)
f0102c5a:	0f b6 10             	movzbl (%eax),%edx
f0102c5d:	84 d2                	test   %dl,%dl
f0102c5f:	74 21                	je     f0102c82 <strchr+0x31>
		if (*s == c)
f0102c61:	38 ca                	cmp    %cl,%dl
f0102c63:	75 0d                	jne    f0102c72 <strchr+0x21>
f0102c65:	f3 c3                	repz ret 
f0102c67:	38 ca                	cmp    %cl,%dl
f0102c69:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0102c70:	74 15                	je     f0102c87 <strchr+0x36>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
f0102c72:	83 c0 01             	add    $0x1,%eax
f0102c75:	0f b6 10             	movzbl (%eax),%edx
f0102c78:	84 d2                	test   %dl,%dl
f0102c7a:	75 eb                	jne    f0102c67 <strchr+0x16>
		if (*s == c)
			return (char *) s;
	return 0;
f0102c7c:	b8 00 00 00 00       	mov    $0x0,%eax
f0102c81:	c3                   	ret    
f0102c82:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0102c87:	f3 c3                	repz ret 

f0102c89 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f0102c89:	8b 44 24 04          	mov    0x4(%esp),%eax
f0102c8d:	0f b6 4c 24 08       	movzbl 0x8(%esp),%ecx
	for (; *s; s++)
f0102c92:	0f b6 10             	movzbl (%eax),%edx
f0102c95:	84 d2                	test   %dl,%dl
f0102c97:	74 14                	je     f0102cad <strfind+0x24>
		if (*s == c)
f0102c99:	38 ca                	cmp    %cl,%dl
f0102c9b:	75 06                	jne    f0102ca3 <strfind+0x1a>
f0102c9d:	f3 c3                	repz ret 
f0102c9f:	38 ca                	cmp    %cl,%dl
f0102ca1:	74 0a                	je     f0102cad <strfind+0x24>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
f0102ca3:	83 c0 01             	add    $0x1,%eax
f0102ca6:	0f b6 10             	movzbl (%eax),%edx
f0102ca9:	84 d2                	test   %dl,%dl
f0102cab:	75 f2                	jne    f0102c9f <strfind+0x16>
		if (*s == c)
			break;
	return (char *) s;
}
f0102cad:	f3 c3                	repz ret 

f0102caf <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
f0102caf:	83 ec 0c             	sub    $0xc,%esp
f0102cb2:	89 1c 24             	mov    %ebx,(%esp)
f0102cb5:	89 74 24 04          	mov    %esi,0x4(%esp)
f0102cb9:	89 7c 24 08          	mov    %edi,0x8(%esp)
f0102cbd:	8b 7c 24 10          	mov    0x10(%esp),%edi
f0102cc1:	8b 44 24 14          	mov    0x14(%esp),%eax
f0102cc5:	8b 4c 24 18          	mov    0x18(%esp),%ecx
	char *p;

	if (n == 0)
f0102cc9:	85 c9                	test   %ecx,%ecx
f0102ccb:	74 30                	je     f0102cfd <memset+0x4e>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
f0102ccd:	f7 c7 03 00 00 00    	test   $0x3,%edi
f0102cd3:	75 25                	jne    f0102cfa <memset+0x4b>
f0102cd5:	f6 c1 03             	test   $0x3,%cl
f0102cd8:	75 20                	jne    f0102cfa <memset+0x4b>
		c &= 0xFF;
f0102cda:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
f0102cdd:	89 d3                	mov    %edx,%ebx
f0102cdf:	c1 e3 08             	shl    $0x8,%ebx
f0102ce2:	89 d6                	mov    %edx,%esi
f0102ce4:	c1 e6 18             	shl    $0x18,%esi
f0102ce7:	89 d0                	mov    %edx,%eax
f0102ce9:	c1 e0 10             	shl    $0x10,%eax
f0102cec:	09 f0                	or     %esi,%eax
f0102cee:	09 d0                	or     %edx,%eax
f0102cf0:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
f0102cf2:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
f0102cf5:	fc                   	cld    
f0102cf6:	f3 ab                	rep stos %eax,%es:(%edi)
f0102cf8:	eb 03                	jmp    f0102cfd <memset+0x4e>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
f0102cfa:	fc                   	cld    
f0102cfb:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
f0102cfd:	89 f8                	mov    %edi,%eax
f0102cff:	8b 1c 24             	mov    (%esp),%ebx
f0102d02:	8b 74 24 04          	mov    0x4(%esp),%esi
f0102d06:	8b 7c 24 08          	mov    0x8(%esp),%edi
f0102d0a:	83 c4 0c             	add    $0xc,%esp
f0102d0d:	c3                   	ret    

f0102d0e <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
f0102d0e:	83 ec 08             	sub    $0x8,%esp
f0102d11:	89 34 24             	mov    %esi,(%esp)
f0102d14:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0102d18:	8b 44 24 0c          	mov    0xc(%esp),%eax
f0102d1c:	8b 74 24 10          	mov    0x10(%esp),%esi
f0102d20:	8b 4c 24 14          	mov    0x14(%esp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
f0102d24:	39 c6                	cmp    %eax,%esi
f0102d26:	73 36                	jae    f0102d5e <memmove+0x50>
f0102d28:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
f0102d2b:	39 d0                	cmp    %edx,%eax
f0102d2d:	73 2f                	jae    f0102d5e <memmove+0x50>
		s += n;
		d += n;
f0102d2f:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0102d32:	f6 c2 03             	test   $0x3,%dl
f0102d35:	75 1b                	jne    f0102d52 <memmove+0x44>
f0102d37:	f7 c7 03 00 00 00    	test   $0x3,%edi
f0102d3d:	75 13                	jne    f0102d52 <memmove+0x44>
f0102d3f:	f6 c1 03             	test   $0x3,%cl
f0102d42:	75 0e                	jne    f0102d52 <memmove+0x44>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
f0102d44:	83 ef 04             	sub    $0x4,%edi
f0102d47:	8d 72 fc             	lea    -0x4(%edx),%esi
f0102d4a:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
f0102d4d:	fd                   	std    
f0102d4e:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0102d50:	eb 09                	jmp    f0102d5b <memmove+0x4d>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
f0102d52:	83 ef 01             	sub    $0x1,%edi
f0102d55:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
f0102d58:	fd                   	std    
f0102d59:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
f0102d5b:	fc                   	cld    
f0102d5c:	eb 20                	jmp    f0102d7e <memmove+0x70>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0102d5e:	f7 c6 03 00 00 00    	test   $0x3,%esi
f0102d64:	75 13                	jne    f0102d79 <memmove+0x6b>
f0102d66:	a8 03                	test   $0x3,%al
f0102d68:	75 0f                	jne    f0102d79 <memmove+0x6b>
f0102d6a:	f6 c1 03             	test   $0x3,%cl
f0102d6d:	75 0a                	jne    f0102d79 <memmove+0x6b>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
f0102d6f:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
f0102d72:	89 c7                	mov    %eax,%edi
f0102d74:	fc                   	cld    
f0102d75:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0102d77:	eb 05                	jmp    f0102d7e <memmove+0x70>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
f0102d79:	89 c7                	mov    %eax,%edi
f0102d7b:	fc                   	cld    
f0102d7c:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
f0102d7e:	8b 34 24             	mov    (%esp),%esi
f0102d81:	8b 7c 24 04          	mov    0x4(%esp),%edi
f0102d85:	83 c4 08             	add    $0x8,%esp
f0102d88:	c3                   	ret    

f0102d89 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
f0102d89:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
f0102d8c:	8b 44 24 18          	mov    0x18(%esp),%eax
f0102d90:	89 44 24 08          	mov    %eax,0x8(%esp)
f0102d94:	8b 44 24 14          	mov    0x14(%esp),%eax
f0102d98:	89 44 24 04          	mov    %eax,0x4(%esp)
f0102d9c:	8b 44 24 10          	mov    0x10(%esp),%eax
f0102da0:	89 04 24             	mov    %eax,(%esp)
f0102da3:	e8 66 ff ff ff       	call   f0102d0e <memmove>
}
f0102da8:	83 c4 0c             	add    $0xc,%esp
f0102dab:	c3                   	ret    

f0102dac <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
f0102dac:	57                   	push   %edi
f0102dad:	56                   	push   %esi
f0102dae:	53                   	push   %ebx
f0102daf:	8b 5c 24 10          	mov    0x10(%esp),%ebx
f0102db3:	8b 74 24 14          	mov    0x14(%esp),%esi
f0102db7:	8b 7c 24 18          	mov    0x18(%esp),%edi
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
f0102dbb:	b8 00 00 00 00       	mov    $0x0,%eax
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f0102dc0:	85 ff                	test   %edi,%edi
f0102dc2:	74 38                	je     f0102dfc <memcmp+0x50>
		if (*s1 != *s2)
f0102dc4:	0f b6 03             	movzbl (%ebx),%eax
f0102dc7:	0f b6 0e             	movzbl (%esi),%ecx
f0102dca:	38 c8                	cmp    %cl,%al
f0102dcc:	74 1d                	je     f0102deb <memcmp+0x3f>
f0102dce:	eb 11                	jmp    f0102de1 <memcmp+0x35>
f0102dd0:	0f b6 44 13 01       	movzbl 0x1(%ebx,%edx,1),%eax
f0102dd5:	0f b6 4c 16 01       	movzbl 0x1(%esi,%edx,1),%ecx
f0102dda:	83 c2 01             	add    $0x1,%edx
f0102ddd:	38 c8                	cmp    %cl,%al
f0102ddf:	74 12                	je     f0102df3 <memcmp+0x47>
			return (int) *s1 - (int) *s2;
f0102de1:	0f b6 c0             	movzbl %al,%eax
f0102de4:	0f b6 c9             	movzbl %cl,%ecx
f0102de7:	29 c8                	sub    %ecx,%eax
f0102de9:	eb 11                	jmp    f0102dfc <memcmp+0x50>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f0102deb:	83 ef 01             	sub    $0x1,%edi
f0102dee:	ba 00 00 00 00       	mov    $0x0,%edx
f0102df3:	39 fa                	cmp    %edi,%edx
f0102df5:	75 d9                	jne    f0102dd0 <memcmp+0x24>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
f0102df7:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0102dfc:	5b                   	pop    %ebx
f0102dfd:	5e                   	pop    %esi
f0102dfe:	5f                   	pop    %edi
f0102dff:	c3                   	ret    

f0102e00 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
f0102e00:	8b 44 24 04          	mov    0x4(%esp),%eax
	const void *ends = (const char *) s + n;
f0102e04:	89 c2                	mov    %eax,%edx
f0102e06:	03 54 24 0c          	add    0xc(%esp),%edx
	for (; s < ends; s++)
f0102e0a:	39 d0                	cmp    %edx,%eax
f0102e0c:	73 16                	jae    f0102e24 <memfind+0x24>
		if (*(const unsigned char *) s == (unsigned char) c)
f0102e0e:	0f b6 4c 24 08       	movzbl 0x8(%esp),%ecx
f0102e13:	38 08                	cmp    %cl,(%eax)
f0102e15:	75 06                	jne    f0102e1d <memfind+0x1d>
f0102e17:	f3 c3                	repz ret 
f0102e19:	38 08                	cmp    %cl,(%eax)
f0102e1b:	74 07                	je     f0102e24 <memfind+0x24>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
f0102e1d:	83 c0 01             	add    $0x1,%eax
f0102e20:	39 c2                	cmp    %eax,%edx
f0102e22:	77 f5                	ja     f0102e19 <memfind+0x19>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
f0102e24:	f3 c3                	repz ret 

f0102e26 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f0102e26:	55                   	push   %ebp
f0102e27:	57                   	push   %edi
f0102e28:	56                   	push   %esi
f0102e29:	53                   	push   %ebx
f0102e2a:	8b 54 24 14          	mov    0x14(%esp),%edx
f0102e2e:	8b 74 24 18          	mov    0x18(%esp),%esi
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f0102e32:	0f b6 02             	movzbl (%edx),%eax
f0102e35:	3c 20                	cmp    $0x20,%al
f0102e37:	74 04                	je     f0102e3d <strtol+0x17>
f0102e39:	3c 09                	cmp    $0x9,%al
f0102e3b:	75 0e                	jne    f0102e4b <strtol+0x25>
		s++;
f0102e3d:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f0102e40:	0f b6 02             	movzbl (%edx),%eax
f0102e43:	3c 20                	cmp    $0x20,%al
f0102e45:	74 f6                	je     f0102e3d <strtol+0x17>
f0102e47:	3c 09                	cmp    $0x9,%al
f0102e49:	74 f2                	je     f0102e3d <strtol+0x17>
		s++;

	// plus/minus sign
	if (*s == '+')
f0102e4b:	3c 2b                	cmp    $0x2b,%al
f0102e4d:	75 0a                	jne    f0102e59 <strtol+0x33>
		s++;
f0102e4f:	83 c2 01             	add    $0x1,%edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
f0102e52:	bf 00 00 00 00       	mov    $0x0,%edi
f0102e57:	eb 10                	jmp    f0102e69 <strtol+0x43>
f0102e59:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
f0102e5e:	3c 2d                	cmp    $0x2d,%al
f0102e60:	75 07                	jne    f0102e69 <strtol+0x43>
		s++, neg = 1;
f0102e62:	83 c2 01             	add    $0x1,%edx
f0102e65:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f0102e69:	83 7c 24 1c 00       	cmpl   $0x0,0x1c(%esp)
f0102e6e:	0f 94 c0             	sete   %al
f0102e71:	74 07                	je     f0102e7a <strtol+0x54>
f0102e73:	83 7c 24 1c 10       	cmpl   $0x10,0x1c(%esp)
f0102e78:	75 18                	jne    f0102e92 <strtol+0x6c>
f0102e7a:	80 3a 30             	cmpb   $0x30,(%edx)
f0102e7d:	75 13                	jne    f0102e92 <strtol+0x6c>
f0102e7f:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
f0102e83:	75 0d                	jne    f0102e92 <strtol+0x6c>
		s += 2, base = 16;
f0102e85:	83 c2 02             	add    $0x2,%edx
f0102e88:	c7 44 24 1c 10 00 00 	movl   $0x10,0x1c(%esp)
f0102e8f:	00 
f0102e90:	eb 1c                	jmp    f0102eae <strtol+0x88>
	else if (base == 0 && s[0] == '0')
f0102e92:	84 c0                	test   %al,%al
f0102e94:	74 18                	je     f0102eae <strtol+0x88>
		s++, base = 8;
	else if (base == 0)
		base = 10;
f0102e96:	c7 44 24 1c 0a 00 00 	movl   $0xa,0x1c(%esp)
f0102e9d:	00 
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f0102e9e:	80 3a 30             	cmpb   $0x30,(%edx)
f0102ea1:	75 0b                	jne    f0102eae <strtol+0x88>
		s++, base = 8;
f0102ea3:	83 c2 01             	add    $0x1,%edx
f0102ea6:	c7 44 24 1c 08 00 00 	movl   $0x8,0x1c(%esp)
f0102ead:	00 
	else if (base == 0)
		base = 10;
f0102eae:	b8 00 00 00 00       	mov    $0x0,%eax

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
f0102eb3:	0f b6 0a             	movzbl (%edx),%ecx
f0102eb6:	8d 69 d0             	lea    -0x30(%ecx),%ebp
f0102eb9:	89 eb                	mov    %ebp,%ebx
f0102ebb:	80 fb 09             	cmp    $0x9,%bl
f0102ebe:	77 08                	ja     f0102ec8 <strtol+0xa2>
			dig = *s - '0';
f0102ec0:	0f be c9             	movsbl %cl,%ecx
f0102ec3:	83 e9 30             	sub    $0x30,%ecx
f0102ec6:	eb 22                	jmp    f0102eea <strtol+0xc4>
		else if (*s >= 'a' && *s <= 'z')
f0102ec8:	8d 69 9f             	lea    -0x61(%ecx),%ebp
f0102ecb:	89 eb                	mov    %ebp,%ebx
f0102ecd:	80 fb 19             	cmp    $0x19,%bl
f0102ed0:	77 08                	ja     f0102eda <strtol+0xb4>
			dig = *s - 'a' + 10;
f0102ed2:	0f be c9             	movsbl %cl,%ecx
f0102ed5:	83 e9 57             	sub    $0x57,%ecx
f0102ed8:	eb 10                	jmp    f0102eea <strtol+0xc4>
		else if (*s >= 'A' && *s <= 'Z')
f0102eda:	8d 69 bf             	lea    -0x41(%ecx),%ebp
f0102edd:	89 eb                	mov    %ebp,%ebx
f0102edf:	80 fb 19             	cmp    $0x19,%bl
f0102ee2:	77 19                	ja     f0102efd <strtol+0xd7>
			dig = *s - 'A' + 10;
f0102ee4:	0f be c9             	movsbl %cl,%ecx
f0102ee7:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
f0102eea:	3b 4c 24 1c          	cmp    0x1c(%esp),%ecx
f0102eee:	7d 11                	jge    f0102f01 <strtol+0xdb>
			break;
		s++, val = (val * base) + dig;
f0102ef0:	83 c2 01             	add    $0x1,%edx
f0102ef3:	0f af 44 24 1c       	imul   0x1c(%esp),%eax
f0102ef8:	8d 04 01             	lea    (%ecx,%eax,1),%eax
		// we don't properly detect overflow!
	}
f0102efb:	eb b6                	jmp    f0102eb3 <strtol+0x8d>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
f0102efd:	89 c1                	mov    %eax,%ecx
f0102eff:	eb 02                	jmp    f0102f03 <strtol+0xdd>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
f0102f01:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
f0102f03:	85 f6                	test   %esi,%esi
f0102f05:	74 02                	je     f0102f09 <strtol+0xe3>
		*endptr = (char *) s;
f0102f07:	89 16                	mov    %edx,(%esi)
	return (neg ? -val : val);
f0102f09:	89 ca                	mov    %ecx,%edx
f0102f0b:	f7 da                	neg    %edx
f0102f0d:	85 ff                	test   %edi,%edi
f0102f0f:	0f 45 c2             	cmovne %edx,%eax
}
f0102f12:	5b                   	pop    %ebx
f0102f13:	5e                   	pop    %esi
f0102f14:	5f                   	pop    %edi
f0102f15:	5d                   	pop    %ebp
f0102f16:	c3                   	ret    
	...

f0102f20 <__udivdi3>:
f0102f20:	55                   	push   %ebp
f0102f21:	89 e5                	mov    %esp,%ebp
f0102f23:	57                   	push   %edi
f0102f24:	56                   	push   %esi
f0102f25:	8d 64 24 e0          	lea    -0x20(%esp),%esp
f0102f29:	8b 45 14             	mov    0x14(%ebp),%eax
f0102f2c:	8b 75 08             	mov    0x8(%ebp),%esi
f0102f2f:	8b 4d 10             	mov    0x10(%ebp),%ecx
f0102f32:	85 c0                	test   %eax,%eax
f0102f34:	89 75 e8             	mov    %esi,-0x18(%ebp)
f0102f37:	8b 7d 0c             	mov    0xc(%ebp),%edi
f0102f3a:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f0102f3d:	75 39                	jne    f0102f78 <__udivdi3+0x58>
f0102f3f:	39 f9                	cmp    %edi,%ecx
f0102f41:	77 65                	ja     f0102fa8 <__udivdi3+0x88>
f0102f43:	85 c9                	test   %ecx,%ecx
f0102f45:	75 0b                	jne    f0102f52 <__udivdi3+0x32>
f0102f47:	b8 01 00 00 00       	mov    $0x1,%eax
f0102f4c:	31 d2                	xor    %edx,%edx
f0102f4e:	f7 f1                	div    %ecx
f0102f50:	89 c1                	mov    %eax,%ecx
f0102f52:	89 f8                	mov    %edi,%eax
f0102f54:	31 d2                	xor    %edx,%edx
f0102f56:	f7 f1                	div    %ecx
f0102f58:	89 c7                	mov    %eax,%edi
f0102f5a:	89 f0                	mov    %esi,%eax
f0102f5c:	f7 f1                	div    %ecx
f0102f5e:	89 fa                	mov    %edi,%edx
f0102f60:	89 c6                	mov    %eax,%esi
f0102f62:	89 75 f0             	mov    %esi,-0x10(%ebp)
f0102f65:	89 55 f4             	mov    %edx,-0xc(%ebp)
f0102f68:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0102f6b:	8b 55 f4             	mov    -0xc(%ebp),%edx
f0102f6e:	8d 64 24 20          	lea    0x20(%esp),%esp
f0102f72:	5e                   	pop    %esi
f0102f73:	5f                   	pop    %edi
f0102f74:	5d                   	pop    %ebp
f0102f75:	c3                   	ret    
f0102f76:	66 90                	xchg   %ax,%ax
f0102f78:	31 d2                	xor    %edx,%edx
f0102f7a:	31 f6                	xor    %esi,%esi
f0102f7c:	39 f8                	cmp    %edi,%eax
f0102f7e:	77 e2                	ja     f0102f62 <__udivdi3+0x42>
f0102f80:	0f bd d0             	bsr    %eax,%edx
f0102f83:	83 f2 1f             	xor    $0x1f,%edx
f0102f86:	89 55 ec             	mov    %edx,-0x14(%ebp)
f0102f89:	75 2d                	jne    f0102fb8 <__udivdi3+0x98>
f0102f8b:	8b 4d e8             	mov    -0x18(%ebp),%ecx
f0102f8e:	39 4d f0             	cmp    %ecx,-0x10(%ebp)
f0102f91:	76 06                	jbe    f0102f99 <__udivdi3+0x79>
f0102f93:	39 f8                	cmp    %edi,%eax
f0102f95:	89 f2                	mov    %esi,%edx
f0102f97:	73 c9                	jae    f0102f62 <__udivdi3+0x42>
f0102f99:	31 d2                	xor    %edx,%edx
f0102f9b:	be 01 00 00 00       	mov    $0x1,%esi
f0102fa0:	eb c0                	jmp    f0102f62 <__udivdi3+0x42>
f0102fa2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0102fa8:	89 f0                	mov    %esi,%eax
f0102faa:	89 fa                	mov    %edi,%edx
f0102fac:	f7 f1                	div    %ecx
f0102fae:	31 d2                	xor    %edx,%edx
f0102fb0:	89 c6                	mov    %eax,%esi
f0102fb2:	eb ae                	jmp    f0102f62 <__udivdi3+0x42>
f0102fb4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0102fb8:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
f0102fbc:	89 c2                	mov    %eax,%edx
f0102fbe:	b8 20 00 00 00       	mov    $0x20,%eax
f0102fc3:	2b 45 ec             	sub    -0x14(%ebp),%eax
f0102fc6:	d3 e2                	shl    %cl,%edx
f0102fc8:	89 c1                	mov    %eax,%ecx
f0102fca:	8b 75 f0             	mov    -0x10(%ebp),%esi
f0102fcd:	d3 ee                	shr    %cl,%esi
f0102fcf:	09 d6                	or     %edx,%esi
f0102fd1:	89 fa                	mov    %edi,%edx
f0102fd3:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
f0102fd7:	89 75 e4             	mov    %esi,-0x1c(%ebp)
f0102fda:	8b 75 f0             	mov    -0x10(%ebp),%esi
f0102fdd:	d3 e6                	shl    %cl,%esi
f0102fdf:	89 c1                	mov    %eax,%ecx
f0102fe1:	89 75 f0             	mov    %esi,-0x10(%ebp)
f0102fe4:	8b 75 e8             	mov    -0x18(%ebp),%esi
f0102fe7:	d3 ea                	shr    %cl,%edx
f0102fe9:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
f0102fed:	d3 e7                	shl    %cl,%edi
f0102fef:	89 c1                	mov    %eax,%ecx
f0102ff1:	d3 ee                	shr    %cl,%esi
f0102ff3:	09 fe                	or     %edi,%esi
f0102ff5:	89 f0                	mov    %esi,%eax
f0102ff7:	f7 75 e4             	divl   -0x1c(%ebp)
f0102ffa:	89 d7                	mov    %edx,%edi
f0102ffc:	89 c6                	mov    %eax,%esi
f0102ffe:	f7 65 f0             	mull   -0x10(%ebp)
f0103001:	39 d7                	cmp    %edx,%edi
f0103003:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f0103006:	72 12                	jb     f010301a <__udivdi3+0xfa>
f0103008:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
f010300c:	8b 55 e8             	mov    -0x18(%ebp),%edx
f010300f:	d3 e2                	shl    %cl,%edx
f0103011:	39 c2                	cmp    %eax,%edx
f0103013:	73 08                	jae    f010301d <__udivdi3+0xfd>
f0103015:	3b 7d e4             	cmp    -0x1c(%ebp),%edi
f0103018:	75 03                	jne    f010301d <__udivdi3+0xfd>
f010301a:	8d 76 ff             	lea    -0x1(%esi),%esi
f010301d:	31 d2                	xor    %edx,%edx
f010301f:	e9 3e ff ff ff       	jmp    f0102f62 <__udivdi3+0x42>
	...

f0103030 <__umoddi3>:
f0103030:	55                   	push   %ebp
f0103031:	89 e5                	mov    %esp,%ebp
f0103033:	57                   	push   %edi
f0103034:	56                   	push   %esi
f0103035:	8d 64 24 e0          	lea    -0x20(%esp),%esp
f0103039:	8b 7d 14             	mov    0x14(%ebp),%edi
f010303c:	8b 45 08             	mov    0x8(%ebp),%eax
f010303f:	8b 4d 10             	mov    0x10(%ebp),%ecx
f0103042:	8b 75 0c             	mov    0xc(%ebp),%esi
f0103045:	85 ff                	test   %edi,%edi
f0103047:	89 45 e8             	mov    %eax,-0x18(%ebp)
f010304a:	89 4d f4             	mov    %ecx,-0xc(%ebp)
f010304d:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0103050:	89 f2                	mov    %esi,%edx
f0103052:	75 14                	jne    f0103068 <__umoddi3+0x38>
f0103054:	39 f1                	cmp    %esi,%ecx
f0103056:	76 40                	jbe    f0103098 <__umoddi3+0x68>
f0103058:	f7 f1                	div    %ecx
f010305a:	89 d0                	mov    %edx,%eax
f010305c:	31 d2                	xor    %edx,%edx
f010305e:	8d 64 24 20          	lea    0x20(%esp),%esp
f0103062:	5e                   	pop    %esi
f0103063:	5f                   	pop    %edi
f0103064:	5d                   	pop    %ebp
f0103065:	c3                   	ret    
f0103066:	66 90                	xchg   %ax,%ax
f0103068:	39 f7                	cmp    %esi,%edi
f010306a:	77 4c                	ja     f01030b8 <__umoddi3+0x88>
f010306c:	0f bd c7             	bsr    %edi,%eax
f010306f:	83 f0 1f             	xor    $0x1f,%eax
f0103072:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0103075:	75 51                	jne    f01030c8 <__umoddi3+0x98>
f0103077:	3b 4d f0             	cmp    -0x10(%ebp),%ecx
f010307a:	0f 87 e8 00 00 00    	ja     f0103168 <__umoddi3+0x138>
f0103080:	89 f2                	mov    %esi,%edx
f0103082:	8b 75 f0             	mov    -0x10(%ebp),%esi
f0103085:	29 ce                	sub    %ecx,%esi
f0103087:	19 fa                	sbb    %edi,%edx
f0103089:	89 75 f0             	mov    %esi,-0x10(%ebp)
f010308c:	8b 45 f0             	mov    -0x10(%ebp),%eax
f010308f:	8d 64 24 20          	lea    0x20(%esp),%esp
f0103093:	5e                   	pop    %esi
f0103094:	5f                   	pop    %edi
f0103095:	5d                   	pop    %ebp
f0103096:	c3                   	ret    
f0103097:	90                   	nop
f0103098:	85 c9                	test   %ecx,%ecx
f010309a:	75 0b                	jne    f01030a7 <__umoddi3+0x77>
f010309c:	b8 01 00 00 00       	mov    $0x1,%eax
f01030a1:	31 d2                	xor    %edx,%edx
f01030a3:	f7 f1                	div    %ecx
f01030a5:	89 c1                	mov    %eax,%ecx
f01030a7:	89 f0                	mov    %esi,%eax
f01030a9:	31 d2                	xor    %edx,%edx
f01030ab:	f7 f1                	div    %ecx
f01030ad:	8b 45 f0             	mov    -0x10(%ebp),%eax
f01030b0:	f7 f1                	div    %ecx
f01030b2:	eb a6                	jmp    f010305a <__umoddi3+0x2a>
f01030b4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f01030b8:	89 f2                	mov    %esi,%edx
f01030ba:	8d 64 24 20          	lea    0x20(%esp),%esp
f01030be:	5e                   	pop    %esi
f01030bf:	5f                   	pop    %edi
f01030c0:	5d                   	pop    %ebp
f01030c1:	c3                   	ret    
f01030c2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f01030c8:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
f01030cc:	c7 45 f0 20 00 00 00 	movl   $0x20,-0x10(%ebp)
f01030d3:	8b 45 ec             	mov    -0x14(%ebp),%eax
f01030d6:	29 45 f0             	sub    %eax,-0x10(%ebp)
f01030d9:	d3 e7                	shl    %cl,%edi
f01030db:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01030de:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
f01030e2:	89 f2                	mov    %esi,%edx
f01030e4:	d3 e8                	shr    %cl,%eax
f01030e6:	09 f8                	or     %edi,%eax
f01030e8:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
f01030ec:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f01030ef:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01030f2:	d3 e0                	shl    %cl,%eax
f01030f4:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
f01030f8:	89 45 f4             	mov    %eax,-0xc(%ebp)
f01030fb:	8b 45 e8             	mov    -0x18(%ebp),%eax
f01030fe:	d3 ea                	shr    %cl,%edx
f0103100:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
f0103104:	d3 e6                	shl    %cl,%esi
f0103106:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
f010310a:	d3 e8                	shr    %cl,%eax
f010310c:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
f0103110:	09 f0                	or     %esi,%eax
f0103112:	8b 75 e8             	mov    -0x18(%ebp),%esi
f0103115:	d3 e6                	shl    %cl,%esi
f0103117:	f7 75 e4             	divl   -0x1c(%ebp)
f010311a:	89 75 e8             	mov    %esi,-0x18(%ebp)
f010311d:	89 d6                	mov    %edx,%esi
f010311f:	f7 65 f4             	mull   -0xc(%ebp)
f0103122:	89 d7                	mov    %edx,%edi
f0103124:	89 c2                	mov    %eax,%edx
f0103126:	39 fe                	cmp    %edi,%esi
f0103128:	89 f9                	mov    %edi,%ecx
f010312a:	72 30                	jb     f010315c <__umoddi3+0x12c>
f010312c:	39 45 e8             	cmp    %eax,-0x18(%ebp)
f010312f:	72 27                	jb     f0103158 <__umoddi3+0x128>
f0103131:	8b 45 e8             	mov    -0x18(%ebp),%eax
f0103134:	29 d0                	sub    %edx,%eax
f0103136:	19 ce                	sbb    %ecx,%esi
f0103138:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
f010313c:	89 f2                	mov    %esi,%edx
f010313e:	d3 e8                	shr    %cl,%eax
f0103140:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
f0103144:	d3 e2                	shl    %cl,%edx
f0103146:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
f010314a:	09 d0                	or     %edx,%eax
f010314c:	89 f2                	mov    %esi,%edx
f010314e:	d3 ea                	shr    %cl,%edx
f0103150:	8d 64 24 20          	lea    0x20(%esp),%esp
f0103154:	5e                   	pop    %esi
f0103155:	5f                   	pop    %edi
f0103156:	5d                   	pop    %ebp
f0103157:	c3                   	ret    
f0103158:	39 fe                	cmp    %edi,%esi
f010315a:	75 d5                	jne    f0103131 <__umoddi3+0x101>
f010315c:	89 f9                	mov    %edi,%ecx
f010315e:	89 c2                	mov    %eax,%edx
f0103160:	2b 55 f4             	sub    -0xc(%ebp),%edx
f0103163:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
f0103166:	eb c9                	jmp    f0103131 <__umoddi3+0x101>
f0103168:	39 f7                	cmp    %esi,%edi
f010316a:	0f 82 10 ff ff ff    	jb     f0103080 <__umoddi3+0x50>
f0103170:	e9 17 ff ff ff       	jmp    f010308c <__umoddi3+0x5c>
