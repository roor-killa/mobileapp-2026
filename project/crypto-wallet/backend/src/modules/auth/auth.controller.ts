import { Controller, Post, Get, Body, UseGuards, Req } from '@nestjs/common';
import { AuthGuard } from '@nestjs/passport';
import { AuthService } from './auth.service';

@Controller('auth')
export class AuthController {
  constructor(private readonly authService: AuthService) {}

  // Vérifier la session (token JWT valide) et retourner l'utilisateur
  @Get('me')
  @UseGuards(AuthGuard('jwt'))
  async me(@Req() req: { user: { userId: string } }) {
    return this.authService.getMe(req.user.userId);
  }

  // Inscription : crée le compte + génère automatiquement les wallets ETH et SOL
  @Post('register')
  async register(
    @Body() body: { email: string; password: string; name: string },
  ) {
    return this.authService.register(body.email, body.password, body.name);
  }

  // Connexion : vérifie les identifiants et retourne un token JWT
  @Post('login')
  async login(@Body() body: { email: string; password: string }) {
    return this.authService.login(body.email, body.password);
  }
}
