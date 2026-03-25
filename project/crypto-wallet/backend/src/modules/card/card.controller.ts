import { Controller, Get, UseGuards, Request } from '@nestjs/common';
import { AuthGuard } from '@nestjs/passport';
import { CardService } from './card.service';

@Controller('card')
@UseGuards(AuthGuard('appwrite-jwt'))
export class CardController {
  constructor(private readonly cardService: CardService) {}

  @Get()
  async getCard(@Request() req: { user: { userId: string } }) {
    const card = await this.cardService.getOrCreateCard(req.user.userId);
    if (!card) return { error: 'Utilisateur introuvable' };
    return card;
  }
}
