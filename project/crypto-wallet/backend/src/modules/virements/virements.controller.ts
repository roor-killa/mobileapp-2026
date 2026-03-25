import { BadRequestException, Controller, Get, Post, Body, UseGuards, Request } from '@nestjs/common';
import { AuthGuard } from '@nestjs/passport';
import { VirementsService } from './virements.service';

@Controller('virements')
@UseGuards(AuthGuard('appwrite-jwt'))
export class VirementsController {
  constructor(private readonly virementsService: VirementsService) {}

  @Get('balance')
  async getBalance(@Request() req: { user: { userId: string } }) {
    return this.virementsService.getBalance(req.user.userId);
  }

  @Get('me')
  async getMe(@Request() req: { user: { userId: string } }) {
    return this.virementsService.getMeInfo(req.user.userId);
  }

  @Get('history')
  async getHistory(@Request() req: { user: { userId: string } }) {
    return this.virementsService.getHistory(req.user.userId);
  }

  @Post('send')
  async send(
    @Request() req: { user: { userId: string } },
    @Body() body: { toIdentifier?: string; toEmail?: string; amount?: number },
  ) {
    const toIdentifier = String(body?.toIdentifier ?? body?.toEmail ?? '').trim();
    const amount = Number(body?.amount ?? 0);
    console.log('[Virements] POST /send', { fromUserId: req.user.userId, toIdentifier, amount });
    if (!toIdentifier) {
      throw new BadRequestException(
        "Indiquez l'IBAN, le pseudonyme ou l'email du destinataire",
      );
    }
    try {
      const result = await this.virementsService.sendToUser(
        req.user.userId,
        toIdentifier,
        amount,
      );
      console.log('[Virements] Succès', result);
      return result;
    } catch (e) {
      console.error('[Virements] Erreur', e);
      throw e;
    }
  }
}
