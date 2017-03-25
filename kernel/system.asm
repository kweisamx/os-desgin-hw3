
kernel/system:     file format elf32-i386


Disassembly of section .text:

00100000 <_start>:

.globl _start

.text
_start:
	movw	$0x1234,0x472			# warm boot
  100000:	66 c7 05 72 04 00 00 	movw   $0x1234,0x472
  100007:	34 12 

	# Setup kernel stack
	movl $0, %ebp
  100009:	bd 00 00 00 00       	mov    $0x0,%ebp
	movl $(bootstacktop), %esp
  10000e:	bc 20 b3 10 00       	mov    $0x10b320,%esp

	call kernel_main
  100013:	e8 04 00 00 00       	call   10001c <kernel_main>

00100018 <die>:
die:
	jmp die
  100018:	eb fe                	jmp    100018 <die>
	...

0010001c <kernel_main>:
#include <kernel/trap.h>
#include <kernel/picirq.h>

extern void init_video(void);
void kernel_main(void)
{
  10001c:	83 ec 0c             	sub    $0xc,%esp
	init_video();
  10001f:	e8 53 04 00 00       	call   100477 <init_video>

	pic_init();
  100024:	e8 3f 00 00 00       	call   100068 <pic_init>
  /* TODO: You should uncomment them
   */
	 kbd_init();
  100029:	e8 08 02 00 00       	call   100236 <kbd_init>
	 timer_init();
  10002e:	e8 d0 09 00 00       	call   100a03 <timer_init>
	 trap_init();
  100033:	e8 73 06 00 00       	call   1006ab <trap_init>

	/* Enable interrupt */
	__asm __volatile("sti");
  100038:	fb                   	sti    

	shell();
}
  100039:	83 c4 0c             	add    $0xc,%esp
	 trap_init();

	/* Enable interrupt */
	__asm __volatile("sti");

	shell();
  10003c:	e9 86 08 00 00       	jmp    1008c7 <shell>
  100041:	00 00                	add    %al,(%eax)
	...

00100044 <irq_setmask_8259A>:
		irq_setmask_8259A(irq_mask_8259A);
}

void
irq_setmask_8259A(uint16_t mask)
{
  100044:	8b 54 24 04          	mov    0x4(%esp),%edx
	int i;
	irq_mask_8259A = mask;
	if (!didinit)
  100048:	80 3d 20 b3 10 00 00 	cmpb   $0x0,0x10b320
		irq_setmask_8259A(irq_mask_8259A);
}

void
irq_setmask_8259A(uint16_t mask)
{
  10004f:	89 d0                	mov    %edx,%eax
	int i;
	irq_mask_8259A = mask;
  100051:	66 89 15 00 30 10 00 	mov    %dx,0x103000
	if (!didinit)
  100058:	74 0d                	je     100067 <irq_setmask_8259A+0x23>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
  10005a:	ba 21 00 00 00       	mov    $0x21,%edx
  10005f:	ee                   	out    %al,(%dx)
		return;
	outb(IO_PIC1+1, (char)mask);
	outb(IO_PIC2+1, (char)(mask >> 8));
  100060:	66 c1 e8 08          	shr    $0x8,%ax
  100064:	b2 a1                	mov    $0xa1,%dl
  100066:	ee                   	out    %al,(%dx)
  100067:	c3                   	ret    

00100068 <pic_init>:
static bool didinit;

/* Initialize the 8259A interrupt controllers. */
void
pic_init(void)
{
  100068:	57                   	push   %edi
  100069:	b9 21 00 00 00       	mov    $0x21,%ecx
  10006e:	56                   	push   %esi
  10006f:	b0 ff                	mov    $0xff,%al
  100071:	53                   	push   %ebx
  100072:	89 ca                	mov    %ecx,%edx
  100074:	ee                   	out    %al,(%dx)
  100075:	be a1 00 00 00       	mov    $0xa1,%esi
  10007a:	89 f2                	mov    %esi,%edx
  10007c:	ee                   	out    %al,(%dx)
  10007d:	bf 11 00 00 00       	mov    $0x11,%edi
  100082:	bb 20 00 00 00       	mov    $0x20,%ebx
  100087:	89 f8                	mov    %edi,%eax
  100089:	89 da                	mov    %ebx,%edx
  10008b:	ee                   	out    %al,(%dx)
  10008c:	b0 20                	mov    $0x20,%al
  10008e:	89 ca                	mov    %ecx,%edx
  100090:	ee                   	out    %al,(%dx)
  100091:	b0 04                	mov    $0x4,%al
  100093:	ee                   	out    %al,(%dx)
  100094:	b0 03                	mov    $0x3,%al
  100096:	ee                   	out    %al,(%dx)
  100097:	b1 a0                	mov    $0xa0,%cl
  100099:	89 f8                	mov    %edi,%eax
  10009b:	89 ca                	mov    %ecx,%edx
  10009d:	ee                   	out    %al,(%dx)
  10009e:	b0 28                	mov    $0x28,%al
  1000a0:	89 f2                	mov    %esi,%edx
  1000a2:	ee                   	out    %al,(%dx)
  1000a3:	b0 02                	mov    $0x2,%al
  1000a5:	ee                   	out    %al,(%dx)
  1000a6:	b0 01                	mov    $0x1,%al
  1000a8:	ee                   	out    %al,(%dx)
  1000a9:	bf 68 00 00 00       	mov    $0x68,%edi
  1000ae:	89 da                	mov    %ebx,%edx
  1000b0:	89 f8                	mov    %edi,%eax
  1000b2:	ee                   	out    %al,(%dx)
  1000b3:	be 0a 00 00 00       	mov    $0xa,%esi
  1000b8:	89 f0                	mov    %esi,%eax
  1000ba:	ee                   	out    %al,(%dx)
  1000bb:	89 f8                	mov    %edi,%eax
  1000bd:	89 ca                	mov    %ecx,%edx
  1000bf:	ee                   	out    %al,(%dx)
  1000c0:	89 f0                	mov    %esi,%eax
  1000c2:	ee                   	out    %al,(%dx)
	outb(IO_PIC1, 0x0a);             /* read IRR by default */

	outb(IO_PIC2, 0x68);               /* OCW3 */
	outb(IO_PIC2, 0x0a);               /* OCW3 */

	if (irq_mask_8259A != 0xFFFF)
  1000c3:	66 a1 00 30 10 00    	mov    0x103000,%ax

/* Initialize the 8259A interrupt controllers. */
void
pic_init(void)
{
	didinit = 1;
  1000c9:	c6 05 20 b3 10 00 01 	movb   $0x1,0x10b320
	outb(IO_PIC1, 0x0a);             /* read IRR by default */

	outb(IO_PIC2, 0x68);               /* OCW3 */
	outb(IO_PIC2, 0x0a);               /* OCW3 */

	if (irq_mask_8259A != 0xFFFF)
  1000d0:	66 83 f8 ff          	cmp    $0xffffffff,%ax
  1000d4:	74 0a                	je     1000e0 <pic_init+0x78>
		irq_setmask_8259A(irq_mask_8259A);
  1000d6:	0f b7 c0             	movzwl %ax,%eax
  1000d9:	50                   	push   %eax
  1000da:	e8 65 ff ff ff       	call   100044 <irq_setmask_8259A>
  1000df:	58                   	pop    %eax
}
  1000e0:	5b                   	pop    %ebx
  1000e1:	5e                   	pop    %esi
  1000e2:	5f                   	pop    %edi
  1000e3:	c3                   	ret    

001000e4 <kbd_proc_data>:
 * Get data from the keyboard.  If we finish a character, return it.  Else 0.
 * Return -1 if no data.
 */
static int
kbd_proc_data(void)
{
  1000e4:	53                   	push   %ebx

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
  1000e5:	ba 64 00 00 00       	mov    $0x64,%edx
  1000ea:	83 ec 08             	sub    $0x8,%esp
  1000ed:	ec                   	in     (%dx),%al
  1000ee:	88 c2                	mov    %al,%dl
	int c;
	uint8_t data;
	static uint32_t shift;

	if ((inb(KBSTATP) & KBS_DIB) == 0)
		return -1;
  1000f0:	83 c8 ff             	or     $0xffffffff,%eax
{
	int c;
	uint8_t data;
	static uint32_t shift;

	if ((inb(KBSTATP) & KBS_DIB) == 0)
  1000f3:	80 e2 01             	and    $0x1,%dl
  1000f6:	0f 84 d2 00 00 00    	je     1001ce <kbd_proc_data+0xea>
  1000fc:	ba 60 00 00 00       	mov    $0x60,%edx
  100101:	ec                   	in     (%dx),%al
		return -1;

	data = inb(KBDATAP);

	if (data == 0xE0) {
  100102:	3c e0                	cmp    $0xe0,%al
  100104:	88 c1                	mov    %al,%cl
  100106:	75 09                	jne    100111 <kbd_proc_data+0x2d>
		// E0 escape character
		shift |= E0ESC;
  100108:	83 0d 2c b5 10 00 40 	orl    $0x40,0x10b52c
  10010f:	eb 2d                	jmp    10013e <kbd_proc_data+0x5a>
		return 0;
	} else if (data & 0x80) {
  100111:	84 c0                	test   %al,%al
  100113:	8b 15 2c b5 10 00    	mov    0x10b52c,%edx
  100119:	79 2a                	jns    100145 <kbd_proc_data+0x61>
		// Key released
		data = (shift & E0ESC ? data : data & 0x7F);
  10011b:	88 c1                	mov    %al,%cl
  10011d:	83 e1 7f             	and    $0x7f,%ecx
  100120:	f6 c2 40             	test   $0x40,%dl
  100123:	0f 45 c8             	cmovne %eax,%ecx
		shift &= ~(shiftcode[data] | E0ESC);
  100126:	0f b6 c9             	movzbl %cl,%ecx
  100129:	8a 81 ec 17 10 00    	mov    0x1017ec(%ecx),%al
  10012f:	83 c8 40             	or     $0x40,%eax
  100132:	0f b6 c0             	movzbl %al,%eax
  100135:	f7 d0                	not    %eax
  100137:	21 d0                	and    %edx,%eax
  100139:	a3 2c b5 10 00       	mov    %eax,0x10b52c
		return 0;
  10013e:	31 c0                	xor    %eax,%eax
  100140:	e9 89 00 00 00       	jmp    1001ce <kbd_proc_data+0xea>
	} else if (shift & E0ESC) {
  100145:	f6 c2 40             	test   $0x40,%dl
  100148:	74 0c                	je     100156 <kbd_proc_data+0x72>
		// Last character was an E0 escape; or with 0x80
		data |= 0x80;
		shift &= ~E0ESC;
  10014a:	83 e2 bf             	and    $0xffffffbf,%edx
		data = (shift & E0ESC ? data : data & 0x7F);
		shift &= ~(shiftcode[data] | E0ESC);
		return 0;
	} else if (shift & E0ESC) {
		// Last character was an E0 escape; or with 0x80
		data |= 0x80;
  10014d:	83 c9 80             	or     $0xffffff80,%ecx
		shift &= ~E0ESC;
  100150:	89 15 2c b5 10 00    	mov    %edx,0x10b52c
	}

	shift |= shiftcode[data];
  100156:	0f b6 c9             	movzbl %cl,%ecx
	shift ^= togglecode[data];
  100159:	0f b6 81 ec 18 10 00 	movzbl 0x1018ec(%ecx),%eax
		// Last character was an E0 escape; or with 0x80
		data |= 0x80;
		shift &= ~E0ESC;
	}

	shift |= shiftcode[data];
  100160:	0f b6 91 ec 17 10 00 	movzbl 0x1017ec(%ecx),%edx
  100167:	0b 15 2c b5 10 00    	or     0x10b52c,%edx
	shift ^= togglecode[data];
  10016d:	31 c2                	xor    %eax,%edx

	c = charcode[shift & (CTL | SHIFT)][data];
  10016f:	89 d0                	mov    %edx,%eax
  100171:	83 e0 03             	and    $0x3,%eax
	if (shift & CAPSLOCK) {
  100174:	f6 c2 08             	test   $0x8,%dl
	}

	shift |= shiftcode[data];
	shift ^= togglecode[data];

	c = charcode[shift & (CTL | SHIFT)][data];
  100177:	8b 04 85 ec 19 10 00 	mov    0x1019ec(,%eax,4),%eax
		data |= 0x80;
		shift &= ~E0ESC;
	}

	shift |= shiftcode[data];
	shift ^= togglecode[data];
  10017e:	89 15 2c b5 10 00    	mov    %edx,0x10b52c

	c = charcode[shift & (CTL | SHIFT)][data];
  100184:	0f b6 04 08          	movzbl (%eax,%ecx,1),%eax
	if (shift & CAPSLOCK) {
  100188:	74 19                	je     1001a3 <kbd_proc_data+0xbf>
		if ('a' <= c && c <= 'z')
  10018a:	8d 48 9f             	lea    -0x61(%eax),%ecx
  10018d:	83 f9 19             	cmp    $0x19,%ecx
  100190:	77 05                	ja     100197 <kbd_proc_data+0xb3>
			c += 'A' - 'a';
  100192:	83 e8 20             	sub    $0x20,%eax
  100195:	eb 0c                	jmp    1001a3 <kbd_proc_data+0xbf>
		else if ('A' <= c && c <= 'Z')
  100197:	8d 58 bf             	lea    -0x41(%eax),%ebx
			c += 'a' - 'A';
  10019a:	8d 48 20             	lea    0x20(%eax),%ecx
  10019d:	83 fb 19             	cmp    $0x19,%ebx
  1001a0:	0f 46 c1             	cmovbe %ecx,%eax
	}

	// Process special keys
	// Ctrl-Alt-Del: reboot
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
  1001a3:	3d e9 00 00 00       	cmp    $0xe9,%eax
  1001a8:	75 24                	jne    1001ce <kbd_proc_data+0xea>
  1001aa:	f7 d2                	not    %edx
  1001ac:	80 e2 06             	and    $0x6,%dl
  1001af:	75 1d                	jne    1001ce <kbd_proc_data+0xea>
		cprintf("Rebooting!\n");
  1001b1:	83 ec 0c             	sub    $0xc,%esp
  1001b4:	68 e0 17 10 00       	push   $0x1017e0
  1001b9:	e8 dc 05 00 00       	call   10079a <cprintf>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
  1001be:	ba 92 00 00 00       	mov    $0x92,%edx
  1001c3:	b0 03                	mov    $0x3,%al
  1001c5:	ee                   	out    %al,(%dx)
  1001c6:	b8 e9 00 00 00       	mov    $0xe9,%eax
  1001cb:	83 c4 10             	add    $0x10,%esp
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
}
  1001ce:	83 c4 08             	add    $0x8,%esp
  1001d1:	5b                   	pop    %ebx
  1001d2:	c3                   	ret    

001001d3 <cons_getc>:
	// so that this function works even when interrupts are disabled
	// (e.g., when called from the kernel monitor).
	//kbd_intr();

	// grab the next character from the input buffer.
	if (cons.rpos != cons.wpos) {
  1001d3:	8b 15 24 b5 10 00    	mov    0x10b524,%edx
		c = cons.buf[cons.rpos++];
		if (cons.rpos == CONSBUFSIZE)
			cons.rpos = 0;
		return c;
	}
	return 0;
  1001d9:	31 c0                	xor    %eax,%eax
	// so that this function works even when interrupts are disabled
	// (e.g., when called from the kernel monitor).
	//kbd_intr();

	// grab the next character from the input buffer.
	if (cons.rpos != cons.wpos) {
  1001db:	3b 15 28 b5 10 00    	cmp    0x10b528,%edx
  1001e1:	74 1b                	je     1001fe <cons_getc+0x2b>
		c = cons.buf[cons.rpos++];
  1001e3:	8d 4a 01             	lea    0x1(%edx),%ecx
  1001e6:	0f b6 82 24 b3 10 00 	movzbl 0x10b324(%edx),%eax
		if (cons.rpos == CONSBUFSIZE)
			cons.rpos = 0;
  1001ed:	31 d2                	xor    %edx,%edx
  1001ef:	81 f9 00 02 00 00    	cmp    $0x200,%ecx
  1001f5:	0f 45 d1             	cmovne %ecx,%edx
  1001f8:	89 15 24 b5 10 00    	mov    %edx,0x10b524
		return c;
	}
	return 0;
}
  1001fe:	c3                   	ret    

001001ff <kbd_intr>:
/* 
 *  Note: The interrupt handler
 */
void
kbd_intr(void)
{
  1001ff:	53                   	push   %ebx
	while ((c = (*proc)()) != -1) {
		if (c == 0)
			continue;
		cons.buf[cons.wpos++] = c;
		if (cons.wpos == CONSBUFSIZE)
			cons.wpos = 0;
  100200:	31 db                	xor    %ebx,%ebx
/* 
 *  Note: The interrupt handler
 */
void
kbd_intr(void)
{
  100202:	83 ec 08             	sub    $0x8,%esp
  100205:	eb 20                	jmp    100227 <kbd_intr+0x28>
cons_intr(int (*proc)(void))
{
	int c;

	while ((c = (*proc)()) != -1) {
		if (c == 0)
  100207:	85 c0                	test   %eax,%eax
  100209:	74 1c                	je     100227 <kbd_intr+0x28>
			continue;
		cons.buf[cons.wpos++] = c;
  10020b:	8b 15 28 b5 10 00    	mov    0x10b528,%edx
  100211:	88 82 24 b3 10 00    	mov    %al,0x10b324(%edx)
  100217:	8d 42 01             	lea    0x1(%edx),%eax
		if (cons.wpos == CONSBUFSIZE)
			cons.wpos = 0;
  10021a:	3d 00 02 00 00       	cmp    $0x200,%eax
  10021f:	0f 44 c3             	cmove  %ebx,%eax
  100222:	a3 28 b5 10 00       	mov    %eax,0x10b528
static void
cons_intr(int (*proc)(void))
{
	int c;

	while ((c = (*proc)()) != -1) {
  100227:	e8 b8 fe ff ff       	call   1000e4 <kbd_proc_data>
  10022c:	83 f8 ff             	cmp    $0xffffffff,%eax
  10022f:	75 d6                	jne    100207 <kbd_intr+0x8>
 */
void
kbd_intr(void)
{
	cons_intr(kbd_proc_data);
}
  100231:	83 c4 08             	add    $0x8,%esp
  100234:	5b                   	pop    %ebx
  100235:	c3                   	ret    

00100236 <kbd_init>:

void kbd_init(void)
{
  100236:	83 ec 0c             	sub    $0xc,%esp
	// Drain the kbd buffer so that Bochs generates interrupts.
  cons.rpos = 0;
  100239:	c7 05 24 b5 10 00 00 	movl   $0x0,0x10b524
  100240:	00 00 00 
  cons.wpos = 0;
  100243:	c7 05 28 b5 10 00 00 	movl   $0x0,0x10b528
  10024a:	00 00 00 
	kbd_intr();
  10024d:	e8 ad ff ff ff       	call   1001ff <kbd_intr>
	irq_setmask_8259A(irq_mask_8259A & ~(1<<IRQ_KBD));
  100252:	0f b7 05 00 30 10 00 	movzwl 0x103000,%eax
  100259:	83 ec 0c             	sub    $0xc,%esp
  10025c:	25 fd ff 00 00       	and    $0xfffd,%eax
  100261:	50                   	push   %eax
  100262:	e8 dd fd ff ff       	call   100044 <irq_setmask_8259A>
}
  100267:	83 c4 1c             	add    $0x1c,%esp
  10026a:	c3                   	ret    

0010026b <getc>:
/* high-level console I/O */
int getc(void)
{
	int c;

	while ((c = cons_getc()) == 0)
  10026b:	e8 63 ff ff ff       	call   1001d3 <cons_getc>
  100270:	85 c0                	test   %eax,%eax
  100272:	74 f7                	je     10026b <getc>
		/* do nothing */;
	return c;
}
  100274:	c3                   	ret    
  100275:	00 00                	add    %al,(%eax)
	...

00100278 <scroll>:
int attrib = 0x0F;
int csr_x = 0, csr_y = 0;

/* Scrolls the screen */
void scroll(void)
{
  100278:	56                   	push   %esi
  100279:	53                   	push   %ebx
  10027a:	83 ec 04             	sub    $0x4,%esp
    /* A blank is defined as a space... we need to give it
    *  backcolor too */
    blank = 0x0 | (attrib << 8);

    /* Row 25 is the end, this means we need to scroll up */
    if(csr_y >= 25)
  10027d:	8b 1d 34 b5 10 00    	mov    0x10b534,%ebx
{
    unsigned short blank, temp;

    /* A blank is defined as a space... we need to give it
    *  backcolor too */
    blank = 0x0 | (attrib << 8);
  100283:	8b 35 04 33 10 00    	mov    0x103304,%esi

    /* Row 25 is the end, this means we need to scroll up */
    if(csr_y >= 25)
  100289:	83 fb 18             	cmp    $0x18,%ebx
  10028c:	7e 58                	jle    1002e6 <scroll+0x6e>
    {
        /* Move the current text chunk that makes up the screen
        *  back in the buffer by a line */
        temp = csr_y - 25 + 1;
  10028e:	83 eb 18             	sub    $0x18,%ebx
        memcpy (textmemptr, textmemptr + temp * 80, (25 - temp) * 80 * 2);
  100291:	a1 40 b9 10 00       	mov    0x10b940,%eax
  100296:	0f b7 db             	movzwl %bx,%ebx
  100299:	52                   	push   %edx
  10029a:	69 d3 60 ff ff ff    	imul   $0xffffff60,%ebx,%edx
{
    unsigned short blank, temp;

    /* A blank is defined as a space... we need to give it
    *  backcolor too */
    blank = 0x0 | (attrib << 8);
  1002a0:	c1 e6 08             	shl    $0x8,%esi
        temp = csr_y - 25 + 1;
        memcpy (textmemptr, textmemptr + temp * 80, (25 - temp) * 80 * 2);

        /* Finally, we set the chunk of memory that occupies
        *  the last line of text to our 'blank' character */
        memset (textmemptr + (25 - temp) * 80, blank, 80);
  1002a3:	0f b7 f6             	movzwl %si,%esi
    if(csr_y >= 25)
    {
        /* Move the current text chunk that makes up the screen
        *  back in the buffer by a line */
        temp = csr_y - 25 + 1;
        memcpy (textmemptr, textmemptr + temp * 80, (25 - temp) * 80 * 2);
  1002a6:	81 c2 a0 0f 00 00    	add    $0xfa0,%edx
  1002ac:	52                   	push   %edx
  1002ad:	69 d3 a0 00 00 00    	imul   $0xa0,%ebx,%edx

        /* Finally, we set the chunk of memory that occupies
        *  the last line of text to our 'blank' character */
        memset (textmemptr + (25 - temp) * 80, blank, 80);
  1002b3:	6b db b0             	imul   $0xffffffb0,%ebx,%ebx
    if(csr_y >= 25)
    {
        /* Move the current text chunk that makes up the screen
        *  back in the buffer by a line */
        temp = csr_y - 25 + 1;
        memcpy (textmemptr, textmemptr + temp * 80, (25 - temp) * 80 * 2);
  1002b6:	8d 14 10             	lea    (%eax,%edx,1),%edx
  1002b9:	52                   	push   %edx
  1002ba:	50                   	push   %eax
  1002bb:	e8 29 11 00 00       	call   1013e9 <memcpy>

        /* Finally, we set the chunk of memory that occupies
        *  the last line of text to our 'blank' character */
        memset (textmemptr + (25 - temp) * 80, blank, 80);
  1002c0:	83 c4 0c             	add    $0xc,%esp
  1002c3:	8d 84 1b a0 0f 00 00 	lea    0xfa0(%ebx,%ebx,1),%eax
  1002ca:	03 05 40 b9 10 00    	add    0x10b940,%eax
  1002d0:	6a 50                	push   $0x50
  1002d2:	56                   	push   %esi
  1002d3:	50                   	push   %eax
  1002d4:	e8 36 10 00 00       	call   10130f <memset>
        csr_y = 25 - 1;
  1002d9:	83 c4 10             	add    $0x10,%esp
  1002dc:	c7 05 34 b5 10 00 18 	movl   $0x18,0x10b534
  1002e3:	00 00 00 
    }
}
  1002e6:	83 c4 04             	add    $0x4,%esp
  1002e9:	5b                   	pop    %ebx
  1002ea:	5e                   	pop    %esi
  1002eb:	c3                   	ret    

001002ec <move_csr>:
    unsigned short temp;

    /* The equation for finding the index in a linear
    *  chunk of memory can be represented by:
    *  Index = [(y * width) + x] */
    temp = csr_y * 80 + csr_x;
  1002ec:	66 6b 0d 34 b5 10 00 	imul   $0x50,0x10b534,%cx
  1002f3:	50 
  1002f4:	ba d4 03 00 00       	mov    $0x3d4,%edx
  1002f9:	03 0d 30 b5 10 00    	add    0x10b530,%ecx
  1002ff:	b0 0e                	mov    $0xe,%al
  100301:	ee                   	out    %al,(%dx)
    *  where the hardware cursor is to be 'blinking'. To
    *  learn more, you should look up some VGA specific
    *  programming documents. A great start to graphics:
    *  http://www.brackeen.com/home/vga */
    outb(0x3D4, 14);
    outb(0x3D5, temp >> 8);
  100302:	89 c8                	mov    %ecx,%eax
  100304:	b2 d5                	mov    $0xd5,%dl
  100306:	66 c1 e8 08          	shr    $0x8,%ax
  10030a:	ee                   	out    %al,(%dx)
  10030b:	b0 0f                	mov    $0xf,%al
  10030d:	b2 d4                	mov    $0xd4,%dl
  10030f:	ee                   	out    %al,(%dx)
  100310:	b2 d5                	mov    $0xd5,%dl
  100312:	88 c8                	mov    %cl,%al
  100314:	ee                   	out    %al,(%dx)
    outb(0x3D4, 15);
    outb(0x3D5, temp);
}
  100315:	c3                   	ret    

00100316 <cls>:

/* Clears the screen */
void cls()
{
  100316:	56                   	push   %esi
  100317:	53                   	push   %ebx
    unsigned short blank;
    int i;

    /* Again, we need the 'short' that will be used to
    *  represent a space with color */
    blank = 0x0 | (attrib << 8);
  100318:	31 db                	xor    %ebx,%ebx
    outb(0x3D5, temp);
}

/* Clears the screen */
void cls()
{
  10031a:	83 ec 04             	sub    $0x4,%esp
    unsigned short blank;
    int i;

    /* Again, we need the 'short' that will be used to
    *  represent a space with color */
    blank = 0x0 | (attrib << 8);
  10031d:	8b 35 04 33 10 00    	mov    0x103304,%esi
  100323:	c1 e6 08             	shl    $0x8,%esi

    /* Sets the entire screen to spaces in our current
    *  color */
    for(i = 0; i < 25; i++)
        memset (textmemptr + i * 80, blank, 80);
  100326:	0f b7 f6             	movzwl %si,%esi
  100329:	a1 40 b9 10 00       	mov    0x10b940,%eax
  10032e:	51                   	push   %ecx
  10032f:	6a 50                	push   $0x50
  100331:	56                   	push   %esi
  100332:	01 d8                	add    %ebx,%eax
  100334:	81 c3 a0 00 00 00    	add    $0xa0,%ebx
  10033a:	50                   	push   %eax
  10033b:	e8 cf 0f 00 00       	call   10130f <memset>
    *  represent a space with color */
    blank = 0x0 | (attrib << 8);

    /* Sets the entire screen to spaces in our current
    *  color */
    for(i = 0; i < 25; i++)
  100340:	83 c4 10             	add    $0x10,%esp
  100343:	81 fb a0 0f 00 00    	cmp    $0xfa0,%ebx
  100349:	75 de                	jne    100329 <cls+0x13>
        memset (textmemptr + i * 80, blank, 80);

    /* Update out virtual cursor, and then move the
    *  hardware cursor */
    csr_x = 0;
  10034b:	c7 05 30 b5 10 00 00 	movl   $0x0,0x10b530
  100352:	00 00 00 
    csr_y = 0;
  100355:	c7 05 34 b5 10 00 00 	movl   $0x0,0x10b534
  10035c:	00 00 00 
    move_csr();
}
  10035f:	83 c4 04             	add    $0x4,%esp
  100362:	5b                   	pop    %ebx
  100363:	5e                   	pop    %esi

    /* Update out virtual cursor, and then move the
    *  hardware cursor */
    csr_x = 0;
    csr_y = 0;
    move_csr();
  100364:	e9 83 ff ff ff       	jmp    1002ec <move_csr>

00100369 <putch>:
}

/* Puts a single character on the screen */
void putch(unsigned char c)
{
  100369:	53                   	push   %ebx
  10036a:	83 ec 08             	sub    $0x8,%esp
    unsigned short *where;
    unsigned short att = attrib << 8;
  10036d:	8b 0d 04 33 10 00    	mov    0x103304,%ecx
    move_csr();
}

/* Puts a single character on the screen */
void putch(unsigned char c)
{
  100373:	8a 44 24 10          	mov    0x10(%esp),%al
    unsigned short *where;
    unsigned short att = attrib << 8;
  100377:	c1 e1 08             	shl    $0x8,%ecx

    /* Handle a backspace, by moving the cursor back one space */
    if(c == 0x08)
  10037a:	3c 08                	cmp    $0x8,%al
  10037c:	75 21                	jne    10039f <putch+0x36>
    {
        if(csr_x != 0) {
  10037e:	a1 30 b5 10 00       	mov    0x10b530,%eax
  100383:	85 c0                	test   %eax,%eax
  100385:	74 7d                	je     100404 <putch+0x9b>
          where = (textmemptr-1) + (csr_y * 80 + csr_x);
  100387:	6b 15 34 b5 10 00 50 	imul   $0x50,0x10b534,%edx
  10038e:	8d 5c 10 ff          	lea    -0x1(%eax,%edx,1),%ebx
          *where = 0x0 | att;	/* Character AND attributes: color */
  100392:	8b 15 40 b9 10 00    	mov    0x10b940,%edx
          csr_x--;
  100398:	48                   	dec    %eax
    /* Handle a backspace, by moving the cursor back one space */
    if(c == 0x08)
    {
        if(csr_x != 0) {
          where = (textmemptr-1) + (csr_y * 80 + csr_x);
          *where = 0x0 | att;	/* Character AND attributes: color */
  100399:	66 89 0c 5a          	mov    %cx,(%edx,%ebx,2)
  10039d:	eb 0f                	jmp    1003ae <putch+0x45>
          csr_x--;
        }
    }
    /* Handles a tab by incrementing the cursor's x, but only
    *  to a point that will make it divisible by 8 */
    else if(c == 0x09)
  10039f:	3c 09                	cmp    $0x9,%al
  1003a1:	75 12                	jne    1003b5 <putch+0x4c>
    {
        csr_x = (csr_x + 8) & ~(8 - 1);
  1003a3:	a1 30 b5 10 00       	mov    0x10b530,%eax
  1003a8:	83 c0 08             	add    $0x8,%eax
  1003ab:	83 e0 f8             	and    $0xfffffff8,%eax
  1003ae:	a3 30 b5 10 00       	mov    %eax,0x10b530
  1003b3:	eb 4f                	jmp    100404 <putch+0x9b>
    }
    /* Handles a 'Carriage Return', which simply brings the
    *  cursor back to the margin */
    else if(c == '\r')
  1003b5:	3c 0d                	cmp    $0xd,%al
  1003b7:	75 0c                	jne    1003c5 <putch+0x5c>
    {
        csr_x = 0;
  1003b9:	c7 05 30 b5 10 00 00 	movl   $0x0,0x10b530
  1003c0:	00 00 00 
  1003c3:	eb 3f                	jmp    100404 <putch+0x9b>
    }
    /* We handle our newlines the way DOS and the BIOS do: we
    *  treat it as if a 'CR' was also there, so we bring the
    *  cursor to the margin and we increment the 'y' value */
    else if(c == '\n')
  1003c5:	3c 0a                	cmp    $0xa,%al
  1003c7:	75 12                	jne    1003db <putch+0x72>
    {
        csr_x = 0;
  1003c9:	c7 05 30 b5 10 00 00 	movl   $0x0,0x10b530
  1003d0:	00 00 00 
        csr_y++;
  1003d3:	ff 05 34 b5 10 00    	incl   0x10b534
  1003d9:	eb 29                	jmp    100404 <putch+0x9b>
    }
    /* Any character greater than and including a space, is a
    *  printable character. The equation for finding the index
    *  in a linear chunk of memory can be represented by:
    *  Index = [(y * width) + x] */
    else if(c >= ' ')
  1003db:	3c 1f                	cmp    $0x1f,%al
  1003dd:	76 25                	jbe    100404 <putch+0x9b>
    {
        where = textmemptr + (csr_y * 80 + csr_x);
  1003df:	8b 15 30 b5 10 00    	mov    0x10b530,%edx
        *where = c | att;	/* Character AND attributes: color */
  1003e5:	0f b6 c0             	movzbl %al,%eax
    *  printable character. The equation for finding the index
    *  in a linear chunk of memory can be represented by:
    *  Index = [(y * width) + x] */
    else if(c >= ' ')
    {
        where = textmemptr + (csr_y * 80 + csr_x);
  1003e8:	6b 1d 34 b5 10 00 50 	imul   $0x50,0x10b534,%ebx
        *where = c | att;	/* Character AND attributes: color */
  1003ef:	09 c8                	or     %ecx,%eax
  1003f1:	8b 0d 40 b9 10 00    	mov    0x10b940,%ecx
    *  printable character. The equation for finding the index
    *  in a linear chunk of memory can be represented by:
    *  Index = [(y * width) + x] */
    else if(c >= ' ')
    {
        where = textmemptr + (csr_y * 80 + csr_x);
  1003f7:	01 d3                	add    %edx,%ebx
        *where = c | att;	/* Character AND attributes: color */
        csr_x++;
  1003f9:	42                   	inc    %edx
    *  in a linear chunk of memory can be represented by:
    *  Index = [(y * width) + x] */
    else if(c >= ' ')
    {
        where = textmemptr + (csr_y * 80 + csr_x);
        *where = c | att;	/* Character AND attributes: color */
  1003fa:	66 89 04 59          	mov    %ax,(%ecx,%ebx,2)
        csr_x++;
  1003fe:	89 15 30 b5 10 00    	mov    %edx,0x10b530
    }

    /* If the cursor has reached the edge of the screen's width, we
    *  insert a new line in there */
    if(csr_x >= 80)
  100404:	83 3d 30 b5 10 00 4f 	cmpl   $0x4f,0x10b530
  10040b:	7e 10                	jle    10041d <putch+0xb4>
    {
        csr_x = 0;
        csr_y++;
  10040d:	ff 05 34 b5 10 00    	incl   0x10b534

    /* If the cursor has reached the edge of the screen's width, we
    *  insert a new line in there */
    if(csr_x >= 80)
    {
        csr_x = 0;
  100413:	c7 05 30 b5 10 00 00 	movl   $0x0,0x10b530
  10041a:	00 00 00 
        csr_y++;
    }

    /* Scroll the screen if needed, and finally move the cursor */
    scroll();
  10041d:	e8 56 fe ff ff       	call   100278 <scroll>
    move_csr();
}
  100422:	83 c4 08             	add    $0x8,%esp
  100425:	5b                   	pop    %ebx
        csr_y++;
    }

    /* Scroll the screen if needed, and finally move the cursor */
    scroll();
    move_csr();
  100426:	e9 c1 fe ff ff       	jmp    1002ec <move_csr>

0010042b <puts>:
}

/* Uses the above routine to output a string... */
void puts(unsigned char *text)
{
  10042b:	56                   	push   %esi
  10042c:	53                   	push   %ebx
    int i;

    for (i = 0; i < strlen(text); i++)
  10042d:	31 db                	xor    %ebx,%ebx
    move_csr();
}

/* Uses the above routine to output a string... */
void puts(unsigned char *text)
{
  10042f:	83 ec 04             	sub    $0x4,%esp
  100432:	8b 74 24 10          	mov    0x10(%esp),%esi
    int i;

    for (i = 0; i < strlen(text); i++)
  100436:	eb 11                	jmp    100449 <puts+0x1e>
    {
        putch(text[i]);
  100438:	0f b6 04 1e          	movzbl (%esi,%ebx,1),%eax
  10043c:	83 ec 0c             	sub    $0xc,%esp
/* Uses the above routine to output a string... */
void puts(unsigned char *text)
{
    int i;

    for (i = 0; i < strlen(text); i++)
  10043f:	43                   	inc    %ebx
    {
        putch(text[i]);
  100440:	50                   	push   %eax
  100441:	e8 23 ff ff ff       	call   100369 <putch>
/* Uses the above routine to output a string... */
void puts(unsigned char *text)
{
    int i;

    for (i = 0; i < strlen(text); i++)
  100446:	83 c4 10             	add    $0x10,%esp
  100449:	83 ec 0c             	sub    $0xc,%esp
  10044c:	56                   	push   %esi
  10044d:	e8 ee 0c 00 00       	call   101140 <strlen>
  100452:	83 c4 10             	add    $0x10,%esp
  100455:	39 c3                	cmp    %eax,%ebx
  100457:	7c df                	jl     100438 <puts+0xd>
    {
        putch(text[i]);
    }
}
  100459:	83 c4 04             	add    $0x4,%esp
  10045c:	5b                   	pop    %ebx
  10045d:	5e                   	pop    %esi
  10045e:	c3                   	ret    

0010045f <settextcolor>:
void settextcolor(unsigned char forecolor, unsigned char backcolor)
{
    /* Lab3: Use this function */
    /* Top 4 bit are the background, bottom 4 bytes
    *  are the foreground color */
    attrib = (backcolor << 4) | (forecolor & 0x0F);
  10045f:	0f b6 44 24 08       	movzbl 0x8(%esp),%eax
  100464:	0f b6 54 24 04       	movzbl 0x4(%esp),%edx
  100469:	c1 e0 04             	shl    $0x4,%eax
  10046c:	83 e2 0f             	and    $0xf,%edx
  10046f:	09 d0                	or     %edx,%eax
  100471:	a3 04 33 10 00       	mov    %eax,0x103304
}
  100476:	c3                   	ret    

00100477 <init_video>:

/* Sets our text-mode VGA pointer, then clears the screen for us */
void init_video(void)
{
  100477:	83 ec 0c             	sub    $0xc,%esp
    textmemptr = (unsigned short *)0xB8000;
  10047a:	c7 05 40 b9 10 00 00 	movl   $0xb8000,0x10b940
  100481:	80 0b 00 
    cls();
}
  100484:	83 c4 0c             	add    $0xc,%esp

/* Sets our text-mode VGA pointer, then clears the screen for us */
void init_video(void)
{
    textmemptr = (unsigned short *)0xB8000;
    cls();
  100487:	e9 8a fe ff ff       	jmp    100316 <cls>

0010048c <print_regs>:
}

/* For debugging */
void
print_regs(struct PushRegs *regs)
{
  10048c:	53                   	push   %ebx
  10048d:	83 ec 10             	sub    $0x10,%esp
  100490:	8b 5c 24 18          	mov    0x18(%esp),%ebx
	cprintf("  edi  0x%08x\n", regs->reg_edi);
  100494:	ff 33                	pushl  (%ebx)
  100496:	68 fc 19 10 00       	push   $0x1019fc
  10049b:	e8 fa 02 00 00       	call   10079a <cprintf>
	cprintf("  esi  0x%08x\n", regs->reg_esi);
  1004a0:	58                   	pop    %eax
  1004a1:	5a                   	pop    %edx
  1004a2:	ff 73 04             	pushl  0x4(%ebx)
  1004a5:	68 0b 1a 10 00       	push   $0x101a0b
  1004aa:	e8 eb 02 00 00       	call   10079a <cprintf>
	cprintf("  ebp  0x%08x\n", regs->reg_ebp);
  1004af:	5a                   	pop    %edx
  1004b0:	59                   	pop    %ecx
  1004b1:	ff 73 08             	pushl  0x8(%ebx)
  1004b4:	68 1a 1a 10 00       	push   $0x101a1a
  1004b9:	e8 dc 02 00 00       	call   10079a <cprintf>
	cprintf("  oesp 0x%08x\n", regs->reg_oesp);
  1004be:	59                   	pop    %ecx
  1004bf:	58                   	pop    %eax
  1004c0:	ff 73 0c             	pushl  0xc(%ebx)
  1004c3:	68 29 1a 10 00       	push   $0x101a29
  1004c8:	e8 cd 02 00 00       	call   10079a <cprintf>
	cprintf("  ebx  0x%08x\n", regs->reg_ebx);
  1004cd:	58                   	pop    %eax
  1004ce:	5a                   	pop    %edx
  1004cf:	ff 73 10             	pushl  0x10(%ebx)
  1004d2:	68 38 1a 10 00       	push   $0x101a38
  1004d7:	e8 be 02 00 00       	call   10079a <cprintf>
	cprintf("  edx  0x%08x\n", regs->reg_edx);
  1004dc:	5a                   	pop    %edx
  1004dd:	59                   	pop    %ecx
  1004de:	ff 73 14             	pushl  0x14(%ebx)
  1004e1:	68 47 1a 10 00       	push   $0x101a47
  1004e6:	e8 af 02 00 00       	call   10079a <cprintf>
	cprintf("  ecx  0x%08x\n", regs->reg_ecx);
  1004eb:	59                   	pop    %ecx
  1004ec:	58                   	pop    %eax
  1004ed:	ff 73 18             	pushl  0x18(%ebx)
  1004f0:	68 56 1a 10 00       	push   $0x101a56
  1004f5:	e8 a0 02 00 00       	call   10079a <cprintf>
	cprintf("  eax  0x%08x\n", regs->reg_eax);
  1004fa:	58                   	pop    %eax
  1004fb:	5a                   	pop    %edx
  1004fc:	ff 73 1c             	pushl  0x1c(%ebx)
  1004ff:	68 65 1a 10 00       	push   $0x101a65
  100504:	e8 91 02 00 00       	call   10079a <cprintf>
}
  100509:	83 c4 18             	add    $0x18,%esp
  10050c:	5b                   	pop    %ebx
  10050d:	c3                   	ret    

0010050e <print_trapframe>:
}

/* For debugging */
void
print_trapframe(struct Trapframe *tf)
{
  10050e:	56                   	push   %esi
  10050f:	53                   	push   %ebx
  100510:	83 ec 10             	sub    $0x10,%esp
  100513:	8b 5c 24 1c          	mov    0x1c(%esp),%ebx
	cprintf("TRAP frame at %p \n");
  100517:	68 c9 1a 10 00       	push   $0x101ac9
  10051c:	e8 79 02 00 00       	call   10079a <cprintf>
	print_regs(&tf->tf_regs);
  100521:	89 1c 24             	mov    %ebx,(%esp)
  100524:	e8 63 ff ff ff       	call   10048c <print_regs>
	cprintf("  es   0x----%04x\n", tf->tf_es);
  100529:	0f b7 43 20          	movzwl 0x20(%ebx),%eax
  10052d:	5a                   	pop    %edx
  10052e:	59                   	pop    %ecx
  10052f:	50                   	push   %eax
  100530:	68 dc 1a 10 00       	push   $0x101adc
  100535:	e8 60 02 00 00       	call   10079a <cprintf>
	cprintf("  ds   0x----%04x\n", tf->tf_ds);
  10053a:	5e                   	pop    %esi
  10053b:	58                   	pop    %eax
  10053c:	0f b7 43 24          	movzwl 0x24(%ebx),%eax
  100540:	50                   	push   %eax
  100541:	68 ef 1a 10 00       	push   $0x101aef
  100546:	e8 4f 02 00 00       	call   10079a <cprintf>
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
  10054b:	8b 43 28             	mov    0x28(%ebx),%eax
		"Alignment Check",
		"Machine-Check",
		"SIMD Floating-Point Exception"
	};

	if (trapno < sizeof(excnames)/sizeof(excnames[0]))
  10054e:	83 c4 10             	add    $0x10,%esp
  100551:	83 f8 13             	cmp    $0x13,%eax
  100554:	77 09                	ja     10055f <print_trapframe+0x51>
		return excnames[trapno];
  100556:	8b 14 85 d8 1c 10 00 	mov    0x101cd8(,%eax,4),%edx
  10055d:	eb 1d                	jmp    10057c <print_trapframe+0x6e>
	if (trapno == T_SYSCALL)
  10055f:	83 f8 30             	cmp    $0x30,%eax
		return "System call";
  100562:	ba 74 1a 10 00       	mov    $0x101a74,%edx
		"SIMD Floating-Point Exception"
	};

	if (trapno < sizeof(excnames)/sizeof(excnames[0]))
		return excnames[trapno];
	if (trapno == T_SYSCALL)
  100567:	74 13                	je     10057c <print_trapframe+0x6e>
		return "System call";
	if (trapno >= IRQ_OFFSET && trapno < IRQ_OFFSET + 16)
  100569:	8d 48 e0             	lea    -0x20(%eax),%ecx
		return "Hardware Interrupt";
  10056c:	ba 80 1a 10 00       	mov    $0x101a80,%edx
  100571:	83 f9 0f             	cmp    $0xf,%ecx
  100574:	b9 93 1a 10 00       	mov    $0x101a93,%ecx
  100579:	0f 47 d1             	cmova  %ecx,%edx
{
	cprintf("TRAP frame at %p \n");
	print_regs(&tf->tf_regs);
	cprintf("  es   0x----%04x\n", tf->tf_es);
	cprintf("  ds   0x----%04x\n", tf->tf_ds);
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
  10057c:	51                   	push   %ecx
  10057d:	52                   	push   %edx
  10057e:	50                   	push   %eax
  10057f:	68 02 1b 10 00       	push   $0x101b02
  100584:	e8 11 02 00 00       	call   10079a <cprintf>
	// If this trap was a page fault that just happened
	// (so %cr2 is meaningful), print the faulting linear address.
	if (tf == last_tf && tf->tf_trapno == T_PGFLT)
  100589:	83 c4 10             	add    $0x10,%esp
  10058c:	3b 1d 38 b5 10 00    	cmp    0x10b538,%ebx
  100592:	75 19                	jne    1005ad <print_trapframe+0x9f>
  100594:	83 7b 28 0e          	cmpl   $0xe,0x28(%ebx)
  100598:	75 13                	jne    1005ad <print_trapframe+0x9f>

static __inline uint32_t
rcr2(void)
{
	uint32_t val;
	__asm __volatile("movl %%cr2,%0" : "=r" (val));
  10059a:	0f 20 d0             	mov    %cr2,%eax
		cprintf("  cr2  0x%08x\n", rcr2());
  10059d:	52                   	push   %edx
  10059e:	52                   	push   %edx
  10059f:	50                   	push   %eax
  1005a0:	68 14 1b 10 00       	push   $0x101b14
  1005a5:	e8 f0 01 00 00       	call   10079a <cprintf>
  1005aa:	83 c4 10             	add    $0x10,%esp
	cprintf("  err  0x%08x", tf->tf_err);
  1005ad:	56                   	push   %esi
  1005ae:	56                   	push   %esi
  1005af:	ff 73 2c             	pushl  0x2c(%ebx)
  1005b2:	68 23 1b 10 00       	push   $0x101b23
  1005b7:	e8 de 01 00 00       	call   10079a <cprintf>
	// For page faults, print decoded fault error code:
	// U/K=fault occurred in user/kernel mode
	// W/R=a write/read caused the fault
	// PR=a protection violation caused the fault (NP=page not present).
	if (tf->tf_trapno == T_PGFLT)
  1005bc:	83 c4 10             	add    $0x10,%esp
  1005bf:	83 7b 28 0e          	cmpl   $0xe,0x28(%ebx)
  1005c3:	75 43                	jne    100608 <print_trapframe+0xfa>
		cprintf(" [%s, %s, %s]\n",
			tf->tf_err & 4 ? "user" : "kernel",
			tf->tf_err & 2 ? "write" : "read",
			tf->tf_err & 1 ? "protection" : "not-present");
  1005c5:	8b 73 2c             	mov    0x2c(%ebx),%esi
	// For page faults, print decoded fault error code:
	// U/K=fault occurred in user/kernel mode
	// W/R=a write/read caused the fault
	// PR=a protection violation caused the fault (NP=page not present).
	if (tf->tf_trapno == T_PGFLT)
		cprintf(" [%s, %s, %s]\n",
  1005c8:	b8 ad 1a 10 00       	mov    $0x101aad,%eax
  1005cd:	b9 a2 1a 10 00       	mov    $0x101aa2,%ecx
  1005d2:	ba b9 1a 10 00       	mov    $0x101ab9,%edx
  1005d7:	f7 c6 01 00 00 00    	test   $0x1,%esi
  1005dd:	0f 44 c8             	cmove  %eax,%ecx
  1005e0:	f7 c6 02 00 00 00    	test   $0x2,%esi
  1005e6:	b8 bf 1a 10 00       	mov    $0x101abf,%eax
  1005eb:	0f 44 d0             	cmove  %eax,%edx
  1005ee:	83 e6 04             	and    $0x4,%esi
  1005f1:	51                   	push   %ecx
  1005f2:	b8 c4 1a 10 00       	mov    $0x101ac4,%eax
  1005f7:	be f2 1d 10 00       	mov    $0x101df2,%esi
  1005fc:	52                   	push   %edx
  1005fd:	0f 44 c6             	cmove  %esi,%eax
  100600:	50                   	push   %eax
  100601:	68 31 1b 10 00       	push   $0x101b31
  100606:	eb 08                	jmp    100610 <print_trapframe+0x102>
			tf->tf_err & 4 ? "user" : "kernel",
			tf->tf_err & 2 ? "write" : "read",
			tf->tf_err & 1 ? "protection" : "not-present");
	else
		cprintf("\n");
  100608:	83 ec 0c             	sub    $0xc,%esp
  10060b:	68 da 1a 10 00       	push   $0x101ada
  100610:	e8 85 01 00 00       	call   10079a <cprintf>
  100615:	5a                   	pop    %edx
  100616:	59                   	pop    %ecx
	cprintf("  eip  0x%08x\n", tf->tf_eip);
  100617:	ff 73 30             	pushl  0x30(%ebx)
  10061a:	68 40 1b 10 00       	push   $0x101b40
  10061f:	e8 76 01 00 00       	call   10079a <cprintf>
	cprintf("  cs   0x----%04x\n", tf->tf_cs);
  100624:	5e                   	pop    %esi
  100625:	58                   	pop    %eax
  100626:	0f b7 43 34          	movzwl 0x34(%ebx),%eax
  10062a:	50                   	push   %eax
  10062b:	68 4f 1b 10 00       	push   $0x101b4f
  100630:	e8 65 01 00 00       	call   10079a <cprintf>
	cprintf("  flag 0x%08x\n", tf->tf_eflags);
  100635:	5a                   	pop    %edx
  100636:	59                   	pop    %ecx
  100637:	ff 73 38             	pushl  0x38(%ebx)
  10063a:	68 62 1b 10 00       	push   $0x101b62
  10063f:	e8 56 01 00 00       	call   10079a <cprintf>
	if ((tf->tf_cs & 3) != 0) {
  100644:	83 c4 10             	add    $0x10,%esp
  100647:	f6 43 34 03          	testb  $0x3,0x34(%ebx)
  10064b:	74 23                	je     100670 <print_trapframe+0x162>
		cprintf("  esp  0x%08x\n", tf->tf_esp);
  10064d:	50                   	push   %eax
  10064e:	50                   	push   %eax
  10064f:	ff 73 3c             	pushl  0x3c(%ebx)
  100652:	68 71 1b 10 00       	push   $0x101b71
  100657:	e8 3e 01 00 00       	call   10079a <cprintf>
		cprintf("  ss   0x----%04x\n", tf->tf_ss);
  10065c:	0f b7 43 40          	movzwl 0x40(%ebx),%eax
  100660:	59                   	pop    %ecx
  100661:	5e                   	pop    %esi
  100662:	50                   	push   %eax
  100663:	68 80 1b 10 00       	push   $0x101b80
  100668:	e8 2d 01 00 00       	call   10079a <cprintf>
  10066d:	83 c4 10             	add    $0x10,%esp
	}
}
  100670:	83 c4 04             	add    $0x4,%esp
  100673:	5b                   	pop    %ebx
  100674:	5e                   	pop    %esi
  100675:	c3                   	ret    

00100676 <default_trap_handler>:

/* 
 * Note: This is the called for every interrupt.
 */
void default_trap_handler(struct Trapframe *tf)
{
  100676:	83 ec 0c             	sub    $0xc,%esp
  100679:	8b 44 24 10          	mov    0x10(%esp),%eax
}

static void
trap_dispatch(struct Trapframe *tf)
{
    if(tf->tf_trapno == IRQ_OFFSET + IRQ_KBD)
  10067d:	8b 50 28             	mov    0x28(%eax),%edx
 */
void default_trap_handler(struct Trapframe *tf)
{
	// Record that tf is the last real trapframe so
	// print_trapframe can print some additional information.
	last_tf = tf;
  100680:	a3 38 b5 10 00       	mov    %eax,0x10b538
}

static void
trap_dispatch(struct Trapframe *tf)
{
    if(tf->tf_trapno == IRQ_OFFSET + IRQ_KBD)
  100685:	83 fa 21             	cmp    $0x21,%edx
  100688:	75 08                	jne    100692 <default_trap_handler+0x1c>
	// print_trapframe can print some additional information.
	last_tf = tf;

	// Dispatch based on what type of trap occurred
	trap_dispatch(tf);
}
  10068a:	83 c4 0c             	add    $0xc,%esp
static void
trap_dispatch(struct Trapframe *tf)
{
    if(tf->tf_trapno == IRQ_OFFSET + IRQ_KBD)
    {
        kbd_intr();
  10068d:	e9 6d fb ff ff       	jmp    1001ff <kbd_intr>
        return;
    }
    if(tf->tf_trapno == IRQ_OFFSET + IRQ_TIMER)
  100692:	83 fa 20             	cmp    $0x20,%edx
  100695:	75 08                	jne    10069f <default_trap_handler+0x29>
	// print_trapframe can print some additional information.
	last_tf = tf;

	// Dispatch based on what type of trap occurred
	trap_dispatch(tf);
}
  100697:	83 c4 0c             	add    $0xc,%esp
        kbd_intr();
        return;
    }
    if(tf->tf_trapno == IRQ_OFFSET + IRQ_TIMER)
    {
        timer_handler();
  10069a:	e9 57 03 00 00       	jmp    1009f6 <timer_handler>
   *       We prepared the keyboard handler and timer handler for you
   *       already. Please reference in kernel/kbd.c and kernel/timer.c
   */

	// Unexpected trap: The user process or the kernel has a bug.
	print_trapframe(tf);
  10069f:	89 44 24 10          	mov    %eax,0x10(%esp)
	// print_trapframe can print some additional information.
	last_tf = tf;

	// Dispatch based on what type of trap occurred
	trap_dispatch(tf);
}
  1006a3:	83 c4 0c             	add    $0xc,%esp
   *       We prepared the keyboard handler and timer handler for you
   *       already. Please reference in kernel/kbd.c and kernel/timer.c
   */

	// Unexpected trap: The user process or the kernel has a bug.
	print_trapframe(tf);
  1006a6:	e9 63 fe ff ff       	jmp    10050e <print_trapframe>

001006ab <trap_init>:
	trap_dispatch(tf);
}


void trap_init()
{
  1006ab:	31 d2                	xor    %edx,%edx
    int i;                                                                       
    for(i = 0;i < 256; i++)
  1006ad:	31 c0                	xor    %eax,%eax
        SETGATE(idt[i],0,GD_KT,64*i,0);
  1006af:	66 89 14 c5 44 b9 10 	mov    %dx,0x10b944(,%eax,8)
  1006b6:	00 


void trap_init()
{
    int i;                                                                       
    for(i = 0;i < 256; i++)
  1006b7:	83 c2 40             	add    $0x40,%edx
        SETGATE(idt[i],0,GD_KT,64*i,0);
  1006ba:	66 c7 04 c5 46 b9 10 	movw   $0x8,0x10b946(,%eax,8)
  1006c1:	00 08 00 
  1006c4:	c6 04 c5 48 b9 10 00 	movb   $0x0,0x10b948(,%eax,8)
  1006cb:	00 
  1006cc:	c6 04 c5 49 b9 10 00 	movb   $0x8e,0x10b949(,%eax,8)
  1006d3:	8e 
  1006d4:	66 c7 04 c5 4a b9 10 	movw   $0x0,0x10b94a(,%eax,8)
  1006db:	00 00 00 


void trap_init()
{
    int i;                                                                       
    for(i = 0;i < 256; i++)
  1006de:	40                   	inc    %eax
  1006df:	3d 00 01 00 00       	cmp    $0x100,%eax
  1006e4:	75 c9                	jne    1006af <trap_init+0x4>
        SETGATE(idt[i],0,GD_KT,64*i,0);
           
    SETGATE(idt[IRQ_OFFSET + IRQ_KBD],0,GD_KT,kbd,0);
  1006e6:	b8 4e 07 10 00       	mov    $0x10074e,%eax
  1006eb:	66 a3 4c ba 10 00    	mov    %ax,0x10ba4c
  1006f1:	c1 e8 10             	shr    $0x10,%eax
  1006f4:	66 a3 52 ba 10 00    	mov    %ax,0x10ba52
    SETGATE(idt[IRQ_OFFSET + IRQ_TIMER],0,GD_KT,timer,0);
  1006fa:	b8 48 07 10 00       	mov    $0x100748,%eax
  1006ff:	66 a3 44 ba 10 00    	mov    %ax,0x10ba44
  100705:	c1 e8 10             	shr    $0x10,%eax
  100708:	66 a3 4a ba 10 00    	mov    %ax,0x10ba4a
}

static __inline void
lidt(void *p)
{
	__asm __volatile("lidt (%0)" : : "r" (p));
  10070e:	b8 08 33 10 00       	mov    $0x103308,%eax
{
    int i;                                                                       
    for(i = 0;i < 256; i++)
        SETGATE(idt[i],0,GD_KT,64*i,0);
           
    SETGATE(idt[IRQ_OFFSET + IRQ_KBD],0,GD_KT,kbd,0);
  100713:	66 c7 05 4e ba 10 00 	movw   $0x8,0x10ba4e
  10071a:	08 00 
  10071c:	c6 05 50 ba 10 00 00 	movb   $0x0,0x10ba50
  100723:	c6 05 51 ba 10 00 8e 	movb   $0x8e,0x10ba51
    SETGATE(idt[IRQ_OFFSET + IRQ_TIMER],0,GD_KT,timer,0);
  10072a:	66 c7 05 46 ba 10 00 	movw   $0x8,0x10ba46
  100731:	08 00 
  100733:	c6 05 48 ba 10 00 00 	movb   $0x0,0x10ba48
  10073a:	c6 05 49 ba 10 00 8e 	movb   $0x8e,0x10ba49
  100741:	0f 01 18             	lidtl  (%eax)

	/* Keyboard interrupt setup */
	/* Timer Trap setup */
  /* Load IDT */

}
  100744:	c3                   	ret    
  100745:	00 00                	add    %al,(%eax)
	...

00100748 <timer>:
	pushl $(num);							\
	jmp _alltraps


.text
    TRAPHANDLER_NOEC(timer,IRQ_OFFSET + IRQ_TIMER)
  100748:	6a 00                	push   $0x0
  10074a:	6a 20                	push   $0x20
  10074c:	eb 06                	jmp    100754 <_alltraps>

0010074e <kbd>:
    TRAPHANDLER_NOEC(kbd,IRQ_OFFSET + IRQ_KBD)   
  10074e:	6a 00                	push   $0x0
  100750:	6a 21                	push   $0x21
  100752:	eb 00                	jmp    100754 <_alltraps>

00100754 <_alltraps>:
   *       CPU.
   *       You may want to leverage the "pusha" instructions to reduce your work of
   *       pushing all the general purpose registers into the stack.
	 */
/*because  in kernel stack ,we need to reverse the push order trapno ->     ds - > es -> pusha*/
    pushl %ds
  100754:	1e                   	push   %ds
    pushl %es
  100755:	06                   	push   %es
    pusha          #  push AX CX BX SP BP SI DI
  100756:	60                   	pusha  

    /*load kernel segment */
    movw $(GD_KT), %ax
  100757:	66 b8 08 00          	mov    $0x8,%ax
    movw %ax , %ds
  10075b:	8e d8                	mov    %eax,%ds
    movw %ax , %es
  10075d:	8e c0                	mov    %eax,%es

	pushl %esp # Pass a pointer which points to the Trapframe as an argument to default_trap_handler()
  10075f:	54                   	push   %esp
	call default_trap_handler
  100760:	e8 11 ff ff ff       	call   100676 <default_trap_handler>
    popl %esp
  100765:	5c                   	pop    %esp
    popa
  100766:	61                   	popa   
    popl %es
  100767:	07                   	pop    %es
    popl %ds
  100768:	1f                   	pop    %ds

	add $8, %esp # Cleans up the pushed error code and pushed ISR number
  100769:	83 c4 08             	add    $0x8,%esp
	iret # pops 5 things at once: CS, EIP, EFLAGS, SS, and ESP!
  10076c:	cf                   	iret   
  10076d:	00 00                	add    %al,(%eax)
	...

00100770 <vcprintf>:
#include <inc/stdio.h>


int
vcprintf(const char *fmt, va_list ap)
{
  100770:	83 ec 1c             	sub    $0x1c,%esp
	int cnt = 0;
  100773:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  10077a:	00 

	vprintfmt((void*)putch, &cnt, fmt, ap);
  10077b:	ff 74 24 24          	pushl  0x24(%esp)
  10077f:	ff 74 24 24          	pushl  0x24(%esp)
  100783:	8d 44 24 14          	lea    0x14(%esp),%eax
  100787:	50                   	push   %eax
  100788:	68 69 03 10 00       	push   $0x100369
  10078d:	e8 0d 04 00 00       	call   100b9f <vprintfmt>
	return cnt;
}
  100792:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  100796:	83 c4 2c             	add    $0x2c,%esp
  100799:	c3                   	ret    

0010079a <cprintf>:

int
cprintf(const char *fmt, ...)
{
  10079a:	83 ec 0c             	sub    $0xc,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  10079d:	8d 44 24 14          	lea    0x14(%esp),%eax
	cnt = vcprintf(fmt, ap);
  1007a1:	52                   	push   %edx
  1007a2:	52                   	push   %edx
  1007a3:	50                   	push   %eax
  1007a4:	ff 74 24 1c          	pushl  0x1c(%esp)
  1007a8:	e8 c3 ff ff ff       	call   100770 <vcprintf>
	va_end(ap);

	return cnt;
}
  1007ad:	83 c4 1c             	add    $0x1c,%esp
  1007b0:	c3                   	ret    
  1007b1:	00 00                	add    %al,(%eax)
	...

001007b4 <mon_kerninfo>:
    extern int kernel_load_addr;
    //extern int __STAB_BEGIN__;
    //extern int __STAB_END__;
    //extern int __STABSTR_BEGIN__;
    //extern int __STABSTR_END__;
    cprintf("Kernel code base start=0x%10x size = %ld\n",&kernel_load_addr,&etext-&kernel_load_addr);
  1007b4:	b8 d5 17 10 00       	mov    $0x1017d5,%eax
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
	return 0;
}

int mon_kerninfo(int argc, char **argv)
{
  1007b9:	83 ec 10             	sub    $0x10,%esp
    extern int kernel_load_addr;
    //extern int __STAB_BEGIN__;
    //extern int __STAB_END__;
    //extern int __STABSTR_BEGIN__;
    //extern int __STABSTR_END__;
    cprintf("Kernel code base start=0x%10x size = %ld\n",&kernel_load_addr,&etext-&kernel_load_addr);
  1007bc:	2d 00 00 10 00       	sub    $0x100000,%eax
  1007c1:	c1 f8 02             	sar    $0x2,%eax
  1007c4:	50                   	push   %eax
  1007c5:	68 00 00 10 00       	push   $0x100000
  1007ca:	68 28 1d 10 00       	push   $0x101d28
  1007cf:	e8 c6 ff ff ff       	call   10079a <cprintf>
    cprintf("Kernel data base start=0x%10x size = %ld\n",&data_start,&end-&data_start);
  1007d4:	b8 44 c1 10 00       	mov    $0x10c144,%eax
  1007d9:	83 c4 0c             	add    $0xc,%esp
  1007dc:	2d 00 30 10 00       	sub    $0x103000,%eax
  1007e1:	c1 f8 02             	sar    $0x2,%eax
  1007e4:	50                   	push   %eax
  1007e5:	68 00 30 10 00       	push   $0x103000
  1007ea:	68 52 1d 10 00       	push   $0x101d52
  1007ef:	e8 a6 ff ff ff       	call   10079a <cprintf>
    cprintf("Kernel executable memory footprint: %10xKB\n");
  1007f4:	c7 04 24 7c 1d 10 00 	movl   $0x101d7c,(%esp)
  1007fb:	e8 9a ff ff ff       	call   10079a <cprintf>
	return 0;
}
  100800:	31 c0                	xor    %eax,%eax
  100802:	83 c4 1c             	add    $0x1c,%esp
  100805:	c3                   	ret    

00100806 <mon_help>:
}
#define NCOMMANDS (sizeof(commands)/sizeof(commands[0]))


int mon_help(int argc, char **argv)
{
  100806:	83 ec 10             	sub    $0x10,%esp
	int i;

	for (i = 0; i < NCOMMANDS; i++)
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
  100809:	68 a8 1d 10 00       	push   $0x101da8
  10080e:	68 c6 1d 10 00       	push   $0x101dc6
  100813:	68 cb 1d 10 00       	push   $0x101dcb
  100818:	e8 7d ff ff ff       	call   10079a <cprintf>
  10081d:	83 c4 0c             	add    $0xc,%esp
  100820:	68 d4 1d 10 00       	push   $0x101dd4
  100825:	68 f9 1d 10 00       	push   $0x101df9
  10082a:	68 cb 1d 10 00       	push   $0x101dcb
  10082f:	e8 66 ff ff ff       	call   10079a <cprintf>
  100834:	83 c4 0c             	add    $0xc,%esp
  100837:	68 02 1e 10 00       	push   $0x101e02
  10083c:	68 16 1e 10 00       	push   $0x101e16
  100841:	68 cb 1d 10 00       	push   $0x101dcb
  100846:	e8 4f ff ff ff       	call   10079a <cprintf>
  10084b:	83 c4 0c             	add    $0xc,%esp
  10084e:	68 21 1e 10 00       	push   $0x101e21
  100853:	68 36 1e 10 00       	push   $0x101e36
  100858:	68 cb 1d 10 00       	push   $0x101dcb
  10085d:	e8 38 ff ff ff       	call   10079a <cprintf>
	return 0;
}
  100862:	31 c0                	xor    %eax,%eax
  100864:	83 c4 1c             	add    $0x1c,%esp
  100867:	c3                   	ret    

00100868 <print_tick>:
    cprintf("Kernel data base start=0x%10x size = %ld\n",&data_start,&end-&data_start);
    cprintf("Kernel executable memory footprint: %10xKB\n");
	return 0;
}
int print_tick(int argc, char **argv)
{
  100868:	83 ec 0c             	sub    $0xc,%esp
	cprintf("Now tick = %d\n", get_tick());
  10086b:	e8 8d 01 00 00       	call   1009fd <get_tick>
  100870:	c7 44 24 10 3f 1e 10 	movl   $0x101e3f,0x10(%esp)
  100877:	00 
  100878:	89 44 24 14          	mov    %eax,0x14(%esp)
}
  10087c:	83 c4 0c             	add    $0xc,%esp
    cprintf("Kernel executable memory footprint: %10xKB\n");
	return 0;
}
int print_tick(int argc, char **argv)
{
	cprintf("Now tick = %d\n", get_tick());
  10087f:	e9 16 ff ff ff       	jmp    10079a <cprintf>

00100884 <chgcolor>:
	{ "help", "Display this list of commands", mon_help },
	{ "kerninfo", "Display information about the kernel", mon_kerninfo },
	{ "print_tick", "Display system tick", print_tick },
    { "chgcolor","change color of text", chgcolor }
};
int chgcolor(int argc, char *argv[]){
  100884:	53                   	push   %ebx
  100885:	83 ec 08             	sub    $0x8,%esp
    if(argc == 1)
  100888:	83 7c 24 10 01       	cmpl   $0x1,0x10(%esp)
	{ "help", "Display this list of commands", mon_help },
	{ "kerninfo", "Display information about the kernel", mon_kerninfo },
	{ "print_tick", "Display system tick", print_tick },
    { "chgcolor","change color of text", chgcolor }
};
int chgcolor(int argc, char *argv[]){
  10088d:	8b 5c 24 14          	mov    0x14(%esp),%ebx
    if(argc == 1)
  100891:	75 0a                	jne    10089d <chgcolor+0x19>
        cprintf("NO input text colors!\n");
  100893:	83 ec 0c             	sub    $0xc,%esp
  100896:	68 4e 1e 10 00       	push   $0x101e4e
  10089b:	eb 1e                	jmp    1008bb <chgcolor+0x37>
    else{
        settextcolor((unsigned char)(*argv[1]),0);
  10089d:	51                   	push   %ecx
  10089e:	51                   	push   %ecx
  10089f:	6a 00                	push   $0x0
  1008a1:	8b 43 04             	mov    0x4(%ebx),%eax
  1008a4:	0f b6 00             	movzbl (%eax),%eax
  1008a7:	50                   	push   %eax
  1008a8:	e8 b2 fb ff ff       	call   10045f <settextcolor>
        cprintf("Change color %c!\n",*argv[1]);
  1008ad:	58                   	pop    %eax
  1008ae:	8b 43 04             	mov    0x4(%ebx),%eax
  1008b1:	5a                   	pop    %edx
  1008b2:	0f be 00             	movsbl (%eax),%eax
  1008b5:	50                   	push   %eax
  1008b6:	68 65 1e 10 00       	push   $0x101e65
  1008bb:	e8 da fe ff ff       	call   10079a <cprintf>
    }   
    return 0;
                            
}
  1008c0:	31 c0                	xor    %eax,%eax
  1008c2:	83 c4 18             	add    $0x18,%esp
  1008c5:	5b                   	pop    %ebx
  1008c6:	c3                   	ret    

001008c7 <shell>:
	}
	cprintf("Unknown command '%s'\n", argv[0]);
	return 0;
}
void shell()
{
  1008c7:	55                   	push   %ebp
  1008c8:	57                   	push   %edi
  1008c9:	56                   	push   %esi
  1008ca:	53                   	push   %ebx
  1008cb:	83 ec 58             	sub    $0x58,%esp
	char *buf;
	cprintf("Welcome to the OSDI course!\n");
  1008ce:	68 77 1e 10 00       	push   $0x101e77
  1008d3:	e8 c2 fe ff ff       	call   10079a <cprintf>
	cprintf("Type 'help' for a list of commands.\n");
  1008d8:	c7 04 24 94 1e 10 00 	movl   $0x101e94,(%esp)
  1008df:	e8 b6 fe ff ff       	call   10079a <cprintf>
  1008e4:	83 c4 10             	add    $0x10,%esp
	// Lookup and invoke the command
	if (argc == 0)
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
		if (strcmp(argv[0], commands[i].name) == 0)
			return commands[i].func(argc, argv);
  1008e7:	89 e5                	mov    %esp,%ebp
	cprintf("Welcome to the OSDI course!\n");
	cprintf("Type 'help' for a list of commands.\n");

	while(1)
	{
		buf = readline("OSDI> ");
  1008e9:	83 ec 0c             	sub    $0xc,%esp
  1008ec:	68 b9 1e 10 00       	push   $0x101eb9
  1008f1:	e8 9a 07 00 00       	call   101090 <readline>
		if (buf != NULL)
  1008f6:	83 c4 10             	add    $0x10,%esp
  1008f9:	85 c0                	test   %eax,%eax
	cprintf("Welcome to the OSDI course!\n");
	cprintf("Type 'help' for a list of commands.\n");

	while(1)
	{
		buf = readline("OSDI> ");
  1008fb:	89 c3                	mov    %eax,%ebx
		if (buf != NULL)
  1008fd:	74 ea                	je     1008e9 <shell+0x22>
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
  1008ff:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
	int argc;
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
  100906:	31 f6                	xor    %esi,%esi
  100908:	eb 04                	jmp    10090e <shell+0x47>
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
			*buf++ = 0;
  10090a:	c6 03 00             	movb   $0x0,(%ebx)
  10090d:	43                   	inc    %ebx
	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
  10090e:	8a 03                	mov    (%ebx),%al
  100910:	84 c0                	test   %al,%al
  100912:	74 17                	je     10092b <shell+0x64>
  100914:	57                   	push   %edi
  100915:	0f be c0             	movsbl %al,%eax
  100918:	57                   	push   %edi
  100919:	50                   	push   %eax
  10091a:	68 c0 1e 10 00       	push   $0x101ec0
  10091f:	e8 8d 09 00 00       	call   1012b1 <strchr>
  100924:	83 c4 10             	add    $0x10,%esp
  100927:	85 c0                	test   %eax,%eax
  100929:	75 df                	jne    10090a <shell+0x43>
			*buf++ = 0;
		if (*buf == 0)
  10092b:	80 3b 00             	cmpb   $0x0,(%ebx)
  10092e:	74 36                	je     100966 <shell+0x9f>
			break;

		// save and scan past next arg
		if (argc == MAXARGS-1) {
  100930:	83 fe 0f             	cmp    $0xf,%esi
  100933:	75 0b                	jne    100940 <shell+0x79>
			cprintf("Too many arguments (max %d)\n", MAXARGS);
  100935:	51                   	push   %ecx
  100936:	51                   	push   %ecx
  100937:	6a 10                	push   $0x10
  100939:	68 c5 1e 10 00       	push   $0x101ec5
  10093e:	eb 7d                	jmp    1009bd <shell+0xf6>
			return 0;
		}
		argv[argc++] = buf;
  100940:	89 1c b4             	mov    %ebx,(%esp,%esi,4)
  100943:	46                   	inc    %esi
  100944:	eb 01                	jmp    100947 <shell+0x80>
		while (*buf && !strchr(WHITESPACE, *buf))
			buf++;
  100946:	43                   	inc    %ebx
		if (argc == MAXARGS-1) {
			cprintf("Too many arguments (max %d)\n", MAXARGS);
			return 0;
		}
		argv[argc++] = buf;
		while (*buf && !strchr(WHITESPACE, *buf))
  100947:	8a 03                	mov    (%ebx),%al
  100949:	84 c0                	test   %al,%al
  10094b:	74 c1                	je     10090e <shell+0x47>
  10094d:	52                   	push   %edx
  10094e:	0f be c0             	movsbl %al,%eax
  100951:	52                   	push   %edx
  100952:	50                   	push   %eax
  100953:	68 c0 1e 10 00       	push   $0x101ec0
  100958:	e8 54 09 00 00       	call   1012b1 <strchr>
  10095d:	83 c4 10             	add    $0x10,%esp
  100960:	85 c0                	test   %eax,%eax
  100962:	74 e2                	je     100946 <shell+0x7f>
  100964:	eb a8                	jmp    10090e <shell+0x47>
			buf++;
	}
	argv[argc] = 0;

	// Lookup and invoke the command
	if (argc == 0)
  100966:	85 f6                	test   %esi,%esi
		}
		argv[argc++] = buf;
		while (*buf && !strchr(WHITESPACE, *buf))
			buf++;
	}
	argv[argc] = 0;
  100968:	c7 04 b4 00 00 00 00 	movl   $0x0,(%esp,%esi,4)

	// Lookup and invoke the command
	if (argc == 0)
  10096f:	0f 84 74 ff ff ff    	je     1008e9 <shell+0x22>
  100975:	bf f8 1e 10 00       	mov    $0x101ef8,%edi
  10097a:	31 db                	xor    %ebx,%ebx
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
		if (strcmp(argv[0], commands[i].name) == 0)
  10097c:	50                   	push   %eax
  10097d:	50                   	push   %eax
  10097e:	ff 37                	pushl  (%edi)
  100980:	83 c7 0c             	add    $0xc,%edi
  100983:	ff 74 24 0c          	pushl  0xc(%esp)
  100987:	e8 ae 08 00 00       	call   10123a <strcmp>
  10098c:	83 c4 10             	add    $0x10,%esp
  10098f:	85 c0                	test   %eax,%eax
  100991:	75 19                	jne    1009ac <shell+0xe5>
			return commands[i].func(argc, argv);
  100993:	6b db 0c             	imul   $0xc,%ebx,%ebx
  100996:	57                   	push   %edi
  100997:	57                   	push   %edi
  100998:	55                   	push   %ebp
  100999:	56                   	push   %esi
  10099a:	ff 93 00 1f 10 00    	call   *0x101f00(%ebx)
	while(1)
	{
		buf = readline("OSDI> ");
		if (buf != NULL)
		{
			if (runcmd(buf) < 0)
  1009a0:	83 c4 10             	add    $0x10,%esp
  1009a3:	85 c0                	test   %eax,%eax
  1009a5:	78 23                	js     1009ca <shell+0x103>
  1009a7:	e9 3d ff ff ff       	jmp    1008e9 <shell+0x22>
	argv[argc] = 0;

	// Lookup and invoke the command
	if (argc == 0)
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
  1009ac:	43                   	inc    %ebx
  1009ad:	83 fb 04             	cmp    $0x4,%ebx
  1009b0:	75 ca                	jne    10097c <shell+0xb5>
		if (strcmp(argv[0], commands[i].name) == 0)
			return commands[i].func(argc, argv);
	}
	cprintf("Unknown command '%s'\n", argv[0]);
  1009b2:	53                   	push   %ebx
  1009b3:	53                   	push   %ebx
  1009b4:	ff 74 24 08          	pushl  0x8(%esp)
  1009b8:	68 e2 1e 10 00       	push   $0x101ee2
  1009bd:	e8 d8 fd ff ff       	call   10079a <cprintf>
  1009c2:	83 c4 10             	add    $0x10,%esp
  1009c5:	e9 1f ff ff ff       	jmp    1008e9 <shell+0x22>
		{
			if (runcmd(buf) < 0)
				break;
		}
	}
}
  1009ca:	83 c4 4c             	add    $0x4c,%esp
  1009cd:	5b                   	pop    %ebx
  1009ce:	5e                   	pop    %esi
  1009cf:	5f                   	pop    %edi
  1009d0:	5d                   	pop    %ebp
  1009d1:	c3                   	ret    
	...

001009d4 <set_timer>:

static unsigned long jiffies = 0;

void set_timer(int hz)
{
    int divisor = 1193180 / hz;       /* Calculate our divisor */
  1009d4:	b9 dc 34 12 00       	mov    $0x1234dc,%ecx
  1009d9:	89 c8                	mov    %ecx,%eax
  1009db:	99                   	cltd   
  1009dc:	f7 7c 24 04          	idivl  0x4(%esp)
  1009e0:	ba 43 00 00 00       	mov    $0x43,%edx
  1009e5:	89 c1                	mov    %eax,%ecx
  1009e7:	b0 36                	mov    $0x36,%al
  1009e9:	ee                   	out    %al,(%dx)
  1009ea:	b2 40                	mov    $0x40,%dl
  1009ec:	88 c8                	mov    %cl,%al
  1009ee:	ee                   	out    %al,(%dx)
    outb(0x43, 0x36);             /* Set our command byte 0x36 */
    outb(0x40, divisor & 0xFF);   /* Set low byte of divisor */
    outb(0x40, divisor >> 8);     /* Set high byte of divisor */
  1009ef:	89 c8                	mov    %ecx,%eax
  1009f1:	c1 f8 08             	sar    $0x8,%eax
  1009f4:	ee                   	out    %al,(%dx)
}
  1009f5:	c3                   	ret    

001009f6 <timer_handler>:
/* 
 * Timer interrupt handler
 */
void timer_handler()
{
	jiffies++;
  1009f6:	ff 05 3c b5 10 00    	incl   0x10b53c
}
  1009fc:	c3                   	ret    

001009fd <get_tick>:

unsigned long get_tick()
{
	return jiffies;
}
  1009fd:	a1 3c b5 10 00       	mov    0x10b53c,%eax
  100a02:	c3                   	ret    

00100a03 <timer_init>:
void timer_init()
{
  100a03:	83 ec 0c             	sub    $0xc,%esp
	set_timer(TIME_HZ);
  100a06:	6a 64                	push   $0x64
  100a08:	e8 c7 ff ff ff       	call   1009d4 <set_timer>

	/* Enable interrupt */
	irq_setmask_8259A(irq_mask_8259A & ~(1<<IRQ_TIMER));
  100a0d:	50                   	push   %eax
  100a0e:	50                   	push   %eax
  100a0f:	0f b7 05 00 30 10 00 	movzwl 0x103000,%eax
  100a16:	25 fe ff 00 00       	and    $0xfffe,%eax
  100a1b:	50                   	push   %eax
  100a1c:	e8 23 f6 ff ff       	call   100044 <irq_setmask_8259A>
}
  100a21:	83 c4 1c             	add    $0x1c,%esp
  100a24:	c3                   	ret    
	...

00100a30 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  100a30:	55                   	push   %ebp
  100a31:	57                   	push   %edi
  100a32:	56                   	push   %esi
  100a33:	53                   	push   %ebx
  100a34:	83 ec 3c             	sub    $0x3c,%esp
  100a37:	89 c5                	mov    %eax,%ebp
  100a39:	89 d6                	mov    %edx,%esi
  100a3b:	8b 44 24 50          	mov    0x50(%esp),%eax
  100a3f:	89 44 24 24          	mov    %eax,0x24(%esp)
  100a43:	8b 54 24 54          	mov    0x54(%esp),%edx
  100a47:	89 54 24 20          	mov    %edx,0x20(%esp)
  100a4b:	8b 5c 24 5c          	mov    0x5c(%esp),%ebx
  100a4f:	8b 7c 24 60          	mov    0x60(%esp),%edi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  100a53:	b8 00 00 00 00       	mov    $0x0,%eax
  100a58:	39 d0                	cmp    %edx,%eax
  100a5a:	72 13                	jb     100a6f <printnum+0x3f>
  100a5c:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  100a60:	39 4c 24 58          	cmp    %ecx,0x58(%esp)
  100a64:	76 09                	jbe    100a6f <printnum+0x3f>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  100a66:	83 eb 01             	sub    $0x1,%ebx
  100a69:	85 db                	test   %ebx,%ebx
  100a6b:	7f 63                	jg     100ad0 <printnum+0xa0>
  100a6d:	eb 71                	jmp    100ae0 <printnum+0xb0>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  100a6f:	89 7c 24 10          	mov    %edi,0x10(%esp)
  100a73:	83 eb 01             	sub    $0x1,%ebx
  100a76:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  100a7a:	8b 5c 24 58          	mov    0x58(%esp),%ebx
  100a7e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  100a82:	8b 44 24 08          	mov    0x8(%esp),%eax
  100a86:	8b 54 24 0c          	mov    0xc(%esp),%edx
  100a8a:	89 44 24 28          	mov    %eax,0x28(%esp)
  100a8e:	89 54 24 2c          	mov    %edx,0x2c(%esp)
  100a92:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  100a99:	00 
  100a9a:	8b 54 24 24          	mov    0x24(%esp),%edx
  100a9e:	89 14 24             	mov    %edx,(%esp)
  100aa1:	8b 4c 24 20          	mov    0x20(%esp),%ecx
  100aa5:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  100aa9:	e8 d2 0a 00 00       	call   101580 <__udivdi3>
  100aae:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  100ab2:	8b 5c 24 2c          	mov    0x2c(%esp),%ebx
  100ab6:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  100aba:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  100abe:	89 04 24             	mov    %eax,(%esp)
  100ac1:	89 54 24 04          	mov    %edx,0x4(%esp)
  100ac5:	89 f2                	mov    %esi,%edx
  100ac7:	89 e8                	mov    %ebp,%eax
  100ac9:	e8 62 ff ff ff       	call   100a30 <printnum>
  100ace:	eb 10                	jmp    100ae0 <printnum+0xb0>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  100ad0:	89 74 24 04          	mov    %esi,0x4(%esp)
  100ad4:	89 3c 24             	mov    %edi,(%esp)
  100ad7:	ff d5                	call   *%ebp
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  100ad9:	83 eb 01             	sub    $0x1,%ebx
  100adc:	85 db                	test   %ebx,%ebx
  100ade:	7f f0                	jg     100ad0 <printnum+0xa0>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  100ae0:	89 74 24 04          	mov    %esi,0x4(%esp)
  100ae4:	8b 74 24 04          	mov    0x4(%esp),%esi
  100ae8:	8b 44 24 58          	mov    0x58(%esp),%eax
  100aec:	89 44 24 08          	mov    %eax,0x8(%esp)
  100af0:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  100af7:	00 
  100af8:	8b 54 24 24          	mov    0x24(%esp),%edx
  100afc:	89 14 24             	mov    %edx,(%esp)
  100aff:	8b 4c 24 20          	mov    0x20(%esp),%ecx
  100b03:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  100b07:	e8 84 0b 00 00       	call   101690 <__umoddi3>
  100b0c:	89 74 24 04          	mov    %esi,0x4(%esp)
  100b10:	0f be 80 28 1f 10 00 	movsbl 0x101f28(%eax),%eax
  100b17:	89 04 24             	mov    %eax,(%esp)
  100b1a:	ff d5                	call   *%ebp
}
  100b1c:	83 c4 3c             	add    $0x3c,%esp
  100b1f:	5b                   	pop    %ebx
  100b20:	5e                   	pop    %esi
  100b21:	5f                   	pop    %edi
  100b22:	5d                   	pop    %ebp
  100b23:	c3                   	ret    

00100b24 <getuint>:
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  100b24:	83 fa 01             	cmp    $0x1,%edx
  100b27:	7e 0d                	jle    100b36 <getuint+0x12>
		return va_arg(*ap, unsigned long long);
  100b29:	8b 10                	mov    (%eax),%edx
  100b2b:	8d 4a 08             	lea    0x8(%edx),%ecx
  100b2e:	89 08                	mov    %ecx,(%eax)
  100b30:	8b 02                	mov    (%edx),%eax
  100b32:	8b 52 04             	mov    0x4(%edx),%edx
  100b35:	c3                   	ret    
	else if (lflag)
  100b36:	85 d2                	test   %edx,%edx
  100b38:	74 0f                	je     100b49 <getuint+0x25>
		return va_arg(*ap, unsigned long);
  100b3a:	8b 10                	mov    (%eax),%edx
  100b3c:	8d 4a 04             	lea    0x4(%edx),%ecx
  100b3f:	89 08                	mov    %ecx,(%eax)
  100b41:	8b 02                	mov    (%edx),%eax
  100b43:	ba 00 00 00 00       	mov    $0x0,%edx
  100b48:	c3                   	ret    
	else
		return va_arg(*ap, unsigned int);
  100b49:	8b 10                	mov    (%eax),%edx
  100b4b:	8d 4a 04             	lea    0x4(%edx),%ecx
  100b4e:	89 08                	mov    %ecx,(%eax)
  100b50:	8b 02                	mov    (%edx),%eax
  100b52:	ba 00 00 00 00       	mov    $0x0,%edx
}
  100b57:	c3                   	ret    

00100b58 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  100b58:	8b 44 24 08          	mov    0x8(%esp),%eax
	b->cnt++;
  100b5c:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  100b60:	8b 10                	mov    (%eax),%edx
  100b62:	3b 50 04             	cmp    0x4(%eax),%edx
  100b65:	73 0b                	jae    100b72 <sprintputch+0x1a>
		*b->buf++ = ch;
  100b67:	8b 4c 24 04          	mov    0x4(%esp),%ecx
  100b6b:	88 0a                	mov    %cl,(%edx)
  100b6d:	83 c2 01             	add    $0x1,%edx
  100b70:	89 10                	mov    %edx,(%eax)
  100b72:	f3 c3                	repz ret 

00100b74 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  100b74:	83 ec 1c             	sub    $0x1c,%esp
	va_list ap;

	va_start(ap, fmt);
  100b77:	8d 44 24 2c          	lea    0x2c(%esp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  100b7b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  100b7f:	8b 44 24 28          	mov    0x28(%esp),%eax
  100b83:	89 44 24 08          	mov    %eax,0x8(%esp)
  100b87:	8b 44 24 24          	mov    0x24(%esp),%eax
  100b8b:	89 44 24 04          	mov    %eax,0x4(%esp)
  100b8f:	8b 44 24 20          	mov    0x20(%esp),%eax
  100b93:	89 04 24             	mov    %eax,(%esp)
  100b96:	e8 04 00 00 00       	call   100b9f <vprintfmt>
	va_end(ap);
}
  100b9b:	83 c4 1c             	add    $0x1c,%esp
  100b9e:	c3                   	ret    

00100b9f <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  100b9f:	55                   	push   %ebp
  100ba0:	57                   	push   %edi
  100ba1:	56                   	push   %esi
  100ba2:	53                   	push   %ebx
  100ba3:	83 ec 4c             	sub    $0x4c,%esp
  100ba6:	8b 6c 24 60          	mov    0x60(%esp),%ebp
  100baa:	8b 7c 24 64          	mov    0x64(%esp),%edi
  100bae:	8b 5c 24 68          	mov    0x68(%esp),%ebx
  100bb2:	eb 11                	jmp    100bc5 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  100bb4:	85 c0                	test   %eax,%eax
  100bb6:	0f 84 40 04 00 00    	je     100ffc <vprintfmt+0x45d>
				return;
			putch(ch, putdat);
  100bbc:	89 7c 24 04          	mov    %edi,0x4(%esp)
  100bc0:	89 04 24             	mov    %eax,(%esp)
  100bc3:	ff d5                	call   *%ebp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  100bc5:	0f b6 03             	movzbl (%ebx),%eax
  100bc8:	83 c3 01             	add    $0x1,%ebx
  100bcb:	83 f8 25             	cmp    $0x25,%eax
  100bce:	75 e4                	jne    100bb4 <vprintfmt+0x15>
  100bd0:	c6 44 24 28 20       	movb   $0x20,0x28(%esp)
  100bd5:	c7 44 24 2c 00 00 00 	movl   $0x0,0x2c(%esp)
  100bdc:	00 
  100bdd:	be ff ff ff ff       	mov    $0xffffffff,%esi
  100be2:	c7 44 24 30 ff ff ff 	movl   $0xffffffff,0x30(%esp)
  100be9:	ff 
  100bea:	b9 00 00 00 00       	mov    $0x0,%ecx
  100bef:	89 74 24 34          	mov    %esi,0x34(%esp)
  100bf3:	eb 34                	jmp    100c29 <vprintfmt+0x8a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  100bf5:	8b 5c 24 24          	mov    0x24(%esp),%ebx

		// flag to pad on the right
		case '-':
			padc = '-';
  100bf9:	c6 44 24 28 2d       	movb   $0x2d,0x28(%esp)
  100bfe:	eb 29                	jmp    100c29 <vprintfmt+0x8a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  100c00:	8b 5c 24 24          	mov    0x24(%esp),%ebx
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  100c04:	c6 44 24 28 30       	movb   $0x30,0x28(%esp)
  100c09:	eb 1e                	jmp    100c29 <vprintfmt+0x8a>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  100c0b:	8b 5c 24 24          	mov    0x24(%esp),%ebx
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  100c0f:	c7 44 24 30 00 00 00 	movl   $0x0,0x30(%esp)
  100c16:	00 
  100c17:	eb 10                	jmp    100c29 <vprintfmt+0x8a>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  100c19:	8b 44 24 34          	mov    0x34(%esp),%eax
  100c1d:	89 44 24 30          	mov    %eax,0x30(%esp)
  100c21:	c7 44 24 34 ff ff ff 	movl   $0xffffffff,0x34(%esp)
  100c28:	ff 
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  100c29:	0f b6 03             	movzbl (%ebx),%eax
  100c2c:	0f b6 d0             	movzbl %al,%edx
  100c2f:	8d 73 01             	lea    0x1(%ebx),%esi
  100c32:	89 74 24 24          	mov    %esi,0x24(%esp)
  100c36:	83 e8 23             	sub    $0x23,%eax
  100c39:	3c 55                	cmp    $0x55,%al
  100c3b:	0f 87 9c 03 00 00    	ja     100fdd <vprintfmt+0x43e>
  100c41:	0f b6 c0             	movzbl %al,%eax
  100c44:	ff 24 85 e0 1f 10 00 	jmp    *0x101fe0(,%eax,4)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  100c4b:	83 ea 30             	sub    $0x30,%edx
  100c4e:	89 54 24 34          	mov    %edx,0x34(%esp)
				ch = *fmt;
  100c52:	8b 54 24 24          	mov    0x24(%esp),%edx
  100c56:	0f be 02             	movsbl (%edx),%eax
				if (ch < '0' || ch > '9')
  100c59:	8d 50 d0             	lea    -0x30(%eax),%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  100c5c:	8b 5c 24 24          	mov    0x24(%esp),%ebx
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
  100c60:	83 fa 09             	cmp    $0x9,%edx
  100c63:	77 5b                	ja     100cc0 <vprintfmt+0x121>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  100c65:	8b 74 24 34          	mov    0x34(%esp),%esi
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  100c69:	83 c3 01             	add    $0x1,%ebx
				precision = precision * 10 + ch - '0';
  100c6c:	8d 14 b6             	lea    (%esi,%esi,4),%edx
  100c6f:	8d 74 50 d0          	lea    -0x30(%eax,%edx,2),%esi
				ch = *fmt;
  100c73:	0f be 03             	movsbl (%ebx),%eax
				if (ch < '0' || ch > '9')
  100c76:	8d 50 d0             	lea    -0x30(%eax),%edx
  100c79:	83 fa 09             	cmp    $0x9,%edx
  100c7c:	76 eb                	jbe    100c69 <vprintfmt+0xca>
  100c7e:	89 74 24 34          	mov    %esi,0x34(%esp)
  100c82:	eb 3c                	jmp    100cc0 <vprintfmt+0x121>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  100c84:	8b 44 24 6c          	mov    0x6c(%esp),%eax
  100c88:	8d 50 04             	lea    0x4(%eax),%edx
  100c8b:	89 54 24 6c          	mov    %edx,0x6c(%esp)
  100c8f:	8b 00                	mov    (%eax),%eax
  100c91:	89 44 24 34          	mov    %eax,0x34(%esp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  100c95:	8b 5c 24 24          	mov    0x24(%esp),%ebx
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  100c99:	eb 25                	jmp    100cc0 <vprintfmt+0x121>

		case '.':
			if (width < 0)
  100c9b:	83 7c 24 30 00       	cmpl   $0x0,0x30(%esp)
  100ca0:	0f 88 65 ff ff ff    	js     100c0b <vprintfmt+0x6c>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  100ca6:	8b 5c 24 24          	mov    0x24(%esp),%ebx
  100caa:	e9 7a ff ff ff       	jmp    100c29 <vprintfmt+0x8a>
  100caf:	8b 5c 24 24          	mov    0x24(%esp),%ebx
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  100cb3:	c7 44 24 2c 01 00 00 	movl   $0x1,0x2c(%esp)
  100cba:	00 
			goto reswitch;
  100cbb:	e9 69 ff ff ff       	jmp    100c29 <vprintfmt+0x8a>

		process_precision:
			if (width < 0)
  100cc0:	83 7c 24 30 00       	cmpl   $0x0,0x30(%esp)
  100cc5:	0f 89 5e ff ff ff    	jns    100c29 <vprintfmt+0x8a>
  100ccb:	e9 49 ff ff ff       	jmp    100c19 <vprintfmt+0x7a>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  100cd0:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  100cd3:	8b 5c 24 24          	mov    0x24(%esp),%ebx
  100cd7:	e9 4d ff ff ff       	jmp    100c29 <vprintfmt+0x8a>
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  100cdc:	8b 44 24 6c          	mov    0x6c(%esp),%eax
  100ce0:	8d 50 04             	lea    0x4(%eax),%edx
  100ce3:	89 54 24 6c          	mov    %edx,0x6c(%esp)
  100ce7:	89 7c 24 04          	mov    %edi,0x4(%esp)
  100ceb:	8b 00                	mov    (%eax),%eax
  100ced:	89 04 24             	mov    %eax,(%esp)
  100cf0:	ff d5                	call   *%ebp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  100cf2:	8b 5c 24 24          	mov    0x24(%esp),%ebx
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  100cf6:	e9 ca fe ff ff       	jmp    100bc5 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  100cfb:	8b 44 24 6c          	mov    0x6c(%esp),%eax
  100cff:	8d 50 04             	lea    0x4(%eax),%edx
  100d02:	89 54 24 6c          	mov    %edx,0x6c(%esp)
  100d06:	8b 00                	mov    (%eax),%eax
  100d08:	89 c2                	mov    %eax,%edx
  100d0a:	c1 fa 1f             	sar    $0x1f,%edx
  100d0d:	31 d0                	xor    %edx,%eax
  100d0f:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  100d11:	83 f8 08             	cmp    $0x8,%eax
  100d14:	7f 0b                	jg     100d21 <vprintfmt+0x182>
  100d16:	8b 14 85 40 21 10 00 	mov    0x102140(,%eax,4),%edx
  100d1d:	85 d2                	test   %edx,%edx
  100d1f:	75 21                	jne    100d42 <vprintfmt+0x1a3>
				printfmt(putch, putdat, "error %d", err);
  100d21:	89 44 24 0c          	mov    %eax,0xc(%esp)
  100d25:	c7 44 24 08 40 1f 10 	movl   $0x101f40,0x8(%esp)
  100d2c:	00 
  100d2d:	89 7c 24 04          	mov    %edi,0x4(%esp)
  100d31:	89 2c 24             	mov    %ebp,(%esp)
  100d34:	e8 3b fe ff ff       	call   100b74 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  100d39:	8b 5c 24 24          	mov    0x24(%esp),%ebx
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  100d3d:	e9 83 fe ff ff       	jmp    100bc5 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  100d42:	89 54 24 0c          	mov    %edx,0xc(%esp)
  100d46:	c7 44 24 08 49 1f 10 	movl   $0x101f49,0x8(%esp)
  100d4d:	00 
  100d4e:	89 7c 24 04          	mov    %edi,0x4(%esp)
  100d52:	89 2c 24             	mov    %ebp,(%esp)
  100d55:	e8 1a fe ff ff       	call   100b74 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  100d5a:	8b 5c 24 24          	mov    0x24(%esp),%ebx
  100d5e:	e9 62 fe ff ff       	jmp    100bc5 <vprintfmt+0x26>
  100d63:	8b 74 24 34          	mov    0x34(%esp),%esi
  100d67:	8b 5c 24 24          	mov    0x24(%esp),%ebx
  100d6b:	8b 44 24 30          	mov    0x30(%esp),%eax
  100d6f:	89 44 24 38          	mov    %eax,0x38(%esp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  100d73:	8b 44 24 6c          	mov    0x6c(%esp),%eax
  100d77:	8d 50 04             	lea    0x4(%eax),%edx
  100d7a:	89 54 24 6c          	mov    %edx,0x6c(%esp)
  100d7e:	8b 00                	mov    (%eax),%eax
				p = "(null)";
  100d80:	85 c0                	test   %eax,%eax
  100d82:	ba 39 1f 10 00       	mov    $0x101f39,%edx
  100d87:	0f 45 d0             	cmovne %eax,%edx
  100d8a:	89 54 24 34          	mov    %edx,0x34(%esp)
			if (width > 0 && padc != '-')
  100d8e:	83 7c 24 38 00       	cmpl   $0x0,0x38(%esp)
  100d93:	7e 07                	jle    100d9c <vprintfmt+0x1fd>
  100d95:	80 7c 24 28 2d       	cmpb   $0x2d,0x28(%esp)
  100d9a:	75 14                	jne    100db0 <vprintfmt+0x211>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  100d9c:	8b 54 24 34          	mov    0x34(%esp),%edx
  100da0:	0f be 02             	movsbl (%edx),%eax
  100da3:	85 c0                	test   %eax,%eax
  100da5:	0f 85 ac 00 00 00    	jne    100e57 <vprintfmt+0x2b8>
  100dab:	e9 97 00 00 00       	jmp    100e47 <vprintfmt+0x2a8>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  100db0:	89 74 24 04          	mov    %esi,0x4(%esp)
  100db4:	8b 44 24 34          	mov    0x34(%esp),%eax
  100db8:	89 04 24             	mov    %eax,(%esp)
  100dbb:	e8 99 03 00 00       	call   101159 <strnlen>
  100dc0:	8b 54 24 38          	mov    0x38(%esp),%edx
  100dc4:	29 c2                	sub    %eax,%edx
  100dc6:	89 54 24 30          	mov    %edx,0x30(%esp)
  100dca:	85 d2                	test   %edx,%edx
  100dcc:	7e ce                	jle    100d9c <vprintfmt+0x1fd>
					putch(padc, putdat);
  100dce:	0f be 44 24 28       	movsbl 0x28(%esp),%eax
  100dd3:	89 74 24 38          	mov    %esi,0x38(%esp)
  100dd7:	89 5c 24 3c          	mov    %ebx,0x3c(%esp)
  100ddb:	89 d3                	mov    %edx,%ebx
  100ddd:	89 c6                	mov    %eax,%esi
  100ddf:	89 7c 24 04          	mov    %edi,0x4(%esp)
  100de3:	89 34 24             	mov    %esi,(%esp)
  100de6:	ff d5                	call   *%ebp
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  100de8:	83 eb 01             	sub    $0x1,%ebx
  100deb:	85 db                	test   %ebx,%ebx
  100ded:	7f f0                	jg     100ddf <vprintfmt+0x240>
  100def:	8b 74 24 38          	mov    0x38(%esp),%esi
  100df3:	8b 5c 24 3c          	mov    0x3c(%esp),%ebx
  100df7:	c7 44 24 30 00 00 00 	movl   $0x0,0x30(%esp)
  100dfe:	00 
  100dff:	eb 9b                	jmp    100d9c <vprintfmt+0x1fd>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  100e01:	83 7c 24 2c 00       	cmpl   $0x0,0x2c(%esp)
  100e06:	74 19                	je     100e21 <vprintfmt+0x282>
  100e08:	8d 50 e0             	lea    -0x20(%eax),%edx
  100e0b:	83 fa 5e             	cmp    $0x5e,%edx
  100e0e:	76 11                	jbe    100e21 <vprintfmt+0x282>
					putch('?', putdat);
  100e10:	89 7c 24 04          	mov    %edi,0x4(%esp)
  100e14:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  100e1b:	ff 54 24 28          	call   *0x28(%esp)
  100e1f:	eb 0b                	jmp    100e2c <vprintfmt+0x28d>
				else
					putch(ch, putdat);
  100e21:	89 7c 24 04          	mov    %edi,0x4(%esp)
  100e25:	89 04 24             	mov    %eax,(%esp)
  100e28:	ff 54 24 28          	call   *0x28(%esp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  100e2c:	83 ed 01             	sub    $0x1,%ebp
  100e2f:	0f be 03             	movsbl (%ebx),%eax
  100e32:	85 c0                	test   %eax,%eax
  100e34:	74 05                	je     100e3b <vprintfmt+0x29c>
  100e36:	83 c3 01             	add    $0x1,%ebx
  100e39:	eb 31                	jmp    100e6c <vprintfmt+0x2cd>
  100e3b:	89 6c 24 30          	mov    %ebp,0x30(%esp)
  100e3f:	8b 6c 24 28          	mov    0x28(%esp),%ebp
  100e43:	8b 5c 24 38          	mov    0x38(%esp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  100e47:	83 7c 24 30 00       	cmpl   $0x0,0x30(%esp)
  100e4c:	7f 35                	jg     100e83 <vprintfmt+0x2e4>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  100e4e:	8b 5c 24 24          	mov    0x24(%esp),%ebx
  100e52:	e9 6e fd ff ff       	jmp    100bc5 <vprintfmt+0x26>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  100e57:	8b 54 24 34          	mov    0x34(%esp),%edx
  100e5b:	83 c2 01             	add    $0x1,%edx
  100e5e:	89 6c 24 28          	mov    %ebp,0x28(%esp)
  100e62:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  100e66:	89 5c 24 38          	mov    %ebx,0x38(%esp)
  100e6a:	89 d3                	mov    %edx,%ebx
  100e6c:	85 f6                	test   %esi,%esi
  100e6e:	78 91                	js     100e01 <vprintfmt+0x262>
  100e70:	83 ee 01             	sub    $0x1,%esi
  100e73:	79 8c                	jns    100e01 <vprintfmt+0x262>
  100e75:	89 6c 24 30          	mov    %ebp,0x30(%esp)
  100e79:	8b 6c 24 28          	mov    0x28(%esp),%ebp
  100e7d:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  100e81:	eb c4                	jmp    100e47 <vprintfmt+0x2a8>
  100e83:	89 de                	mov    %ebx,%esi
  100e85:	8b 5c 24 30          	mov    0x30(%esp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  100e89:	89 7c 24 04          	mov    %edi,0x4(%esp)
  100e8d:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  100e94:	ff d5                	call   *%ebp
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  100e96:	83 eb 01             	sub    $0x1,%ebx
  100e99:	85 db                	test   %ebx,%ebx
  100e9b:	7f ec                	jg     100e89 <vprintfmt+0x2ea>
  100e9d:	89 f3                	mov    %esi,%ebx
  100e9f:	e9 21 fd ff ff       	jmp    100bc5 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  100ea4:	83 f9 01             	cmp    $0x1,%ecx
  100ea7:	7e 12                	jle    100ebb <vprintfmt+0x31c>
		return va_arg(*ap, long long);
  100ea9:	8b 44 24 6c          	mov    0x6c(%esp),%eax
  100ead:	8d 50 08             	lea    0x8(%eax),%edx
  100eb0:	89 54 24 6c          	mov    %edx,0x6c(%esp)
  100eb4:	8b 18                	mov    (%eax),%ebx
  100eb6:	8b 70 04             	mov    0x4(%eax),%esi
  100eb9:	eb 2a                	jmp    100ee5 <vprintfmt+0x346>
	else if (lflag)
  100ebb:	85 c9                	test   %ecx,%ecx
  100ebd:	74 14                	je     100ed3 <vprintfmt+0x334>
		return va_arg(*ap, long);
  100ebf:	8b 44 24 6c          	mov    0x6c(%esp),%eax
  100ec3:	8d 50 04             	lea    0x4(%eax),%edx
  100ec6:	89 54 24 6c          	mov    %edx,0x6c(%esp)
  100eca:	8b 18                	mov    (%eax),%ebx
  100ecc:	89 de                	mov    %ebx,%esi
  100ece:	c1 fe 1f             	sar    $0x1f,%esi
  100ed1:	eb 12                	jmp    100ee5 <vprintfmt+0x346>
	else
		return va_arg(*ap, int);
  100ed3:	8b 44 24 6c          	mov    0x6c(%esp),%eax
  100ed7:	8d 50 04             	lea    0x4(%eax),%edx
  100eda:	89 54 24 6c          	mov    %edx,0x6c(%esp)
  100ede:	8b 18                	mov    (%eax),%ebx
  100ee0:	89 de                	mov    %ebx,%esi
  100ee2:	c1 fe 1f             	sar    $0x1f,%esi
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  100ee5:	b8 0a 00 00 00       	mov    $0xa,%eax
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  100eea:	85 f6                	test   %esi,%esi
  100eec:	0f 89 ab 00 00 00    	jns    100f9d <vprintfmt+0x3fe>
				putch('-', putdat);
  100ef2:	89 7c 24 04          	mov    %edi,0x4(%esp)
  100ef6:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  100efd:	ff d5                	call   *%ebp
				num = -(long long) num;
  100eff:	f7 db                	neg    %ebx
  100f01:	83 d6 00             	adc    $0x0,%esi
  100f04:	f7 de                	neg    %esi
			}
			base = 10;
  100f06:	b8 0a 00 00 00       	mov    $0xa,%eax
  100f0b:	e9 8d 00 00 00       	jmp    100f9d <vprintfmt+0x3fe>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  100f10:	89 ca                	mov    %ecx,%edx
  100f12:	8d 44 24 6c          	lea    0x6c(%esp),%eax
  100f16:	e8 09 fc ff ff       	call   100b24 <getuint>
  100f1b:	89 c3                	mov    %eax,%ebx
  100f1d:	89 d6                	mov    %edx,%esi
			base = 10;
  100f1f:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  100f24:	eb 77                	jmp    100f9d <vprintfmt+0x3fe>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
  100f26:	89 7c 24 04          	mov    %edi,0x4(%esp)
  100f2a:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  100f31:	ff d5                	call   *%ebp
			putch('X', putdat);
  100f33:	89 7c 24 04          	mov    %edi,0x4(%esp)
  100f37:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  100f3e:	ff d5                	call   *%ebp
			putch('X', putdat);
  100f40:	89 7c 24 04          	mov    %edi,0x4(%esp)
  100f44:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  100f4b:	ff d5                	call   *%ebp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  100f4d:	8b 5c 24 24          	mov    0x24(%esp),%ebx
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
			putch('X', putdat);
			putch('X', putdat);
			break;
  100f51:	e9 6f fc ff ff       	jmp    100bc5 <vprintfmt+0x26>

		// pointer
		case 'p':
			putch('0', putdat);
  100f56:	89 7c 24 04          	mov    %edi,0x4(%esp)
  100f5a:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  100f61:	ff d5                	call   *%ebp
			putch('x', putdat);
  100f63:	89 7c 24 04          	mov    %edi,0x4(%esp)
  100f67:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  100f6e:	ff d5                	call   *%ebp
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  100f70:	8b 44 24 6c          	mov    0x6c(%esp),%eax
  100f74:	8d 50 04             	lea    0x4(%eax),%edx
  100f77:	89 54 24 6c          	mov    %edx,0x6c(%esp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  100f7b:	8b 18                	mov    (%eax),%ebx
  100f7d:	be 00 00 00 00       	mov    $0x0,%esi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  100f82:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  100f87:	eb 14                	jmp    100f9d <vprintfmt+0x3fe>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  100f89:	89 ca                	mov    %ecx,%edx
  100f8b:	8d 44 24 6c          	lea    0x6c(%esp),%eax
  100f8f:	e8 90 fb ff ff       	call   100b24 <getuint>
  100f94:	89 c3                	mov    %eax,%ebx
  100f96:	89 d6                	mov    %edx,%esi
			base = 16;
  100f98:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  100f9d:	0f be 54 24 28       	movsbl 0x28(%esp),%edx
  100fa2:	89 54 24 10          	mov    %edx,0x10(%esp)
  100fa6:	8b 54 24 30          	mov    0x30(%esp),%edx
  100faa:	89 54 24 0c          	mov    %edx,0xc(%esp)
  100fae:	89 44 24 08          	mov    %eax,0x8(%esp)
  100fb2:	89 1c 24             	mov    %ebx,(%esp)
  100fb5:	89 74 24 04          	mov    %esi,0x4(%esp)
  100fb9:	89 fa                	mov    %edi,%edx
  100fbb:	89 e8                	mov    %ebp,%eax
  100fbd:	e8 6e fa ff ff       	call   100a30 <printnum>
			break;
  100fc2:	8b 5c 24 24          	mov    0x24(%esp),%ebx
  100fc6:	e9 fa fb ff ff       	jmp    100bc5 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  100fcb:	89 7c 24 04          	mov    %edi,0x4(%esp)
  100fcf:	89 14 24             	mov    %edx,(%esp)
  100fd2:	ff d5                	call   *%ebp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  100fd4:	8b 5c 24 24          	mov    0x24(%esp),%ebx
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  100fd8:	e9 e8 fb ff ff       	jmp    100bc5 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  100fdd:	89 7c 24 04          	mov    %edi,0x4(%esp)
  100fe1:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  100fe8:	ff d5                	call   *%ebp
			for (fmt--; fmt[-1] != '%'; fmt--)
  100fea:	eb 02                	jmp    100fee <vprintfmt+0x44f>
  100fec:	89 c3                	mov    %eax,%ebx
  100fee:	8d 43 ff             	lea    -0x1(%ebx),%eax
  100ff1:	80 7b ff 25          	cmpb   $0x25,-0x1(%ebx)
  100ff5:	75 f5                	jne    100fec <vprintfmt+0x44d>
  100ff7:	e9 c9 fb ff ff       	jmp    100bc5 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  100ffc:	83 c4 4c             	add    $0x4c,%esp
  100fff:	5b                   	pop    %ebx
  101000:	5e                   	pop    %esi
  101001:	5f                   	pop    %edi
  101002:	5d                   	pop    %ebp
  101003:	c3                   	ret    

00101004 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  101004:	83 ec 2c             	sub    $0x2c,%esp
  101007:	8b 44 24 30          	mov    0x30(%esp),%eax
  10100b:	8b 54 24 34          	mov    0x34(%esp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  10100f:	89 44 24 14          	mov    %eax,0x14(%esp)
  101013:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  101017:	89 4c 24 18          	mov    %ecx,0x18(%esp)
  10101b:	c7 44 24 1c 00 00 00 	movl   $0x0,0x1c(%esp)
  101022:	00 

	if (buf == NULL || n < 1)
  101023:	85 c0                	test   %eax,%eax
  101025:	74 35                	je     10105c <vsnprintf+0x58>
  101027:	85 d2                	test   %edx,%edx
  101029:	7e 31                	jle    10105c <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  10102b:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  10102f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  101033:	8b 44 24 38          	mov    0x38(%esp),%eax
  101037:	89 44 24 08          	mov    %eax,0x8(%esp)
  10103b:	8d 44 24 14          	lea    0x14(%esp),%eax
  10103f:	89 44 24 04          	mov    %eax,0x4(%esp)
  101043:	c7 04 24 58 0b 10 00 	movl   $0x100b58,(%esp)
  10104a:	e8 50 fb ff ff       	call   100b9f <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  10104f:	8b 44 24 14          	mov    0x14(%esp),%eax
  101053:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  101056:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  10105a:	eb 05                	jmp    101061 <vsnprintf+0x5d>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  10105c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  101061:	83 c4 2c             	add    $0x2c,%esp
  101064:	c3                   	ret    

00101065 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  101065:	83 ec 1c             	sub    $0x1c,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  101068:	8d 44 24 2c          	lea    0x2c(%esp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  10106c:	89 44 24 0c          	mov    %eax,0xc(%esp)
  101070:	8b 44 24 28          	mov    0x28(%esp),%eax
  101074:	89 44 24 08          	mov    %eax,0x8(%esp)
  101078:	8b 44 24 24          	mov    0x24(%esp),%eax
  10107c:	89 44 24 04          	mov    %eax,0x4(%esp)
  101080:	8b 44 24 20          	mov    0x20(%esp),%eax
  101084:	89 04 24             	mov    %eax,(%esp)
  101087:	e8 78 ff ff ff       	call   101004 <vsnprintf>
	va_end(ap);

	return rc;
}
  10108c:	83 c4 1c             	add    $0x1c,%esp
  10108f:	c3                   	ret    

00101090 <readline>:

#define BUFLEN 1024
static char buf[BUFLEN];

char *readline(const char *prompt)
{
  101090:	56                   	push   %esi
  101091:	53                   	push   %ebx
  101092:	83 ec 14             	sub    $0x14,%esp
  101095:	8b 44 24 20          	mov    0x20(%esp),%eax
	int i, c, echoing;

	if (prompt != NULL)
  101099:	85 c0                	test   %eax,%eax
  10109b:	74 10                	je     1010ad <readline+0x1d>
		cprintf("%s", prompt);
  10109d:	89 44 24 04          	mov    %eax,0x4(%esp)
  1010a1:	c7 04 24 49 1f 10 00 	movl   $0x101f49,(%esp)
  1010a8:	e8 ed f6 ff ff       	call   10079a <cprintf>

#define BUFLEN 1024
static char buf[BUFLEN];

char *readline(const char *prompt)
{
  1010ad:	be 00 00 00 00       	mov    $0x0,%esi
	if (prompt != NULL)
		cprintf("%s", prompt);

	i = 0;
	while (1) {
		c = getc();
  1010b2:	e8 b4 f1 ff ff       	call   10026b <getc>
  1010b7:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
  1010b9:	85 c0                	test   %eax,%eax
  1010bb:	79 17                	jns    1010d4 <readline+0x44>
			cprintf("read error: %e\n", c);
  1010bd:	89 44 24 04          	mov    %eax,0x4(%esp)
  1010c1:	c7 04 24 64 21 10 00 	movl   $0x102164,(%esp)
  1010c8:	e8 cd f6 ff ff       	call   10079a <cprintf>
			return NULL;
  1010cd:	b8 00 00 00 00       	mov    $0x0,%eax
  1010d2:	eb 64                	jmp    101138 <readline+0xa8>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
  1010d4:	83 f8 08             	cmp    $0x8,%eax
  1010d7:	74 05                	je     1010de <readline+0x4e>
  1010d9:	83 f8 7f             	cmp    $0x7f,%eax
  1010dc:	75 15                	jne    1010f3 <readline+0x63>
  1010de:	85 f6                	test   %esi,%esi
  1010e0:	7e 11                	jle    1010f3 <readline+0x63>
			putch('\b');
  1010e2:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
  1010e9:	e8 7b f2 ff ff       	call   100369 <putch>
			i--;
  1010ee:	83 ee 01             	sub    $0x1,%esi
  1010f1:	eb bf                	jmp    1010b2 <readline+0x22>
		} else if (c >= ' ' && i < BUFLEN-1) {
  1010f3:	83 fb 1f             	cmp    $0x1f,%ebx
  1010f6:	7e 1e                	jle    101116 <readline+0x86>
  1010f8:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
  1010fe:	7f 16                	jg     101116 <readline+0x86>
			putch(c);
  101100:	0f b6 c3             	movzbl %bl,%eax
  101103:	89 04 24             	mov    %eax,(%esp)
  101106:	e8 5e f2 ff ff       	call   100369 <putch>
			buf[i++] = c;
  10110b:	88 9e 40 b5 10 00    	mov    %bl,0x10b540(%esi)
  101111:	83 c6 01             	add    $0x1,%esi
  101114:	eb 9c                	jmp    1010b2 <readline+0x22>
		} else if (c == '\n' || c == '\r') {
  101116:	83 fb 0a             	cmp    $0xa,%ebx
  101119:	74 05                	je     101120 <readline+0x90>
  10111b:	83 fb 0d             	cmp    $0xd,%ebx
  10111e:	75 92                	jne    1010b2 <readline+0x22>
			putch('\n');
  101120:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
  101127:	e8 3d f2 ff ff       	call   100369 <putch>
			buf[i] = 0;
  10112c:	c6 86 40 b5 10 00 00 	movb   $0x0,0x10b540(%esi)
			return buf;
  101133:	b8 40 b5 10 00       	mov    $0x10b540,%eax
		}
	}
}
  101138:	83 c4 14             	add    $0x14,%esp
  10113b:	5b                   	pop    %ebx
  10113c:	5e                   	pop    %esi
  10113d:	c3                   	ret    
	...

00101140 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  101140:	8b 54 24 04          	mov    0x4(%esp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  101144:	b8 00 00 00 00       	mov    $0x0,%eax
  101149:	80 3a 00             	cmpb   $0x0,(%edx)
  10114c:	74 09                	je     101157 <strlen+0x17>
		n++;
  10114e:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  101151:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  101155:	75 f7                	jne    10114e <strlen+0xe>
		n++;
	return n;
}
  101157:	f3 c3                	repz ret 

00101159 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  101159:	8b 4c 24 04          	mov    0x4(%esp),%ecx
  10115d:	8b 54 24 08          	mov    0x8(%esp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  101161:	b8 00 00 00 00       	mov    $0x0,%eax
  101166:	85 d2                	test   %edx,%edx
  101168:	74 12                	je     10117c <strnlen+0x23>
  10116a:	80 39 00             	cmpb   $0x0,(%ecx)
  10116d:	74 0d                	je     10117c <strnlen+0x23>
		n++;
  10116f:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  101172:	39 d0                	cmp    %edx,%eax
  101174:	74 06                	je     10117c <strnlen+0x23>
  101176:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  10117a:	75 f3                	jne    10116f <strnlen+0x16>
		n++;
	return n;
}
  10117c:	f3 c3                	repz ret 

0010117e <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  10117e:	53                   	push   %ebx
  10117f:	8b 44 24 08          	mov    0x8(%esp),%eax
  101183:	8b 5c 24 0c          	mov    0xc(%esp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  101187:	ba 00 00 00 00       	mov    $0x0,%edx
  10118c:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  101190:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  101193:	83 c2 01             	add    $0x1,%edx
  101196:	84 c9                	test   %cl,%cl
  101198:	75 f2                	jne    10118c <strcpy+0xe>
		/* do nothing */;
	return ret;
}
  10119a:	5b                   	pop    %ebx
  10119b:	c3                   	ret    

0010119c <strcat>:

char *
strcat(char *dst, const char *src)
{
  10119c:	53                   	push   %ebx
  10119d:	83 ec 08             	sub    $0x8,%esp
  1011a0:	8b 5c 24 10          	mov    0x10(%esp),%ebx
	int len = strlen(dst);
  1011a4:	89 1c 24             	mov    %ebx,(%esp)
  1011a7:	e8 94 ff ff ff       	call   101140 <strlen>
	strcpy(dst + len, src);
  1011ac:	8b 54 24 14          	mov    0x14(%esp),%edx
  1011b0:	89 54 24 04          	mov    %edx,0x4(%esp)
  1011b4:	8d 04 03             	lea    (%ebx,%eax,1),%eax
  1011b7:	89 04 24             	mov    %eax,(%esp)
  1011ba:	e8 bf ff ff ff       	call   10117e <strcpy>
	return dst;
}
  1011bf:	89 d8                	mov    %ebx,%eax
  1011c1:	83 c4 08             	add    $0x8,%esp
  1011c4:	5b                   	pop    %ebx
  1011c5:	c3                   	ret    

001011c6 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  1011c6:	56                   	push   %esi
  1011c7:	53                   	push   %ebx
  1011c8:	8b 44 24 0c          	mov    0xc(%esp),%eax
  1011cc:	8b 54 24 10          	mov    0x10(%esp),%edx
  1011d0:	8b 74 24 14          	mov    0x14(%esp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  1011d4:	85 f6                	test   %esi,%esi
  1011d6:	74 18                	je     1011f0 <strncpy+0x2a>
  1011d8:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  1011dd:	0f b6 1a             	movzbl (%edx),%ebx
  1011e0:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  1011e3:	80 3a 01             	cmpb   $0x1,(%edx)
  1011e6:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  1011e9:	83 c1 01             	add    $0x1,%ecx
  1011ec:	39 ce                	cmp    %ecx,%esi
  1011ee:	77 ed                	ja     1011dd <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  1011f0:	5b                   	pop    %ebx
  1011f1:	5e                   	pop    %esi
  1011f2:	c3                   	ret    

001011f3 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  1011f3:	57                   	push   %edi
  1011f4:	56                   	push   %esi
  1011f5:	53                   	push   %ebx
  1011f6:	8b 7c 24 10          	mov    0x10(%esp),%edi
  1011fa:	8b 5c 24 14          	mov    0x14(%esp),%ebx
  1011fe:	8b 74 24 18          	mov    0x18(%esp),%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  101202:	89 f8                	mov    %edi,%eax
  101204:	85 f6                	test   %esi,%esi
  101206:	74 2c                	je     101234 <strlcpy+0x41>
		while (--size > 0 && *src != '\0')
  101208:	83 fe 01             	cmp    $0x1,%esi
  10120b:	74 24                	je     101231 <strlcpy+0x3e>
  10120d:	0f b6 0b             	movzbl (%ebx),%ecx
  101210:	84 c9                	test   %cl,%cl
  101212:	74 1d                	je     101231 <strlcpy+0x3e>
  101214:	ba 00 00 00 00       	mov    $0x0,%edx
	}
	return ret;
}

size_t
strlcpy(char *dst, const char *src, size_t size)
  101219:	83 ee 02             	sub    $0x2,%esi
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  10121c:	88 08                	mov    %cl,(%eax)
  10121e:	83 c0 01             	add    $0x1,%eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  101221:	39 f2                	cmp    %esi,%edx
  101223:	74 0c                	je     101231 <strlcpy+0x3e>
  101225:	0f b6 4c 13 01       	movzbl 0x1(%ebx,%edx,1),%ecx
  10122a:	83 c2 01             	add    $0x1,%edx
  10122d:	84 c9                	test   %cl,%cl
  10122f:	75 eb                	jne    10121c <strlcpy+0x29>
			*dst++ = *src++;
		*dst = '\0';
  101231:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  101234:	29 f8                	sub    %edi,%eax
}
  101236:	5b                   	pop    %ebx
  101237:	5e                   	pop    %esi
  101238:	5f                   	pop    %edi
  101239:	c3                   	ret    

0010123a <strcmp>:

int
strcmp(const char *p, const char *q)
{
  10123a:	8b 4c 24 04          	mov    0x4(%esp),%ecx
  10123e:	8b 54 24 08          	mov    0x8(%esp),%edx
	while (*p && *p == *q)
  101242:	0f b6 01             	movzbl (%ecx),%eax
  101245:	84 c0                	test   %al,%al
  101247:	74 15                	je     10125e <strcmp+0x24>
  101249:	3a 02                	cmp    (%edx),%al
  10124b:	75 11                	jne    10125e <strcmp+0x24>
		p++, q++;
  10124d:	83 c1 01             	add    $0x1,%ecx
  101250:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  101253:	0f b6 01             	movzbl (%ecx),%eax
  101256:	84 c0                	test   %al,%al
  101258:	74 04                	je     10125e <strcmp+0x24>
  10125a:	3a 02                	cmp    (%edx),%al
  10125c:	74 ef                	je     10124d <strcmp+0x13>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  10125e:	0f b6 c0             	movzbl %al,%eax
  101261:	0f b6 12             	movzbl (%edx),%edx
  101264:	29 d0                	sub    %edx,%eax
}
  101266:	c3                   	ret    

00101267 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  101267:	53                   	push   %ebx
  101268:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  10126c:	8b 5c 24 0c          	mov    0xc(%esp),%ebx
  101270:	8b 54 24 10          	mov    0x10(%esp),%edx
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  101274:	b8 00 00 00 00       	mov    $0x0,%eax
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  101279:	85 d2                	test   %edx,%edx
  10127b:	74 28                	je     1012a5 <strncmp+0x3e>
  10127d:	0f b6 01             	movzbl (%ecx),%eax
  101280:	84 c0                	test   %al,%al
  101282:	74 23                	je     1012a7 <strncmp+0x40>
  101284:	3a 03                	cmp    (%ebx),%al
  101286:	75 1f                	jne    1012a7 <strncmp+0x40>
  101288:	83 ea 01             	sub    $0x1,%edx
  10128b:	74 13                	je     1012a0 <strncmp+0x39>
		n--, p++, q++;
  10128d:	83 c1 01             	add    $0x1,%ecx
  101290:	83 c3 01             	add    $0x1,%ebx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  101293:	0f b6 01             	movzbl (%ecx),%eax
  101296:	84 c0                	test   %al,%al
  101298:	74 0d                	je     1012a7 <strncmp+0x40>
  10129a:	3a 03                	cmp    (%ebx),%al
  10129c:	74 ea                	je     101288 <strncmp+0x21>
  10129e:	eb 07                	jmp    1012a7 <strncmp+0x40>
		n--, p++, q++;
	if (n == 0)
		return 0;
  1012a0:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  1012a5:	5b                   	pop    %ebx
  1012a6:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  1012a7:	0f b6 01             	movzbl (%ecx),%eax
  1012aa:	0f b6 13             	movzbl (%ebx),%edx
  1012ad:	29 d0                	sub    %edx,%eax
  1012af:	eb f4                	jmp    1012a5 <strncmp+0x3e>

001012b1 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  1012b1:	8b 44 24 04          	mov    0x4(%esp),%eax
  1012b5:	0f b6 4c 24 08       	movzbl 0x8(%esp),%ecx
	for (; *s; s++)
  1012ba:	0f b6 10             	movzbl (%eax),%edx
  1012bd:	84 d2                	test   %dl,%dl
  1012bf:	74 21                	je     1012e2 <strchr+0x31>
		if (*s == c)
  1012c1:	38 ca                	cmp    %cl,%dl
  1012c3:	75 0d                	jne    1012d2 <strchr+0x21>
  1012c5:	f3 c3                	repz ret 
  1012c7:	38 ca                	cmp    %cl,%dl
  1012c9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  1012d0:	74 15                	je     1012e7 <strchr+0x36>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  1012d2:	83 c0 01             	add    $0x1,%eax
  1012d5:	0f b6 10             	movzbl (%eax),%edx
  1012d8:	84 d2                	test   %dl,%dl
  1012da:	75 eb                	jne    1012c7 <strchr+0x16>
		if (*s == c)
			return (char *) s;
	return 0;
  1012dc:	b8 00 00 00 00       	mov    $0x0,%eax
  1012e1:	c3                   	ret    
  1012e2:	b8 00 00 00 00       	mov    $0x0,%eax
}
  1012e7:	f3 c3                	repz ret 

001012e9 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  1012e9:	8b 44 24 04          	mov    0x4(%esp),%eax
  1012ed:	0f b6 4c 24 08       	movzbl 0x8(%esp),%ecx
	for (; *s; s++)
  1012f2:	0f b6 10             	movzbl (%eax),%edx
  1012f5:	84 d2                	test   %dl,%dl
  1012f7:	74 14                	je     10130d <strfind+0x24>
		if (*s == c)
  1012f9:	38 ca                	cmp    %cl,%dl
  1012fb:	75 06                	jne    101303 <strfind+0x1a>
  1012fd:	f3 c3                	repz ret 
  1012ff:	38 ca                	cmp    %cl,%dl
  101301:	74 0a                	je     10130d <strfind+0x24>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  101303:	83 c0 01             	add    $0x1,%eax
  101306:	0f b6 10             	movzbl (%eax),%edx
  101309:	84 d2                	test   %dl,%dl
  10130b:	75 f2                	jne    1012ff <strfind+0x16>
		if (*s == c)
			break;
	return (char *) s;
}
  10130d:	f3 c3                	repz ret 

0010130f <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  10130f:	83 ec 0c             	sub    $0xc,%esp
  101312:	89 1c 24             	mov    %ebx,(%esp)
  101315:	89 74 24 04          	mov    %esi,0x4(%esp)
  101319:	89 7c 24 08          	mov    %edi,0x8(%esp)
  10131d:	8b 7c 24 10          	mov    0x10(%esp),%edi
  101321:	8b 44 24 14          	mov    0x14(%esp),%eax
  101325:	8b 4c 24 18          	mov    0x18(%esp),%ecx
	char *p;

	if (n == 0)
  101329:	85 c9                	test   %ecx,%ecx
  10132b:	74 30                	je     10135d <memset+0x4e>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  10132d:	f7 c7 03 00 00 00    	test   $0x3,%edi
  101333:	75 25                	jne    10135a <memset+0x4b>
  101335:	f6 c1 03             	test   $0x3,%cl
  101338:	75 20                	jne    10135a <memset+0x4b>
		c &= 0xFF;
  10133a:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  10133d:	89 d3                	mov    %edx,%ebx
  10133f:	c1 e3 08             	shl    $0x8,%ebx
  101342:	89 d6                	mov    %edx,%esi
  101344:	c1 e6 18             	shl    $0x18,%esi
  101347:	89 d0                	mov    %edx,%eax
  101349:	c1 e0 10             	shl    $0x10,%eax
  10134c:	09 f0                	or     %esi,%eax
  10134e:	09 d0                	or     %edx,%eax
  101350:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  101352:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  101355:	fc                   	cld    
  101356:	f3 ab                	rep stos %eax,%es:(%edi)
  101358:	eb 03                	jmp    10135d <memset+0x4e>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  10135a:	fc                   	cld    
  10135b:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  10135d:	89 f8                	mov    %edi,%eax
  10135f:	8b 1c 24             	mov    (%esp),%ebx
  101362:	8b 74 24 04          	mov    0x4(%esp),%esi
  101366:	8b 7c 24 08          	mov    0x8(%esp),%edi
  10136a:	83 c4 0c             	add    $0xc,%esp
  10136d:	c3                   	ret    

0010136e <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  10136e:	83 ec 08             	sub    $0x8,%esp
  101371:	89 34 24             	mov    %esi,(%esp)
  101374:	89 7c 24 04          	mov    %edi,0x4(%esp)
  101378:	8b 44 24 0c          	mov    0xc(%esp),%eax
  10137c:	8b 74 24 10          	mov    0x10(%esp),%esi
  101380:	8b 4c 24 14          	mov    0x14(%esp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  101384:	39 c6                	cmp    %eax,%esi
  101386:	73 36                	jae    1013be <memmove+0x50>
  101388:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  10138b:	39 d0                	cmp    %edx,%eax
  10138d:	73 2f                	jae    1013be <memmove+0x50>
		s += n;
		d += n;
  10138f:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  101392:	f6 c2 03             	test   $0x3,%dl
  101395:	75 1b                	jne    1013b2 <memmove+0x44>
  101397:	f7 c7 03 00 00 00    	test   $0x3,%edi
  10139d:	75 13                	jne    1013b2 <memmove+0x44>
  10139f:	f6 c1 03             	test   $0x3,%cl
  1013a2:	75 0e                	jne    1013b2 <memmove+0x44>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  1013a4:	83 ef 04             	sub    $0x4,%edi
  1013a7:	8d 72 fc             	lea    -0x4(%edx),%esi
  1013aa:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  1013ad:	fd                   	std    
  1013ae:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  1013b0:	eb 09                	jmp    1013bb <memmove+0x4d>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  1013b2:	83 ef 01             	sub    $0x1,%edi
  1013b5:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  1013b8:	fd                   	std    
  1013b9:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  1013bb:	fc                   	cld    
  1013bc:	eb 20                	jmp    1013de <memmove+0x70>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  1013be:	f7 c6 03 00 00 00    	test   $0x3,%esi
  1013c4:	75 13                	jne    1013d9 <memmove+0x6b>
  1013c6:	a8 03                	test   $0x3,%al
  1013c8:	75 0f                	jne    1013d9 <memmove+0x6b>
  1013ca:	f6 c1 03             	test   $0x3,%cl
  1013cd:	75 0a                	jne    1013d9 <memmove+0x6b>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  1013cf:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  1013d2:	89 c7                	mov    %eax,%edi
  1013d4:	fc                   	cld    
  1013d5:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  1013d7:	eb 05                	jmp    1013de <memmove+0x70>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  1013d9:	89 c7                	mov    %eax,%edi
  1013db:	fc                   	cld    
  1013dc:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  1013de:	8b 34 24             	mov    (%esp),%esi
  1013e1:	8b 7c 24 04          	mov    0x4(%esp),%edi
  1013e5:	83 c4 08             	add    $0x8,%esp
  1013e8:	c3                   	ret    

001013e9 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  1013e9:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  1013ec:	8b 44 24 18          	mov    0x18(%esp),%eax
  1013f0:	89 44 24 08          	mov    %eax,0x8(%esp)
  1013f4:	8b 44 24 14          	mov    0x14(%esp),%eax
  1013f8:	89 44 24 04          	mov    %eax,0x4(%esp)
  1013fc:	8b 44 24 10          	mov    0x10(%esp),%eax
  101400:	89 04 24             	mov    %eax,(%esp)
  101403:	e8 66 ff ff ff       	call   10136e <memmove>
}
  101408:	83 c4 0c             	add    $0xc,%esp
  10140b:	c3                   	ret    

0010140c <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  10140c:	57                   	push   %edi
  10140d:	56                   	push   %esi
  10140e:	53                   	push   %ebx
  10140f:	8b 5c 24 10          	mov    0x10(%esp),%ebx
  101413:	8b 74 24 14          	mov    0x14(%esp),%esi
  101417:	8b 7c 24 18          	mov    0x18(%esp),%edi
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  10141b:	b8 00 00 00 00       	mov    $0x0,%eax
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  101420:	85 ff                	test   %edi,%edi
  101422:	74 38                	je     10145c <memcmp+0x50>
		if (*s1 != *s2)
  101424:	0f b6 03             	movzbl (%ebx),%eax
  101427:	0f b6 0e             	movzbl (%esi),%ecx
  10142a:	38 c8                	cmp    %cl,%al
  10142c:	74 1d                	je     10144b <memcmp+0x3f>
  10142e:	eb 11                	jmp    101441 <memcmp+0x35>
  101430:	0f b6 44 13 01       	movzbl 0x1(%ebx,%edx,1),%eax
  101435:	0f b6 4c 16 01       	movzbl 0x1(%esi,%edx,1),%ecx
  10143a:	83 c2 01             	add    $0x1,%edx
  10143d:	38 c8                	cmp    %cl,%al
  10143f:	74 12                	je     101453 <memcmp+0x47>
			return (int) *s1 - (int) *s2;
  101441:	0f b6 c0             	movzbl %al,%eax
  101444:	0f b6 c9             	movzbl %cl,%ecx
  101447:	29 c8                	sub    %ecx,%eax
  101449:	eb 11                	jmp    10145c <memcmp+0x50>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  10144b:	83 ef 01             	sub    $0x1,%edi
  10144e:	ba 00 00 00 00       	mov    $0x0,%edx
  101453:	39 fa                	cmp    %edi,%edx
  101455:	75 d9                	jne    101430 <memcmp+0x24>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  101457:	b8 00 00 00 00       	mov    $0x0,%eax
}
  10145c:	5b                   	pop    %ebx
  10145d:	5e                   	pop    %esi
  10145e:	5f                   	pop    %edi
  10145f:	c3                   	ret    

00101460 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  101460:	8b 44 24 04          	mov    0x4(%esp),%eax
	const void *ends = (const char *) s + n;
  101464:	89 c2                	mov    %eax,%edx
  101466:	03 54 24 0c          	add    0xc(%esp),%edx
	for (; s < ends; s++)
  10146a:	39 d0                	cmp    %edx,%eax
  10146c:	73 16                	jae    101484 <memfind+0x24>
		if (*(const unsigned char *) s == (unsigned char) c)
  10146e:	0f b6 4c 24 08       	movzbl 0x8(%esp),%ecx
  101473:	38 08                	cmp    %cl,(%eax)
  101475:	75 06                	jne    10147d <memfind+0x1d>
  101477:	f3 c3                	repz ret 
  101479:	38 08                	cmp    %cl,(%eax)
  10147b:	74 07                	je     101484 <memfind+0x24>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  10147d:	83 c0 01             	add    $0x1,%eax
  101480:	39 c2                	cmp    %eax,%edx
  101482:	77 f5                	ja     101479 <memfind+0x19>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  101484:	f3 c3                	repz ret 

00101486 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  101486:	55                   	push   %ebp
  101487:	57                   	push   %edi
  101488:	56                   	push   %esi
  101489:	53                   	push   %ebx
  10148a:	8b 54 24 14          	mov    0x14(%esp),%edx
  10148e:	8b 74 24 18          	mov    0x18(%esp),%esi
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  101492:	0f b6 02             	movzbl (%edx),%eax
  101495:	3c 20                	cmp    $0x20,%al
  101497:	74 04                	je     10149d <strtol+0x17>
  101499:	3c 09                	cmp    $0x9,%al
  10149b:	75 0e                	jne    1014ab <strtol+0x25>
		s++;
  10149d:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  1014a0:	0f b6 02             	movzbl (%edx),%eax
  1014a3:	3c 20                	cmp    $0x20,%al
  1014a5:	74 f6                	je     10149d <strtol+0x17>
  1014a7:	3c 09                	cmp    $0x9,%al
  1014a9:	74 f2                	je     10149d <strtol+0x17>
		s++;

	// plus/minus sign
	if (*s == '+')
  1014ab:	3c 2b                	cmp    $0x2b,%al
  1014ad:	75 0a                	jne    1014b9 <strtol+0x33>
		s++;
  1014af:	83 c2 01             	add    $0x1,%edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  1014b2:	bf 00 00 00 00       	mov    $0x0,%edi
  1014b7:	eb 10                	jmp    1014c9 <strtol+0x43>
  1014b9:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  1014be:	3c 2d                	cmp    $0x2d,%al
  1014c0:	75 07                	jne    1014c9 <strtol+0x43>
		s++, neg = 1;
  1014c2:	83 c2 01             	add    $0x1,%edx
  1014c5:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  1014c9:	83 7c 24 1c 00       	cmpl   $0x0,0x1c(%esp)
  1014ce:	0f 94 c0             	sete   %al
  1014d1:	74 07                	je     1014da <strtol+0x54>
  1014d3:	83 7c 24 1c 10       	cmpl   $0x10,0x1c(%esp)
  1014d8:	75 18                	jne    1014f2 <strtol+0x6c>
  1014da:	80 3a 30             	cmpb   $0x30,(%edx)
  1014dd:	75 13                	jne    1014f2 <strtol+0x6c>
  1014df:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  1014e3:	75 0d                	jne    1014f2 <strtol+0x6c>
		s += 2, base = 16;
  1014e5:	83 c2 02             	add    $0x2,%edx
  1014e8:	c7 44 24 1c 10 00 00 	movl   $0x10,0x1c(%esp)
  1014ef:	00 
  1014f0:	eb 1c                	jmp    10150e <strtol+0x88>
	else if (base == 0 && s[0] == '0')
  1014f2:	84 c0                	test   %al,%al
  1014f4:	74 18                	je     10150e <strtol+0x88>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  1014f6:	c7 44 24 1c 0a 00 00 	movl   $0xa,0x1c(%esp)
  1014fd:	00 
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  1014fe:	80 3a 30             	cmpb   $0x30,(%edx)
  101501:	75 0b                	jne    10150e <strtol+0x88>
		s++, base = 8;
  101503:	83 c2 01             	add    $0x1,%edx
  101506:	c7 44 24 1c 08 00 00 	movl   $0x8,0x1c(%esp)
  10150d:	00 
	else if (base == 0)
		base = 10;
  10150e:	b8 00 00 00 00       	mov    $0x0,%eax

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  101513:	0f b6 0a             	movzbl (%edx),%ecx
  101516:	8d 69 d0             	lea    -0x30(%ecx),%ebp
  101519:	89 eb                	mov    %ebp,%ebx
  10151b:	80 fb 09             	cmp    $0x9,%bl
  10151e:	77 08                	ja     101528 <strtol+0xa2>
			dig = *s - '0';
  101520:	0f be c9             	movsbl %cl,%ecx
  101523:	83 e9 30             	sub    $0x30,%ecx
  101526:	eb 22                	jmp    10154a <strtol+0xc4>
		else if (*s >= 'a' && *s <= 'z')
  101528:	8d 69 9f             	lea    -0x61(%ecx),%ebp
  10152b:	89 eb                	mov    %ebp,%ebx
  10152d:	80 fb 19             	cmp    $0x19,%bl
  101530:	77 08                	ja     10153a <strtol+0xb4>
			dig = *s - 'a' + 10;
  101532:	0f be c9             	movsbl %cl,%ecx
  101535:	83 e9 57             	sub    $0x57,%ecx
  101538:	eb 10                	jmp    10154a <strtol+0xc4>
		else if (*s >= 'A' && *s <= 'Z')
  10153a:	8d 69 bf             	lea    -0x41(%ecx),%ebp
  10153d:	89 eb                	mov    %ebp,%ebx
  10153f:	80 fb 19             	cmp    $0x19,%bl
  101542:	77 19                	ja     10155d <strtol+0xd7>
			dig = *s - 'A' + 10;
  101544:	0f be c9             	movsbl %cl,%ecx
  101547:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  10154a:	3b 4c 24 1c          	cmp    0x1c(%esp),%ecx
  10154e:	7d 11                	jge    101561 <strtol+0xdb>
			break;
		s++, val = (val * base) + dig;
  101550:	83 c2 01             	add    $0x1,%edx
  101553:	0f af 44 24 1c       	imul   0x1c(%esp),%eax
  101558:	8d 04 01             	lea    (%ecx,%eax,1),%eax
		// we don't properly detect overflow!
	}
  10155b:	eb b6                	jmp    101513 <strtol+0x8d>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  10155d:	89 c1                	mov    %eax,%ecx
  10155f:	eb 02                	jmp    101563 <strtol+0xdd>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  101561:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  101563:	85 f6                	test   %esi,%esi
  101565:	74 02                	je     101569 <strtol+0xe3>
		*endptr = (char *) s;
  101567:	89 16                	mov    %edx,(%esi)
	return (neg ? -val : val);
  101569:	89 ca                	mov    %ecx,%edx
  10156b:	f7 da                	neg    %edx
  10156d:	85 ff                	test   %edi,%edi
  10156f:	0f 45 c2             	cmovne %edx,%eax
}
  101572:	5b                   	pop    %ebx
  101573:	5e                   	pop    %esi
  101574:	5f                   	pop    %edi
  101575:	5d                   	pop    %ebp
  101576:	c3                   	ret    
	...

00101580 <__udivdi3>:
  101580:	55                   	push   %ebp
  101581:	89 e5                	mov    %esp,%ebp
  101583:	57                   	push   %edi
  101584:	56                   	push   %esi
  101585:	8d 64 24 e0          	lea    -0x20(%esp),%esp
  101589:	8b 45 14             	mov    0x14(%ebp),%eax
  10158c:	8b 75 08             	mov    0x8(%ebp),%esi
  10158f:	8b 4d 10             	mov    0x10(%ebp),%ecx
  101592:	85 c0                	test   %eax,%eax
  101594:	89 75 e8             	mov    %esi,-0x18(%ebp)
  101597:	8b 7d 0c             	mov    0xc(%ebp),%edi
  10159a:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  10159d:	75 39                	jne    1015d8 <__udivdi3+0x58>
  10159f:	39 f9                	cmp    %edi,%ecx
  1015a1:	77 65                	ja     101608 <__udivdi3+0x88>
  1015a3:	85 c9                	test   %ecx,%ecx
  1015a5:	75 0b                	jne    1015b2 <__udivdi3+0x32>
  1015a7:	b8 01 00 00 00       	mov    $0x1,%eax
  1015ac:	31 d2                	xor    %edx,%edx
  1015ae:	f7 f1                	div    %ecx
  1015b0:	89 c1                	mov    %eax,%ecx
  1015b2:	89 f8                	mov    %edi,%eax
  1015b4:	31 d2                	xor    %edx,%edx
  1015b6:	f7 f1                	div    %ecx
  1015b8:	89 c7                	mov    %eax,%edi
  1015ba:	89 f0                	mov    %esi,%eax
  1015bc:	f7 f1                	div    %ecx
  1015be:	89 fa                	mov    %edi,%edx
  1015c0:	89 c6                	mov    %eax,%esi
  1015c2:	89 75 f0             	mov    %esi,-0x10(%ebp)
  1015c5:	89 55 f4             	mov    %edx,-0xc(%ebp)
  1015c8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1015cb:	8b 55 f4             	mov    -0xc(%ebp),%edx
  1015ce:	8d 64 24 20          	lea    0x20(%esp),%esp
  1015d2:	5e                   	pop    %esi
  1015d3:	5f                   	pop    %edi
  1015d4:	5d                   	pop    %ebp
  1015d5:	c3                   	ret    
  1015d6:	66 90                	xchg   %ax,%ax
  1015d8:	31 d2                	xor    %edx,%edx
  1015da:	31 f6                	xor    %esi,%esi
  1015dc:	39 f8                	cmp    %edi,%eax
  1015de:	77 e2                	ja     1015c2 <__udivdi3+0x42>
  1015e0:	0f bd d0             	bsr    %eax,%edx
  1015e3:	83 f2 1f             	xor    $0x1f,%edx
  1015e6:	89 55 ec             	mov    %edx,-0x14(%ebp)
  1015e9:	75 2d                	jne    101618 <__udivdi3+0x98>
  1015eb:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  1015ee:	39 4d f0             	cmp    %ecx,-0x10(%ebp)
  1015f1:	76 06                	jbe    1015f9 <__udivdi3+0x79>
  1015f3:	39 f8                	cmp    %edi,%eax
  1015f5:	89 f2                	mov    %esi,%edx
  1015f7:	73 c9                	jae    1015c2 <__udivdi3+0x42>
  1015f9:	31 d2                	xor    %edx,%edx
  1015fb:	be 01 00 00 00       	mov    $0x1,%esi
  101600:	eb c0                	jmp    1015c2 <__udivdi3+0x42>
  101602:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  101608:	89 f0                	mov    %esi,%eax
  10160a:	89 fa                	mov    %edi,%edx
  10160c:	f7 f1                	div    %ecx
  10160e:	31 d2                	xor    %edx,%edx
  101610:	89 c6                	mov    %eax,%esi
  101612:	eb ae                	jmp    1015c2 <__udivdi3+0x42>
  101614:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  101618:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  10161c:	89 c2                	mov    %eax,%edx
  10161e:	b8 20 00 00 00       	mov    $0x20,%eax
  101623:	2b 45 ec             	sub    -0x14(%ebp),%eax
  101626:	d3 e2                	shl    %cl,%edx
  101628:	89 c1                	mov    %eax,%ecx
  10162a:	8b 75 f0             	mov    -0x10(%ebp),%esi
  10162d:	d3 ee                	shr    %cl,%esi
  10162f:	09 d6                	or     %edx,%esi
  101631:	89 fa                	mov    %edi,%edx
  101633:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  101637:	89 75 e4             	mov    %esi,-0x1c(%ebp)
  10163a:	8b 75 f0             	mov    -0x10(%ebp),%esi
  10163d:	d3 e6                	shl    %cl,%esi
  10163f:	89 c1                	mov    %eax,%ecx
  101641:	89 75 f0             	mov    %esi,-0x10(%ebp)
  101644:	8b 75 e8             	mov    -0x18(%ebp),%esi
  101647:	d3 ea                	shr    %cl,%edx
  101649:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  10164d:	d3 e7                	shl    %cl,%edi
  10164f:	89 c1                	mov    %eax,%ecx
  101651:	d3 ee                	shr    %cl,%esi
  101653:	09 fe                	or     %edi,%esi
  101655:	89 f0                	mov    %esi,%eax
  101657:	f7 75 e4             	divl   -0x1c(%ebp)
  10165a:	89 d7                	mov    %edx,%edi
  10165c:	89 c6                	mov    %eax,%esi
  10165e:	f7 65 f0             	mull   -0x10(%ebp)
  101661:	39 d7                	cmp    %edx,%edi
  101663:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  101666:	72 12                	jb     10167a <__udivdi3+0xfa>
  101668:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  10166c:	8b 55 e8             	mov    -0x18(%ebp),%edx
  10166f:	d3 e2                	shl    %cl,%edx
  101671:	39 c2                	cmp    %eax,%edx
  101673:	73 08                	jae    10167d <__udivdi3+0xfd>
  101675:	3b 7d e4             	cmp    -0x1c(%ebp),%edi
  101678:	75 03                	jne    10167d <__udivdi3+0xfd>
  10167a:	8d 76 ff             	lea    -0x1(%esi),%esi
  10167d:	31 d2                	xor    %edx,%edx
  10167f:	e9 3e ff ff ff       	jmp    1015c2 <__udivdi3+0x42>
	...

00101690 <__umoddi3>:
  101690:	55                   	push   %ebp
  101691:	89 e5                	mov    %esp,%ebp
  101693:	57                   	push   %edi
  101694:	56                   	push   %esi
  101695:	8d 64 24 e0          	lea    -0x20(%esp),%esp
  101699:	8b 7d 14             	mov    0x14(%ebp),%edi
  10169c:	8b 45 08             	mov    0x8(%ebp),%eax
  10169f:	8b 4d 10             	mov    0x10(%ebp),%ecx
  1016a2:	8b 75 0c             	mov    0xc(%ebp),%esi
  1016a5:	85 ff                	test   %edi,%edi
  1016a7:	89 45 e8             	mov    %eax,-0x18(%ebp)
  1016aa:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  1016ad:	89 45 f0             	mov    %eax,-0x10(%ebp)
  1016b0:	89 f2                	mov    %esi,%edx
  1016b2:	75 14                	jne    1016c8 <__umoddi3+0x38>
  1016b4:	39 f1                	cmp    %esi,%ecx
  1016b6:	76 40                	jbe    1016f8 <__umoddi3+0x68>
  1016b8:	f7 f1                	div    %ecx
  1016ba:	89 d0                	mov    %edx,%eax
  1016bc:	31 d2                	xor    %edx,%edx
  1016be:	8d 64 24 20          	lea    0x20(%esp),%esp
  1016c2:	5e                   	pop    %esi
  1016c3:	5f                   	pop    %edi
  1016c4:	5d                   	pop    %ebp
  1016c5:	c3                   	ret    
  1016c6:	66 90                	xchg   %ax,%ax
  1016c8:	39 f7                	cmp    %esi,%edi
  1016ca:	77 4c                	ja     101718 <__umoddi3+0x88>
  1016cc:	0f bd c7             	bsr    %edi,%eax
  1016cf:	83 f0 1f             	xor    $0x1f,%eax
  1016d2:	89 45 ec             	mov    %eax,-0x14(%ebp)
  1016d5:	75 51                	jne    101728 <__umoddi3+0x98>
  1016d7:	3b 4d f0             	cmp    -0x10(%ebp),%ecx
  1016da:	0f 87 e8 00 00 00    	ja     1017c8 <__umoddi3+0x138>
  1016e0:	89 f2                	mov    %esi,%edx
  1016e2:	8b 75 f0             	mov    -0x10(%ebp),%esi
  1016e5:	29 ce                	sub    %ecx,%esi
  1016e7:	19 fa                	sbb    %edi,%edx
  1016e9:	89 75 f0             	mov    %esi,-0x10(%ebp)
  1016ec:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1016ef:	8d 64 24 20          	lea    0x20(%esp),%esp
  1016f3:	5e                   	pop    %esi
  1016f4:	5f                   	pop    %edi
  1016f5:	5d                   	pop    %ebp
  1016f6:	c3                   	ret    
  1016f7:	90                   	nop
  1016f8:	85 c9                	test   %ecx,%ecx
  1016fa:	75 0b                	jne    101707 <__umoddi3+0x77>
  1016fc:	b8 01 00 00 00       	mov    $0x1,%eax
  101701:	31 d2                	xor    %edx,%edx
  101703:	f7 f1                	div    %ecx
  101705:	89 c1                	mov    %eax,%ecx
  101707:	89 f0                	mov    %esi,%eax
  101709:	31 d2                	xor    %edx,%edx
  10170b:	f7 f1                	div    %ecx
  10170d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  101710:	f7 f1                	div    %ecx
  101712:	eb a6                	jmp    1016ba <__umoddi3+0x2a>
  101714:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  101718:	89 f2                	mov    %esi,%edx
  10171a:	8d 64 24 20          	lea    0x20(%esp),%esp
  10171e:	5e                   	pop    %esi
  10171f:	5f                   	pop    %edi
  101720:	5d                   	pop    %ebp
  101721:	c3                   	ret    
  101722:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  101728:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  10172c:	c7 45 f0 20 00 00 00 	movl   $0x20,-0x10(%ebp)
  101733:	8b 45 ec             	mov    -0x14(%ebp),%eax
  101736:	29 45 f0             	sub    %eax,-0x10(%ebp)
  101739:	d3 e7                	shl    %cl,%edi
  10173b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10173e:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  101742:	89 f2                	mov    %esi,%edx
  101744:	d3 e8                	shr    %cl,%eax
  101746:	09 f8                	or     %edi,%eax
  101748:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  10174c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  10174f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  101752:	d3 e0                	shl    %cl,%eax
  101754:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  101758:	89 45 f4             	mov    %eax,-0xc(%ebp)
  10175b:	8b 45 e8             	mov    -0x18(%ebp),%eax
  10175e:	d3 ea                	shr    %cl,%edx
  101760:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  101764:	d3 e6                	shl    %cl,%esi
  101766:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  10176a:	d3 e8                	shr    %cl,%eax
  10176c:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  101770:	09 f0                	or     %esi,%eax
  101772:	8b 75 e8             	mov    -0x18(%ebp),%esi
  101775:	d3 e6                	shl    %cl,%esi
  101777:	f7 75 e4             	divl   -0x1c(%ebp)
  10177a:	89 75 e8             	mov    %esi,-0x18(%ebp)
  10177d:	89 d6                	mov    %edx,%esi
  10177f:	f7 65 f4             	mull   -0xc(%ebp)
  101782:	89 d7                	mov    %edx,%edi
  101784:	89 c2                	mov    %eax,%edx
  101786:	39 fe                	cmp    %edi,%esi
  101788:	89 f9                	mov    %edi,%ecx
  10178a:	72 30                	jb     1017bc <__umoddi3+0x12c>
  10178c:	39 45 e8             	cmp    %eax,-0x18(%ebp)
  10178f:	72 27                	jb     1017b8 <__umoddi3+0x128>
  101791:	8b 45 e8             	mov    -0x18(%ebp),%eax
  101794:	29 d0                	sub    %edx,%eax
  101796:	19 ce                	sbb    %ecx,%esi
  101798:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  10179c:	89 f2                	mov    %esi,%edx
  10179e:	d3 e8                	shr    %cl,%eax
  1017a0:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  1017a4:	d3 e2                	shl    %cl,%edx
  1017a6:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  1017aa:	09 d0                	or     %edx,%eax
  1017ac:	89 f2                	mov    %esi,%edx
  1017ae:	d3 ea                	shr    %cl,%edx
  1017b0:	8d 64 24 20          	lea    0x20(%esp),%esp
  1017b4:	5e                   	pop    %esi
  1017b5:	5f                   	pop    %edi
  1017b6:	5d                   	pop    %ebp
  1017b7:	c3                   	ret    
  1017b8:	39 fe                	cmp    %edi,%esi
  1017ba:	75 d5                	jne    101791 <__umoddi3+0x101>
  1017bc:	89 f9                	mov    %edi,%ecx
  1017be:	89 c2                	mov    %eax,%edx
  1017c0:	2b 55 f4             	sub    -0xc(%ebp),%edx
  1017c3:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  1017c6:	eb c9                	jmp    101791 <__umoddi3+0x101>
  1017c8:	39 f7                	cmp    %esi,%edi
  1017ca:	0f 82 10 ff ff ff    	jb     1016e0 <__umoddi3+0x50>
  1017d0:	e9 17 ff ff ff       	jmp    1016ec <__umoddi3+0x5c>
